%% STIEGL-BOTTLECAP-CODE-SCANNER
% This is the entrypoint to our program. As soon as you click run you will
% be asked to select an image to process.
%
% As soon as you start a window will show you through the progress through
% the process though.
%
% authors: Dag Leven, Gaal Martin, Jäger Damian, Kimmersdorfer Gerald,
% Kyselka David 
%
% Made with love for EDBV by group A4

% === PARAMETERS ===
autoload = false;

if (~autoload)
    filefilter = {...
        '*.jpeg;*.jpg' , 'JPEG-Bilddateien (.jpeg, .jpg)';
        '*.png;','Portable Network Graphics (.png)';
        '*.*', 'Alle Dateien'};
    [file,path] = uigetfile(filefilter, 'Datei zum Öffnen auswählen');
    if file == 0
        return
    end
    filename = strcat(path, file);
else
    filename = "../testbilder/learning set/12 caps, aligned, black background [ausschnitt].jpg";
end

unscaled_rgb_image = imread(filename);

[caps] = stieglBottleCapScan(imread(filename));

outImg = createOutputImage(unscaled_rgb_image, caps);
imshow(outImg);

