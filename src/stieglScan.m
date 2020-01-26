%% STIEGL-BOTTLECAP-CODE-SCANNER


filenames = [];
supported_files = {...
	'*.jpeg;*.jpg' ,    'JPEG-Images (.jpeg, .jpg)';
	'*.png' ,           'Portable Network Graphics (.png)';
    '*.gif' ,           'Graphics Interchange Format (.gif)'};

if Parameters.DEBUG && Parameters.DEBUG_SOURCE_FILE ~= ""
    filenames{1} = Parameters.DEBUG_SOURCE_FILE;
else
    if Parameters.BATCH_MODE
        %% ask user for directory to scan
        directory = uigetdir(pwd, "Select folder with images to process");
        if directory == 0
            return
        end
        
        %% build array containing supported extensions
        supported_extensions = {};
        co = 1;
        for i = 1:length(supported_files)
            tmp = split(strrep(supported_files{i,1}, "*",""), ';');
            for i2 = 1:length(tmp)
                supported_extensions{co} = tmp{i2}; %#ok<SAGROW>
                co = co + 1;
            end
        end
        
        %% read and filter all files with one of the supported extensions
        files = dir(directory);
        co = 1;
        for i = 1:length(files)
            [~,~,ext] = fileparts(files(i).name);
            if any(ismember(supported_extensions, lower(ext)))
                filenames{co} = strcat(files(i).folder, '\', files(i).name); %#ok<SAGROW>
                co = co + 1;
            end
        end
        
        if isempty(filenames)
            % not one supported file in directory
            disp("> There are no supported image-files in the selected folder");
            return;
        end
    else
        %% ask user for file to scan
        supported_files{3,1} = '*.*';
        supported_files{3,2} = 'All files';
        [file,path] = uigetfile(supported_files, "Select Image to process");
        if file == 0
            return
        end
        filenames{1} = strcat(path, file);
    end
end

n = length(filenames);
for i = 1:length(filenames)
    filename = filenames{i};
    disp(strcat("> Starting scan of image ", num2str(i), " / ", num2str(n), " with filename: '", filename, "'"));
    [caps] = stieglBottleCapScan(imread(filename), ...
        Parameters.SHOW_PROGRESS_BAR, ...
        Parameters.SHOW_RESULT_FIGURE, ...
        Parameters.DEBUG);
end

