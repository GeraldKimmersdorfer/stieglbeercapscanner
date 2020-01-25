% Counts the number of lines with white parts
%   AUTHOR: Damian
function [numWhite] = countWhiteLines(image, angle)

    [imSize, ~, ~] = size(image);
    angle = mod(angle, 360);
    
    modAngle = mod(angle, 90);
    rotateMatrix = [cosd(modAngle), -sind(modAngle); sind(modAngle), cosd(modAngle)];
    
    % rotate the point [imSize;imSize] to find the new image size
    maxCoords = rotateMatrix * [imSize;imSize];
    newImSize = ceil(max(maxCoords(1), maxCoords(2)));
    
    center = [imSize/2; imSize/2];
    newCenter = [newImSize/2; newImSize/2];
   
    rotateMatrix = [cosd(-angle), -sind(-angle); sind(-angle), cosd(-angle)];
    
    numEmptyRows = 0;
    
    for x = 1:newImSize
        num = 0;
        
        for y = 1:newImSize
            % rotate pos around the center of the image
            pos = [y;x];
            coords = rotateMatrix * (pos - newCenter);
            coords = coords + center;
            
            coords = ceil(coords);
            
            if coords > 0 & coords < imSize
                if(image(coords(1),coords(2))) 
                    num = num + 1;
                end
            end
        end
        
        if num < imSize/25 % threshold to ignore outliers
            numEmptyRows = numEmptyRows + 1;
        end
    end
    
    numWhite = newImSize - numEmptyRows;
end