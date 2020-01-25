function ret = readCode(cap)
%READCODE Reads the bottlecap code and attaches it to the given
%bottlecap-object (if possible)
%
%   Gets a bottlecap object where the rotated bottlecap code is stored.
%   Due to the implementation it is possible that this image is also
%   rotated by 90°, 180° or 270°. Therefore this function tries to read the
%   code in all 4 directions and picks the one with the highest accuarcy.
%
%   @author: Gerald KIMMERSDORFER, 01326608

global logger debug;
logger.setFuncName(mfilename);

%% calls the function ocr_readCode with an image in every possible rotation
img = cap.imgRotated;
results = cell(1,4);
for i = 1:length(results)
    [code,likelyhood,failure] = ocr_readCode(img);
    if ~isempty(failure)
        results{i} = {false, failure};
    else
        results{i} = {true, code, likelyhood, img};
    end
    img = rot90(img);
end

%% iterates through the results and picks the best option
bestfit = {false, '', 0, []};
for i = 1:length(results)
    if results{i}{1}
        if results{i}{3} > bestfit{3}
            bestfit = results{i};
            rotation = 90 * (i - 1);
        end
    end
end
if debug
    msg = "possible codes are: ";
    for i = 1:length(results)
        if results{i}{1}
            msg = strcat(msg, "['", results{i}{2}, "', ", int2str(round(results{i}{3}*100)), "%],");
        else
            msg = strcat(msg, "['", results{i}{2}, "'],");
        end
    end
    logger.debug(msg);
end
%% check if an option is sufficient enough and return the result
if ~bestfit{1}
    logger.error("code could not be successfully read in any direction");
    cap = cap.setError(BottlecapError.Recognition, 'ocr-error: could not read code');
else
    cap.imgOCR = bestfit{4};
    cap.code = bestfit{2};
    logger.info(strcat("Successfully read code '", cap.code, "' with a likelyhood of ", int2str(round(bestfit{3}*100)), "%", ...
    ", the image used was rotated by ", int2str(rotation), "° to the left"));
end

ret = cap;

logger.endOfFunction();
end

