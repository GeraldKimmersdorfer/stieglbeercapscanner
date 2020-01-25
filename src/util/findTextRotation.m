% Calculates the angle of rotation of the text
%   AUTHOR: Damian
function [angle] = findTextRotation(image)
    
    numWhites = zeros(180,1);

    minWhite = 1/0;
    minAngle = 0;
    % find the angle for which the number of white lines is minimal
    for angle = 1:180
        numWhite = countWhiteLines(image, angle);
        if(numWhite < minWhite) 
            minWhite = numWhite;
            minAngle = angle;
        end
        numWhites(angle) = numWhite;
    end
    
    minAngle = mod(minAngle - 90, 180);
    
    optAngle = 0;
    minWhite = 1/0;
    
    % find the angle for which the number of white lines is minimal within
    % minAngle-115 and minAngle-65
    for angle = -25:25
        numWhite = numWhites(1 + mod(minAngle + angle, 180));
        if(numWhite < minWhite) 
            minWhite = numWhite;
            optAngle = minAngle + angle;
       end
    end
    
    angle = optAngle;
end