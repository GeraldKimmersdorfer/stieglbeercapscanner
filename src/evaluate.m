% EVALUATE-Script
% Führt die Kronkorkenerkennung an allen Bildern eines gewünschten Ordners
% aus und gibt eine Statistik über den Erfolg auf diesem Testdatensatz aus.
%
% Anmerkung: Bilder im Testdatensatz müssen am Ende des Dateinamens in
% Klammer die Anzahl an ersichtlichen Stiegl-Kronkorken stehen haben.
% z.B. 'Bild 01 (5).jpg' ... falls 5 Kronkorken ersichtlich sind
%
% @author: GERALD KIMMERSDORFER

% === PARAMETERS ===
AUTO_LOAD = false;
IMAGE_FILES_EXTENSION = '.jpg';
EVAL_IMG_OUTPUT_FOLDER = 'log\eval\';
DEBUG_SCAN = false;

if (~AUTO_LOAD)
    directory = uigetdir(matlabroot,'Select path with Test-Jpges');
    if isempty(directory) || ~directory
        return
    end
else
    directory = '..\testbilder\testing set';
end

files = dir(strcat(strcat(directory,'\'),'*',IMAGE_FILES_EXTENSION));
n = length(files);
disp(strcat("> ",num2str(n)," pictures found in source path"));

st_foundCaps = zeros(n,1);  % contains how many bottlecaps have been found
st_totalCaps = zeros(n,1);
st_correctSeparation = zeros(n,1);  % contains how many bottlecaps could have been seperated (filtered, if not usually threshold failure)
st_couldRead = zeros(n,1);  % contains how many bottlecaps could have been read (also incorrectly)
st_correctRead = zeros(n,1); % contains how many bottlecaps could have been correctly read (server will return code already used)
st_timeToProcessAll = zeros(n,1);
st_timeToProcessSeparated = zeros(n,1);

for i = 1:n
    filename = files(i).name;
    
    disp(strcat("> starting with picture '", filename, "' (", int2str(i), " out of ", int2str(n), ")"));
    
    bracketStart = strfind(filename, '(');
    bracketEnd = strfind(filename, ')');
    if isempty(bracketStart) || isempty(bracketEnd)
        disp("> I'm skipping this picture since obviously the amount of beercaps is not stated in the filename.");
        continue;
    end
    bracketStart = bracketStart(length(bracketStart)) + 1;
    bracketEnd = bracketEnd(length(bracketEnd)) - 1;
    if bracketStart > bracketEnd
        disp("> I'm skipping this picture since the amount in the filename is not stated correctly.");
        continue;
    end
    countCaps = filename(bracketStart:bracketEnd);
    [countCaps, status] = str2num(countCaps);
    if ~status
        disp("> I'm skipping this picture since i can't interprete the amount correctly.");
        continue;
    end

    img = imread(strcat(files(i).folder, '\', filename));
    try
        [caps,outimg] = stieglBottleCapScan(img, false, false, DEBUG_SCAN);
    catch
        disp("> I'm skipping this picture cause an error occured while trying to fetch codes");
        continue
    end
    
    imwrite(outimg, strcat(EVAL_IMG_OUTPUT_FOLDER, filename));

    st_totalCaps(i) = countCaps;
    if length(caps) > countCaps
        st_foundCaps(i) = countCaps;
    else
        st_foundCaps(i) = length(caps);
    end
    for i2 = 1:length(caps)
        cap = caps{i2};
        st_timeToProcessAll(i) = st_timeToProcessAll(i) + cap.runtime;
        if cap.error == BottlecapError.None || cap.error == BottlecapError.AlreadyUsed
            st_correctRead(i) = st_correctRead(i) + 1;
        end
        if cap.error == BottlecapError.None || cap.error == BottlecapError.AlreadyUsed || ...
                cap.error == BottlecapError.Upload
            st_couldRead(i) = st_couldRead(i) + 1;
        end
        if cap.error ~= BottlecapError.Seperation
            st_correctSeparation(i) = st_correctSeparation(i) + 1;
            st_timeToProcessSeparated(i) = st_timeToProcessSeparated(i) + cap.runtime;
        end
    end
end

st_timeToProcessOne = sum(st_timeToProcessAll) / sum(st_foundCaps);
st_timeToProcessOneSuccessfull = sum(st_timeToProcessSeparated) / sum(st_correctSeparation);
st_foundCapsProz = sum(st_foundCaps) / sum(st_totalCaps);
st_corSeparatedProz = sum(st_correctSeparation) / sum(st_foundCaps);
st_couldReadProz = sum(st_couldRead) / sum(st_correctSeparation);
st_corReadProz = sum(st_correctRead) / sum(st_couldRead);

disp("> all images are processed, the statistic is as follows:");
fprintf("\tFound Bottlecaps: %0.2f%% (%i out of %i)\n", st_foundCapsProz * 100, sum(st_foundCaps), sum(st_totalCaps));
fprintf("\tCorrectly seperated: %0.2f%% (%i out of %i)\n", st_corSeparatedProz * 100, sum(st_correctSeparation), sum(st_foundCaps));
fprintf("\tCould read: %0.2f%% (%i out of %i)\n", st_couldReadProz * 100, sum(st_couldRead), sum(st_correctSeparation));
fprintf("\tCorrectly read: %0.2f%% (%i out of %i)\n", st_corReadProz * 100, sum(st_correctRead), sum(st_couldRead));
fprintf("\tAverage runtime for one cap: %0.3fs\n", st_timeToProcessOne);
fprintf("\tAverage runtime for one seperated cap: %0.3fs\n", st_timeToProcessOneSuccessfull);

