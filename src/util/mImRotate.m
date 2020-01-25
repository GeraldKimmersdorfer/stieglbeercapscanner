% Rotates a logical image
%   AUTHOR: Damian
%
% parameters:
%   image: logical image to be rotated
%   angle: rotation angle in degrees  
%
% output: the rotated logical image

function [rotated] = mImRotate(image, angle)
    [imSize, ~, ~] = size(image);
    angle = mod(angle, 360);
    
    % rotate the point [imSize;imSize] to find the new image size
    modAngle = mod(angle, 90);
    rotateMatrix = [cosd(modAngle), -sind(modAngle); sind(modAngle), cosd(modAngle)];
    
    maxCoords = rotateMatrix * [imSize;imSize];
    newImSize = ceil(max(maxCoords(1), maxCoords(2)));
    
    rotated = zeros(newImSize, newImSize, 'logical');
    
    center = [imSize/2; imSize/2];
    newCenter = [newImSize/2; newImSize/2];
   
    rotateMatrix = [cosd(-angle), -sind(-angle); sind(-angle), cosd(-angle)];
    
    % iterate over all pixels of the new image
    for x = 1:newImSize
        for y = 1:newImSize
            % rotate pos around the center of the image
            pos = [y;x];
            coords = rotateMatrix * (pos - newCenter);
            coords = coords + center;
            
            coords = ceil(coords);
            
            % take the corresponding point from the original image
            if coords > 0 & coords < imSize
                rotated(y, x) = image(coords(1),coords(2));
            else     
                rotated(y, x) = 0;
            end
        end
    end
end