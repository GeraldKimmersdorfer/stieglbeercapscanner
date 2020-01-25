function thresholds = simpleThresholds(grayImage)
%SIMPLETHRESHOLDS Calculates some simple threshold values
%
%   This function returns an array with two simply calculated thresholds
%
%   @author: Gerald Kimmersdorfer

    % === PARAMETERS ===
    OFFSET_THRESHOLD_VALUE = 45;
    
    mini = min(min(grayImage));
    maxi = max(max(grayImage));
    % mean threshold between the brightest and the darkest spot
    thresholds(1) = (maxi-mini)/2 + mini;
    % simple offset from the brightest spot
    thresholds(2) = maxi - OFFSET_THRESHOLD_VALUE;
end

