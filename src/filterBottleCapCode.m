function ret = filterBottleCapCode(cap)
%BINARIZEBOTTLECAPIMAGE Calculates the threshold and filtered image of a
%given bottlecap
%   Converts given bottle-cap image (stored in bottlecap.imgTrimmed) into a
%   binary image using the otsu algorithm and saves it in bottlecap.imgBinary
%   and also filters the components of the picture by looking
%   for LETTER_COUNT similar sized components and saves the image with
%   just those components in bottlecap.imgFiltered.
%
%   @author: Gerald Kimmersdorfer, 01326608

global logger;
logger.setFuncName(mfilename);

% == PARAMETERS ==
IMG_SIZE_MAX = [180 180];
THRESHOLD_BOXSIZE_FACTOR = 0.3;
DIFFERENT_THRESHOLD_FILTER = 2;
ADAPTIVE_THRESHOLD_SENSITIVITY = 0.5;

img = scalefitImage(cap.imgTrimmed, IMG_SIZE_MAX, false);

% Threshold-Filter anhand eines Samples in der Mitte
imgsize = size(img);
threshbox = imgsize * THRESHOLD_BOXSIZE_FACTOR;
threshimg = img(round(imgsize(1)/2-threshbox(1)/2):round(imgsize(1)/2+threshbox(1)/2), ...
    round(imgsize(2)/2-threshbox(2)/2):round(imgsize(2)/2+threshbox(2)/2));
cap.imgOtsu = threshimg;  % for debugging purposes also saved in caps-object

foundLetters = false;
% Tries different threshold techniques and stops if one is successfull
for i = 1:DIFFERENT_THRESHOLD_FILTER
    switch i
        case 1
            threshName = 'GrayThresh';
            binImage = imbinarize(img, graythresh(threshimg));
        case 2
            threshName = 'Adaptive';
            T = adaptthresh(img, ADAPTIVE_THRESHOLD_SENSITIVITY, 'ForegroundPolarity', 'bright');
            binImage = imbinarize(img, T);
        otherwise
            error("this threshold is not implemented");
    end
    
    filtered = letterFiltering(binImage);
    
    if ~isempty(filtered)
        foundLetters = true;
        cap.imgFiltered = filtered;
        cap.imgBinary = binImage;
        logger.debug(strcat("used ", threshName, "-Method for binarizing the image"));
        break;
    end
end

if ~foundLetters
    msg = "could not filter enough components in any of the threshold-images, problematic image is being logged";
    logger.error(msg);
    logger.imglog(img, strcat("problematic Image", cap.id));
    cap = cap.setError(BottlecapError.Seperation, msg);
end

ret = cap;

logger.endOfFunction();
end

