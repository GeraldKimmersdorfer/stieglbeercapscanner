function [centers,estimated_r] = findCircles(biImg, radius_range)
%FINDCIRCLES finds circles using circular hough transformation
%   Author: Levent
%   basically a very simple reimplementation of imfindcircles
%   1. compute 2D accumulator
%   2. estimate centers
%   3. estimate radii using the phase-coding method
%
%   parameters:
%       biImg = binary edge image (sobel filter)
%       radius_range = 2x1 array with (1) lower end and (2) upper end
%
%   output:
%       centers = nx2 array with n circle centers (n, 1) => Y coord, (n, 2)
%       => X coord
%       estimated_r = nx1 array estimated radius for each of the n circle
%       in the same order
%
%       length(centers) == length(estimated_r)
%   References:
%   -----------
%   [1] H. K. Yuen, J. Princen, J. Illingworth, and J. Kittler,
%       "Comparative study of Hough Transform methods for circle finding,"
%       Image and Vision Computing, Volume 8, Number 1, 1990, pp. 71-77.
%
%   [2] T. J. Atherton, D. J. Kerbyson, "Size invariant circle detection,"
%       Image and Vision Computing, Volume 17, Number 11, 1999, pp. 795-803.
    centers=[];
    estimated_r=[];
    
    %% compute accumulator
    [accuMatrix] = compAccu(biImg, radius_range);
    
    %% check if accumatrix is 0
    if(~any(accuMatrix(:)))
        return;
    end
    
    %% estimate centers
    centers = estCenters(accuMatrix);
    
    %% estimate radii
    estimated_r = estRadii(centers, accuMatrix, radius_range);
end

function [accuMatrix] = compAccu(biImg, radius_range)
%COMPACCU computes 2d accumulator array using circular hough transformation
%   turns biImg to grayImage and gets gradient 
%   gets edge pixels
%   computes weights for votes using phase-coding method
%   calculates accumulator array
%
%   parameters:
%       biImg = binary edge image (sobel filter)
%       radius_range = 2x1 array with (1) lower end and (2) upper end
%
%   ouput:
%       accuMatrix = m x n array => size(biImg), calculated accumulator
%       array

%% get image in correct format
img = getGrayImage(biImg);

%% calculate gradient
[gx, gy, gradientImg] = getGradientImg(img);

%% get edge pixels
[ex, ey] = getEdgePixels(gradientImg);
s = size(gradientImg);
idxe = sub2ind(s, ey, ex);

%% get different radii for votes
radius_range = radius_range(1):0.5:radius_range(2);

%% compute weights for votes using the phase-coding method
lnR = log(radius_range);

% Modified form of Log-coding from Eqn. 8 in [2]
lCalc = lnR - lnR(1);
rCalc = lnR(end) - lnR(1);
phi = ((lCalc/rCalc)*2*pi)-pi;

opca = exp(sqrt(-1)*phi);
w0 = opca./(2*pi*radius_range);

%% compute accumulator array

xcstep = floor(1e6/length(radius_range));
lene = length(ex);
[m, n] = size(img);
accuMatrix = zeros(m,n);


    for i = 1:xcstep:lene
        ex_chunk = ex(i:min(i+xcstep-1,lene));
        ey_chunk = ey(i:min(i+xcstep-1,lene));
        idxe_chunk = idxe(i:min(i+xcstep-1,lene));

        % Eqns. 10.3 & 10.4 from Machine Vision by E. R. Davies
        xc = bsxfun(@plus, ex_chunk, bsxfun(@times, -radius_range, gx(idxe_chunk)./gradientImg(idxe_chunk)));
        yc = bsxfun(@plus, ey_chunk, bsxfun(@times, -radius_range, gy(idxe_chunk)./gradientImg(idxe_chunk)));

        xc = round(xc);
        yc = round(yc);

        w = repmat(w0, size(xc, 1), 1);

        %% determine which edge pixel votes are within the image domain
        % which candidate center positions are inside the image rectangle
        [m, n] = size(img);
        inside = (xc >= 1) & (xc <= n) & (yc >= 1) & (yc < m);

        % keep rows that have at least one candidate position inside domain
        rows_to_keep = any(inside, 2);
        xc = xc(rows_to_keep,:);
        yc = yc(rows_to_keep,:);
        w = w(rows_to_keep,:);
        inside = inside(rows_to_keep,:);

        %% accumulate votes in the parameter plane
        xc = xc(inside); yc = yc(inside);
        accuMatrix = accuMatrix + accumarray([yc(:), xc(:)], w(inside), [m, n]);
        clear xc yc w; % clear tmp memory
    end
end

function [gx, gy, gradientImg] = getGradientImg(biImg)
    hy = -fspecial('sobel');
    hx = hy';

    gx = imfilter(biImg, hx, 'replicate','conv');
    gy = imfilter(biImg, hy, 'replicate','conv');

    gradientImg = hypot(gx, gy);
end

function img = getGrayImage(biImg)
    filtStd = 1.5;
    filtSize = ceil(filtStd*3); % filtSize = Smallest odd integer greater than filtStd*3
    gaussFilt = fspecial('gaussian',[filtSize filtSize],filtStd);
    img = imfilter(im2single(biImg),gaussFilt,'replicate');
end

function [Ex, Ey] = getEdgePixels(gradientImg)
    Gmax = max(gradientImg(:));
    edgeThresh = graythresh(gradientImg/Gmax); % Default EdgeThreshold
    t = Gmax * cast(edgeThresh,'like',gradientImg);
    [Ey, Ex] = find(gradientImg > t);
end

function centers = estCenters(accuMatrix)
%ESTCENTERS estimate centers for Hough Transformation using the accumulator
%array
    centers=[];
    accuMatrix = abs(accuMatrix);
   
    %% preprocess img median filter + detect peaks
    medFiltered = medfilt2(accuMatrix, [5 5]);
    medFiltered = imhmax(medFiltered, 0.2); %get maxima
    regionalMax = imregionalmax(medFiltered);
    s = regionprops(regionalMax, accuMatrix, 'weightedcentroid');
    
    %% put centers
    centers = reshape(cell2mat(struct2cell(s)), 2, length(s))';
    
    % remove NaNs
    [rNaN, ~] = find(isnan(centers));
    centers(rNaN,:)=[];
end

function estimated_r = estRadii(centers, accuMatrix, radius_range)
%ESTRADII estimate radius for hough tranformation using phase coding
%
%   parameters:
%       centers = nx2 array with n circle centers (n, 1) => Y coord, (n, 2)
%       => X coord
%       accuMatric = calculated accumulatorMatrix
%       radius_range = 2x1 array with (1) lower end and (2) upper end
%
%   output:
%       estimated_r = nx1 array estimated radius for each of the n circle
%       in the same order
%
    cenPhase = angle(accuMatrix(sub2ind(size(accuMatrix),round(centers(:,2)),round(centers(:,1)))));
    lnR = log(radius_range);
    % inverse of modified form of Log-coding from Eqn. 8 in [2]
    estimated_r = exp(((cenPhase + pi)/(2*pi)*(lnR(end) - lnR(1))) + lnR(1)); 
end