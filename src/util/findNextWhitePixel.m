function output = findNextWhitePixel(image, ignoreRadius, maxRadius, startP, moveP)
%FINDNEXTWHITEPIXEL
%   Author: Levent
%   finds next white pixel starting from start P and ignoring everything
%   until out of ignore radius also considering a max radius for
%   performance.
%   
%   parameters:
%       image = sobel image
%       ignoreRadius = innerbound to be ignored
%       maxRadius = try to find pixel until this bound
%       startP = starting point
%       moveP = movement direction
%
%   output:
%       output = point of the next white pixel
   startP(1) = int32(startP(1));
   startP(2) = int32(startP(2));
   mr = int32(maxRadius);
   
   curP = startP;
   
   [maxX, maxY] = size(image);
   minX = 0;
   minY = 0;
   
   %% if there is no max radius use image size
   if(maxRadius ~= 0)
       maxX = min(curP(2)+mr,maxX);
       maxY = min(curP(1)+mr,maxY);
       minX = max(curP(2)-mr,0);
       minY = max(curP(1)-mr,0);
   end
   
   %% move and search
   while curP(2) > minX && curP(2) < maxX && curP(1) > minY && curP(1) < maxY
       if((norm(curP-startP) > ignoreRadius)) 
           
           y = curP(1);
           x = curP(2);
           
           pixel = image(x, y);
           if(pixel == 1) % White Pixel found %
              break; 
           end
       end
       curP = curP+moveP;
   end
   
   output=[curP(1), curP(2)];
end