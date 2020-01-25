function threshold = otsuThresholdVal(grayImage)
%OTSUTHRESHOLDVAL Calculates the best threshold value based on the histogram
%of the input image.
%
%   Calculates an optimal threshold value based on the histogram of the
%   image. The whole idea is to loop through all thresholds and search for
%   the one that minimizes the intra-class variance. This is usually
%   the case in between peaks of the histogram. This function replaces
%   graythresh of the matlab image processing library
%   
%   (for more information on the algorithm see:
%   https://www.youtube.com/watch?v=mnmjZOLjoBA)
%
%   or have a look at the original paper by Otsu:
%   N. Otsu, "A Threshold Selection Method from Gray-Level Histograms," in
%   IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
%   pp. 62-66, Jan. 1979.
%
%   @author: Gerald Kimmersdorfer

% Usually 255 with an 8-bit image, but who knows :D
maxBrightness = double(intmax(class(grayImage)));

% calculates the area of the image (amount of pixel):
area = numel(grayImage);

% histcounts groups the pixels with the same color (graytone) into buckets
% and returns an array filled with the amount of appearances of each color
% tone. The function basically does the same as histogram, but it doesnt
% plot the result.
stats = histcounts(grayImage, maxBrightness+1);

sumB = 0;
% initialize class probability 
w0t = 0;
% max contains the current maximum of inter-class variance
maxsigb2 = double(0);
myt = dot(double(0:maxBrightness), stats);

% loop through all of the intensity levels
for i = 1:(maxBrightness + 1)
    w1t = area - w0t;
    % avoid division by zero error:
    if w0t > 0 && w1t > 0   
        sumA = myt - sumB;
        % calculate means
        my1 = sumA / w1t;
        my0 = sumB / w0t;
        % calculate inter-class variance
        tmp = my0 - my1;
        sigb2 = w0t * w1t * tmp * tmp;
        if ( sigb2 >= maxsigb2 )
            threshold = i;
            maxsigb2 = sigb2;
        end
    end
    w0t = w0t + stats(i);
    sumB = sumB + (i-1) * stats(i);
end
end

