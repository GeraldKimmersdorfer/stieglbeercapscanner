function [centers,radii] = filterConnectingCircles(centers, radii)
%FILTERCONNECTINGCIRCLES Filters connecting and contained circles by always
%keeping the bigger one
%
%   @author Gerald Kimmersdorfer
    
    % Step2: If a circle is contained by a different circle delete the
    % contained one
    n = length(radii);
    selector = false(n,1);
    for i1 = 1:n
        if selector(i1) == 1
            continue
        end
        for i2 = 1:n
            if i1 == i2 || selector(i2) == 1
                continue
            end
            if isCircleInCircle(centers(i1,1), centers(i1,2), radii(i1),...
                    centers(i2,1), centers(i2,2), radii(i2))
                selector(i2) = true;
            end
        end
    end
    centers(selector,:) = [];
    radii(selector) = [];
    
    % Step3: If two circles intersect delete the smaller one
    n = length(radii);
    selector = false(n,1);
    for i1 = 1:n
        if selector(i1) == 1
            continue
        end
        for i2 = 1:n
            if i1 == i2 || selector(i2) == 1
                continue
            end
            [xis,~] = circcirc(centers(i1,1), centers(i1,2), radii(i1),...
                    centers(i2,1), centers(i2,2), radii(i2));
            if ~isnan(xis)
                if radii(i2) <= radii(i1)
                    selector(i2) = true;
                end
            end
        end
    end
    centers(selector,:) = [];
    radii(selector) = [];
end

