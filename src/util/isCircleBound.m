function res = isCircleBound(img,ignoreRadius)
%ISCIRCLEBOUND Returns true if in 8 different angles from the middle point
%in a given edge picture there are white dots in at least 4 angles.
%
%   if former description is true it most likely means that the center is bound 
%   by a different circle. WARNING: JUST WORKS WITH SQUARE IMAGES
%   @author: Gerald Kimmersdorfer

res = false;

% === PARAMETERS ===
% all the directions in which to look
dir = [1,0 ; 1,1 ; 0,1 ; -1,1 ; -1,0 ; -1,-1 ; 0,-1 ; 1,-1];
MIN_BOUNDS = 5; % defines how many angles have to be positive

dirn = length(dir);
imgsize = size(img);
center = imgsize ./ 2;

img = logical(img);

dirnorm = bsxfun(@rdivide,dir,sqrt(sum(dir.^2,2))); % calculates norm for every row
startingOffset = dirnorm * ignoreRadius; 
startingPoints = int16(repmat(center, dirn, 1) + startingOffset);

countBordered = 0;
for i = 1:dirn
    cdir = int16(dir(i,:));
    point = startingPoints(i,:);
    while (point(1) > 0 && point(1) <= imgsize(1)) && ...
            (point(2) > 0 && point(2) <= imgsize(2))
        
        if img(point(1),point(2)) == true
            countBordered = countBordered + 1;
            break;
        end
        point = point + cdir;
    end
end

if countBordered >= MIN_BOUNDS
    res = true;
end
end

