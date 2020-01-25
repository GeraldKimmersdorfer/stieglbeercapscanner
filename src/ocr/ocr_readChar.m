function [out,likelyhood] = ocr_readChar(comp, templates)
%OCR_READCHAR Correlates a component with the learned letter masks and
%picks the most likely one
%
%   This function correlates one Component-Image with all the learned Letters
%   saved in LEARNED_TEMPLATES.mat. If the best letter mask correlates better than
%   MIN_CHAR_CORRELATION the corresponding char will be returned together
%   with the correlation-factor (likelyhood)
%
%   @author: Gerald Kimmersdorfer, 01326608

% == PARTAMETERS ==
MIN_CHAR_CORRELATION = 0.1;

% The training mode can be enabled here! If activated the program will ask
% for every letter it finds which char it actually stands for. The masks
% will be added another layer with those information and the overall
% ocr-process will get better.
% ATTENTION: This feature is NOT part of the assignment. The
% LEARNED_TEMPLATES.mat already contains the necessary mask-data build by
% the images in the "learning set"-folder
TRAINING_MODE = false;

likelyhood = 0;
out = '';
mask = binaryNearestNeighbourScale(comp.image, size(templates(1).mask));
% mask = imresize(comp.image, size(templates(1).mask));

if TRAINING_MODE
    out = ocr_trainLetter(mask);
    if ~isempty(out)
        likelyhood = 1;
    end
else
    bestfit = [];
    bestcorr = 0;
    for i2 = 1:length(templates)
        currentcorr = templates(i2).correlate(mask);
        if currentcorr > bestcorr
            bestcorr = currentcorr;
            bestfit = templates(i2);
        end
    end
    if ~isempty(bestfit) && bestcorr >= MIN_CHAR_CORRELATION
        out = bestfit.letter;
        likelyhood = bestcorr;
    end
end

end

