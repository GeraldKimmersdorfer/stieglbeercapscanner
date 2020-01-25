function [imgrotated] = magicRotation(img)
%MAGICROTATION Rotates the picture of the inner circle of a bottlecap so
%that the text is straight.
%   AUTHOR: Damian
%
%   parameters:
%       img: the logical image to be aligned
%
%   output:
%       img rotated so that the text is horizontally aligned

%% == PARAMETERS ==
IMG_SIZE_MAX_FINDROTATION = [60 60];

global logger;
logger.setFuncName(mfilename);

img = cropBinaryImage(img,true);
img_findrotation = scalefitImage(img, IMG_SIZE_MAX_FINDROTATION, false);

tstart = tic;
angle = findTextRotation(img_findrotation);
logger.debug(strcat("The text is probably by ", num2str(angle), "° rotated. Angle found in ", num2str(toc(tstart)), " seconds."));
tstart = tic;
imgrotated = mImRotate(img, angle);
logger.debug(strcat("Image successfully rotated in ", num2str(toc(tstart)), " seconds."));

logger.endOfFunction();
end