function letters = letterExtraction(logimg)
%LETTEREXTRACTION tries to extract a certain amount of similar sized
%components out of a picture
%
%   This function returns an array of the letter components inside the
%   given logimg, if not enough letters could be found it returns empty
%   arrays.
%
%   The function determines connected letters with the following steps:
%   1.) the area (amount of pixels) need to be of a certain value
%   2.) the aspect ratio of the component needs to be inside certain bounds
%   3.) it looks for exactly LETTER_COUNT components that are just
%   relatively by the SIZE_TOLERANCE different in size
%
%   @author: Gerald Kimmersdorfer

letters = [];

% == PARAMETERS FOR LETTER EXTRACTION ==
LETTER_MIN_AREA = 20;   % minimal amount of pixel of letter
SIZE_TOLERANCE = [0.2 0.7];
LETTER_ASPECTRATIO_BOUNDS = [0.4 1.1];
LETTER_COUNT = 9;

[~,comp] = componentExtraction(logimg);

% Preselection with Min-Area and AspectRatio
n = length(comp);
deleteflags = false(n,1);
for i1 = 1:n
    aspectratio = comp(i1).getAspectRatio();
    if comp(i1).area < LETTER_MIN_AREA || ...
            aspectratio > LETTER_ASPECTRATIO_BOUNDS(2) || aspectratio < LETTER_ASPECTRATIO_BOUNDS(1)
        comp(i1).tag = false;
        deleteflags(i1) = true;
    end
end

% Component.debugInfo(comp);
comp(deleteflags) = [];

n = length(comp);
if n < LETTER_COUNT
    return;
end

% Search for LETTER_COUNT similar sized components:
similar = [];
for i1 = 1:n
    tolerance = comp(i1).size .* SIZE_TOLERANCE;
    similar = comp(i1);
    for i2 = 1:n
        if i1 == i2 , continue; end
        insidebounds = abs(comp(i1).size - comp(i2).size) < tolerance;
        if sum(insidebounds) == 2
            similar = [similar comp(i2)];
        end
    end
    if length(similar) == LETTER_COUNT
        break
    end
end

%Component.debugInfo(similar);

if length(similar) == LETTER_COUNT
    letters = similar;
end

end

