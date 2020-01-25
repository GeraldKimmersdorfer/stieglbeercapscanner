function [bottlecaps] = findOuterBounds(image, centers, radii)
%FINDOUTERBOUNDS
%   Author: Levent
%   tries to find outer circle(=bottlecap) using a simple "line casting"
%   method
%   we know the center of the inner circle and its radii so we put a
%   tolerance zone to ignore noise in this zone, after that we cast 4 lines
%   in each direction(up, down, left, right) starting from the center. We
%   follow the line until we hit a boundary and assume it to be the
%   bottlecap.
%   For performance we calculate an average Radius on the fly to make sure
%   all bottlecaps are about the same size (would make no sense if they
%   weren't)
%
%   parameters:
%       image = sobel image
%       centers = center points of inner circle
%       radii = radii of center points
%
%   output:
%       bottlecaps = nx1 array of Bottlecap objects => see Bottlecap.m
    averageRadius = 0;
    len = length(radii);
    bottlecaps=Bottlecap.empty;
    
    for n=1 : len
       radius = radii(n,1)*1.25;
       startP = [centers(n, 1), centers(n, 2)];
       
       %% set max radius after second run to have a max bound if something goes wrong
       maxRadius = 0;
       if(averageRadius~=0) 
        maxRadius = averageRadius*1.2;
       end
       
       %% cast the line in each direction and get until the next white pixel considering an min and max threshold
       upperX = findNextWhitePixel(image, radius, maxRadius, startP, [0,1]);
       lowerX = findNextWhitePixel(image, radius, maxRadius, startP, [0,-1]);
       upperY = findNextWhitePixel(image, radius, maxRadius, startP, [1,0]);
       lowerY = findNextWhitePixel(image, radius, maxRadius, startP, [-1,0]);
       
       %% calculate new center point + radius for the outerbound
       newY = lowerY(1) + (upperY(1)-lowerY(1))/2;
       newX = lowerX(2) + (upperX(2)-lowerX(2))/2;
       
       newP = [newY, newX];
       newRadius = max(norm(newP-upperY), norm(newP-upperX));
       
       b = Bottlecap(startP, radii(n, 1));
       b.outerCenter = newP;
       b.outerRadius = newRadius;
       bottlecaps(n) = b;
       
       %% calc average radius for performance reasons
       averageRadius = mean(Bottlecap.map(bottlecaps, Bottlecap.orMaper, 1));
    end
 end