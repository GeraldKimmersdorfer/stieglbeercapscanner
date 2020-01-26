classdef Parameters
    %PARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        %% == DEBUG SETTINGS ===
        
        % activates general debug mode (writes img-logs,...)
        DEBUG = true;
        
        % if set and debug mode stieglScan will automatically scan
        % following picture ("" means user will be asked)
        DEBUG_SOURCE_FILE = ""; %"../data/testing/20191127_172126 (6).jpg";
        
        %% == GENERAL SETTINGS ===
        
        % if set stieglScan will ask for a folder and not a single picture
        % to scan. It will use all of the pictures in this folder as
        % sources.
        BATCH_MODE = true;
        
        % if set stieglBottleCapScan will keep you updated with a
        % progressbar window that will show the current progress of one
        % given file.
        SHOW_PROGRESS_BAR = true;
        
        % if set the resulting image will be shown and the code execution
        % will be stopped until the figure is closed again.
        SHOW_RESULT_FIGURE = true;
        
        %% == FREUNDESKREIS-UPLOAD SETTINGS ===
        
        % if activated stieglBottleCapScan will try to immediately upload
        % the points to a certain Stiegl-Store Freundeskreis Account.
        % (Credentials have to be correctly filled in below)
        DO_STIEGL_POINTS_UPLOAD = true;
        
        % the username for the platform
        % https://www.stiegl-shop.at/freundeskreis/ of the account where
        % the points are supposed to be uploaded to.
        STIEGL_USERNAME = Secrets.STIEGL_USERNAME;
        
        % the password to the given STIEGL_USERNAME for automatic point
        % upload.
        STIEGL_PASSWORD = Secrets.STIEGL_PASSWORD;
        
    end
    
end

