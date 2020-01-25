function [centers,radii] = filterUnboundCircles(centers,radii,sobelimg)
%FILTERUNBOUNDCIRCLES Filters circles that are not bound by white pixel in
%a certain area around the given binary image
%
%   @author: Gerald Kimmersdorfer

    % === PARAMETERS ===
    BOUNDRY_TO_INNERCIRCLE_RATIO = 2.7;% how many times is the bottlecap on a maximum bigger than the inner black circle
    IGNORE_TO_INNERCIRCLE_RATIO = 1.6; % how many times is the ignore-radius larger than the inner black circle (to ignore the code-eingeben letters)
    
    if isempty(radii)
        % abort if no circles
        return;
    end
 
    % extend sobelimg with padding so no index out of bounds can happen
    padding = ceil(max(radii) * ( BOUNDRY_TO_INNERCIRCLE_RATIO - 1 ));
    sobelsize = size(sobelimg);
    paddedsobel = false(sobelsize(1) + 2 * padding, sobelsize(2) + 2 * padding);
    paddedsobel(padding:(padding + sobelsize(1) - 1), padding:(padding + sobelsize(2) - 1)) = logical(sobelimg);
    sobelimg = paddedsobel;
    
    n = length(radii);
    selector = false(n,1);
    for i = 1:n
        outerRadi = radii(i) * BOUNDRY_TO_INNERCIRCLE_RATIO;
        ignoreRadi = radii(i) * IGNORE_TO_INNERCIRCLE_RATIO;
        
        imgOffset = uint16([centers(i,1) - outerRadi + padding , centers(i,2) - outerRadi + padding]);
        bc_image = sobelimg(...
                imgOffset(2) : imgOffset(2) + 2 * outerRadi, ...
                imgOffset(1) : imgOffset(1) + 2 * outerRadi);

        if ~isCircleBound(bc_image, ignoreRadi)
             selector(i) = true;
        end
    end
    centers(selector,:) = [];
    radii(selector) = [];
end

