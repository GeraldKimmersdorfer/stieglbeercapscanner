
% STIEGLSCANSERVER
% A Listening-Server that listens to the webpage SERVER_URL for new images
% to scan. The Server-Script has to return the download link to the new
% image or an empty string if there is no new image to scan.
%
% @author: GERALD KIMMERSDORFER

addpath('./lib');

SERVER_URL = "http://stieglscan.beaserein.com/?action=getNextImage";

disp(">  ___ _   _          _     ___                  ___                      ");
disp("> / __| |_(_)___ __ _| |___/ __| __ __ _ _ _ ___/ __| ___ _ ___ _____ _ _ ");
disp("> \__ \  _| / -_) _` | |___\__ \/ _/ _` | ' \___\__ \/ -_) '_\ V / -_) '_|");
disp("> |___/\__|_\___\__, |_|   |___/\__\__,_|_||_|  |___/\___|_|  \_/\___|_|  ");
disp(">               |___/                                                     ");

disp("> New Listening server started! Exit by pressing Str+C while in the command window.");

requestCount = 0;
requestOptions = weboptions("Timeout", 10);
while(true)
    response = webread(SERVER_URL, requestOptions);
    requestCount = requestCount + 1;
    
    % response contains download url
    if response ~= "" 
        warning('off', 'MATLAB:imagesci:jpg:libraryMessage');
        disp(strcat("> New image received '", response, "', I'm gonna try to download it."));
        alreadyToldAboutUpload = false;
        while 1
            img = webread(response);
            if ~contains(lastwarn, 'Premature end') 
                % file was successfully uploaded
                break;
            else
                lastwarn('');
                if ~alreadyToldAboutUpload
                    disp("> Waiting for upload to be finished ...");
                    alreadyToldAboutUpload = true;
                end
                pause(3);
            end
        end
        warning('on', 'MATLAB:imagesci:jpg:libraryMessage');

        disp(strcat("> New image fetched with size ", mat2str(size(img)), " starting the code-scan now."));
        
        stieglBottleCapScan(img, true, true);
        
        disp("> Finished the code scan, listening for new uploaded pictures again. Exit by pressing Str+C while in the command window."); 
    end
    
    [CH, ~] = getkeywait(1);
    if CH == 0
        disp("> Error occured in getkeywait-function. Process is being terminated.");
    elseif CH ~= -1
        disp(strcat("> Okay, I'm shutting down now. J4I: I sent ", num2str(requestCount), " requests to the server. Bye..."));
        break;
    end
end