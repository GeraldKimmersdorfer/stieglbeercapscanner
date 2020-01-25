function [caps,outimg] = stieglBottleCapScan(img,showPBar,showResult,debugOn)
%STIEGLBOTTLECAPSCAN reads an image and extracts and upload all of the
%stiegl-bottlecap codes
%
%   This is where all the magic starts. Make sure to set the correct
%   account-credentials for the upload to work.
%
%   @author: Gerald Kimmersdorfer
%
addpath('./ocr'); addpath('./util'); addpath('./lib');
global debug logger;

assert(nargin >= 1);
switch nargin
    case 1
        showPBar = true;
        showResult = false;
        debugOn = true;
    case 2
        showResult = false;
        debugOn = true;
    case 3
        debugOn = true;
end

% === PARAMETERS ===
DO_FREUNDESKREIS_UPLOAD = true;
STIEGL_FREUNDESKREIS_USERNAME = 'vortox10@hotmail.com';
STIEGL_FREUNDESKREIS_PASSWORD = '12345678';
debug = debugOn;

outimg = [];

logger = log4m.getLogger(strcat("log/", datestr(now, 'yyyy-mm-ddTHH-MM-SS/')));
logger.setLogLevel(logger.ALL);
logger.setCommandWindowLevel(logger.ERROR);
if debug
    logger.setCommandWindowLevel(logger.ALL);
end
logger.setFuncName(mfilename);

if showPBar
    wb = waitbar(0, 'Mögliche Kronkorken werden gesucht...');
end
logger.info("Code-Scan on img started!");
if debug
    logger.imglog(img, "inputImage");
end

unscaled_bw_image = rgb2gray(img);

caps = findBottleCaps(unscaled_bw_image);

wbmax = length(caps) + 3;
countstr = int2str(length(caps));
atleastOneSuccess = false;
for i = 1 : length(caps)
    pmsg = strcat("Code-Scan on bottlecap ", int2str(i), "/", countstr , " with ID '", caps{i}.id , "' started");
    logger.info(pmsg);
    if showPBar
    	waitbar((2 + i) / wbmax, wb, pmsg);
    end
    
    runtimer = tic;
    
    if caps{i}.error == BottlecapError.None
        %author: David
        caps{i}.imgTrimmed = getBottleCapImage(unscaled_bw_image, caps{i});
        
        %author: Gerald
        caps{i} = filterBottleCapCode(caps{i});
        
        if caps{i}.error == BottlecapError.None
            %author: Damian
            caps{i}.imgRotated = magicRotation(caps{i}.imgFiltered);

            %author: Gerald
            caps{i} = readCode(caps{i});
            
            if caps{i}.error == BottlecapError.None
                atleastOneSuccess = true;
            end
        end
        if debug
            img_log = caps{i}.debugInfo(true);
            logger.imglog(img_log, strcat("debug Info ", caps{i}.id));
        end
    end
    
    caps{i}.runtime = toc(runtimer);
end

if DO_FREUNDESKREIS_UPLOAD && atleastOneSuccess
    pmsg = "Trying to upload the codes...";
    logger.info(pmsg);
    if showPBar
        waitbar((wbmax - 1) / wbmax, wb, pmsg);
    end

    caps = uploadCodes(caps, STIEGL_FREUNDESKREIS_USERNAME, STIEGL_FREUNDESKREIS_PASSWORD);
end

if showPBar
    close(wb);
end
outimg = createOutputImage(img, caps);
if debug
    logger.imglog(outimg, "Final Output");
end
if showResult
    figure();
    imshow(outimg);
    title("Result of the code scan");
    uiwait(gcf);
end
end

