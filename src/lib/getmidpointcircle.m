function [xc, yc] = getmidpointcircle(x0, y0, radius)
%% GETMIDPOINTCIRCLE return the x,y pixel coordinates of a circle
%
% [x y] = GETMIDPOINTCIRCLE(x0, y0, radius) returns the pixel coordinates
% of the circle centered at pixel position [x0 y0] and of the given integer
% radius. The mid-point circle algorithm is used for computation
% (http://en.wikipedia.org/wiki/Midpoint_circle_algorithm).
%
% This function is aimed at image processing applications, where the
% integer pixel coordinates matter, and for which one pixel cannot be
% missed or duplicated. In that view, using rounded trigonometric
% coordinates generated using cosine calls are inadequate. The mid-point
% circle algorithm is the answer. 
%
% Accent is made on performance. We compute in advance the number of point
% that will be generated by the algorithm, to pre-allocate the coordinates
% arrays. I have tried to do this using a MATLAB class implementing the
% iterator pattern, to avoid computing the number of points in advance and
% still be able to iterate over circle points. However, it turned out that
% repeated function calls is extremely expansive, and the class version of
% this function is approximately 1000 times slower. With this function, you
% can get the pixel coordinates of a circle of radius 1000 in 0.16 ms, and
% this time will scale linearly with increasing radius (e.g. it takes 
% 0.16 s for a radius of 1 million).
%
% Also, this functions ensure that sorted coordinates are returned. The
% mid-point algorithm normally generates a point for the 8 circles octants
% in one iteration. If they are put in an array in that order, the [x y]
% points will jump from one octant to another. Here, we ensure that they
% are returned in order, starting from the top point, and going clockwise.
%
% EXAMPLE
%
% n_circles = 20;
% color_length = 100;
% image_size = 128;
% max_radius = 20;
% 
% I = zeros(image_size, image_size, 3, 'uint8');
% colors = hsv(color_length);
% 
% for i = 1 : n_circles
%     
%     x0 = round( image_size * rand);
%     y0 = round( image_size * rand);
%     radius = round( max_radius * rand );
%     
%     [x y] = getmidpointcircle(x0, y0, radius);
%     
%     index = 1 ;
%     for j = 1 : numel(x)
%         xp = x(j);
%         yp = y(j);
%         
%         if ( xp < 1 || yp < 1 || xp > image_size || yp > image_size )
%             continue
%         end
%         I(xp, yp, :) = round( 255 * colors(index, :) );
%         index = index + 1;
%         if index > color_length
%             index = 1;
%         end
%     end
%     
% end
% 
% imshow(I, []);
% 
%
% Jean-Yves Tinevez <jeanyves.tinevez@gmail.com> - Nov 2011 - Feb 2012
    % Compute first the number of points
     octant_size = floor((sqrt(2)*(radius-1)+4)/2);
     n_points = 8 * octant_size;
     
     % Iterate a second time, and this time retrieve coordinates.
     % We "zig-zag" through indices, so that we reconstruct a continuous
     % set of of x,y coordinates, starting from the top of the circle.
     xc = NaN(n_points, 1);
     yc = NaN(n_points, 1);
     
     x = 0;
     y = radius;
     f = 1 - radius;
     dx = 1;
     dy = - 2 * radius;
     
     % Store
     
     % 1 octant
     xc(1) = x0 + x;
     yc(1) = y0 + y;
     
    % 2nd octant 
     xc(8 * octant_size) = x0 - x;
     yc(8 * octant_size) = y0 + y;
     
     % 3rd octant 
     xc(4 * octant_size) = x0 + x;
     yc(4 * octant_size) = y0 - y;
     
     % 4th octant 
     xc(4 * octant_size + 1) = x0 - x;
     yc(4 * octant_size + 1) = y0 - y;
     
     % 5th octant 
     xc(2 * octant_size) = x0 + y;
     yc(2 * octant_size) = y0 + x;
     
     % 6th octant 
     xc(6 * octant_size + 1) = x0 - y;
     yc(6 * octant_size + 1) = y0 + x;
     
     % 7th octant 
     xc(2 * octant_size + 1) = x0 + y;
     yc(2 * octant_size + 1) = y0 - x;
     
     % 8th octant 
     xc(6 * octant_size) = x0 - y;
     yc(6 * octant_size) = y0 - x;
     
     
     for i = 2 : n_points/8
         
         % We update x & y
         if f > 0
             y = y - 1;
             dy = dy + 2;
             f = f + dy;
         end
         x = x + 1;
         dx = dx + 2;
         f = f + dx;
         
         % 1 octant
         xc(i) = x0 + x;
         yc(i) = y0 + y;
         
         % 2nd octant
         xc(8 * octant_size - i + 1) = x0 - x;
         yc(8 * octant_size - i + 1) = y0 + y;
         
         % 3rd octant
         xc(4 * octant_size - i + 1) = x0 + x;
         yc(4 * octant_size - i + 1) = y0 - y;
         
         % 4th octant
         xc(4 * octant_size + i) = x0 - x;
         yc(4 * octant_size + i) = y0 - y;
         
         % 5th octant
         xc(2 * octant_size - i + 1) = x0 + y;
         yc(2 * octant_size - i + 1) = y0 + x;
         
         % 6th octant
         xc(6 * octant_size + i) = x0 - y;
         yc(6 * octant_size + i) = y0 + x;
         
         % 7th octant
         xc(2 * octant_size + i) = x0 + y;
         yc(2 * octant_size + i) = y0 - x;
         
         % 8th octant
         xc(6 * octant_size - i + 1) = x0 - y;
         yc(6 * octant_size - i + 1) = y0 - x;
         
     end
     
     % adaption by Gerald Kimmersdorfer return rounded integers:
     xc = uint16(round(xc));
     yc = uint16(round(yc));
     
end