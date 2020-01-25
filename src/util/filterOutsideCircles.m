function [centers,radii] = filterOutsideCircles(centers, radii, img)
%FILTERCONNECTINGCIRCLES returns arrays without circles that are partly
%outside the picture
%
%   @author Gerald Kimmersdorfer
    
    n = length(radii);
    selector = false(n,1);
    imgsize = size(img);
    for i1 = 1:n
        if centers(i1,1) - radii(i1) < 0 || centers(i1,1) + radii(i1) > imgsize(2) || ...
                centers(i1,2) - radii(i1) < 0 || centers(i1,2) + radii(i1) > imgsize(1)
            selector(i1) = true;
        end
    end
    centers(selector,:) = [];
    radii(selector) = [];
    
end

