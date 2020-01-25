function [filteredImage] = letterFiltering(logimg)
%LETTERFILTERING tries to extract a certain amount of similar sized
%components out of a picture
%
%   Letter filtering expects an logical image as input. It applies a few
%   different filters to remove:
%   1.) noise (small components)
%   2.) border-artifacts (components that are on the edge of the circle
%   3.) too large components
%   
%   if at the end of this process there are still at least 9 similar sized
%   components left (probably the letters) then this function returns the
%   filteredImage, otherwise an empty array.
%   This function is similar to letterExtraction it does some more
%   prefiltering though and is more generous on the parameters. (since the
%   letters are not correctly rotated yet) Also if there are more than 9 of
%   those components that is still okay. (it hopefully gets filtered out
%   later at the letterExtraction step)
%
%   @author: Gerald Kimmersdorfer

%% == INITIALIZATION
imgsize = size(logimg);
filteredImage = [];

%% == PARAMETERS ==
LETTER_ASPECTRATIO_BOUNDS = [0.4 2.5];
LETTER_MINSIZE = [15 15];
LETTER_MAXSIZE = [0.2 0.2] .* imgsize;
LETTER_MIN_COUNT = 9;

%% extract components from logical image
[L,comp] = componentExtraction(logimg);
n = length(comp);
removeids = [];

%% Mark all components that touch the outer border of the circle as invalid
r = min(imgsize) / 2 - 1;
center = imgsize / 2;
% get all points on circle
[cx,cy] = getmidpointcircle(center(2), center(1), r);
pointCount = numel(cx);
hitobjects = zeros(pointCount,1);
for j = 1 : numel(cx)
    xp = cx(j); yp = cy(j);
    if ~( xp < 1 || yp < 1 || xp > imgsize(2) || yp > imgsize(1) )
        hitobjects(j) = L(yp,xp);
    end
end
% delete duplicate values
hitobjects = unique(hitobjects);
% delete zeros
hitobjects(hitobjects == 0) = [];

%iterate through all of the components and set the tag to false if its id
%is inside the hitobjects array
removeflags = false(n,1);
for oid = hitobjects'
    for i = 1:n
        if comp(i).id == oid
            removeflags(i) = true;
            comp(i).tag = false;
            removeids = [removeids comp(i).id];
            break;
        end
    end
end
%Component.debugInfo(comp);
comp(removeflags) = [];


%% Preselection with Min-Size, Max-Size and AspectRatio
n = length(comp);
removeflags = false(n,1);
for i1 = 1:n
    aspectratio = comp(i1).getAspectRatio();
    if (sum(comp(i1).size < LETTER_MINSIZE) > 1) || ...
            aspectratio > LETTER_ASPECTRATIO_BOUNDS(2) || aspectratio < LETTER_ASPECTRATIO_BOUNDS(1) || ...
            sum(comp(i1).size > LETTER_MAXSIZE) > 1
        removeflags(i1) = true;
        comp(i1).tag = false;
        removeids = [removeids comp(i1).id];
    end
end
%Component.debugInfo(comp);
comp(removeflags) = [];

%Component.debugInfo(comp);
%% if there are not enough components left return empty array
n = length(comp);
if n < LETTER_MIN_COUNT
    return;
end

%% if there are still enough components left build the filtered return image
% by setting all ids in Matrix L which contain deleted components to zero
filteredImage = L;
for remId = removeids
    filteredImage(filteredImage==remId) = 0;
end
filteredImage = filteredImage > 0;

end

