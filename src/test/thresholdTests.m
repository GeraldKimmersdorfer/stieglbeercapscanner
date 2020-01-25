function thresholdTests(testArray)
    FROM_FOLDER = true;

    if FROM_FOLDER
        folder = "..\testbilder\util test\problematic_codes\";
        files = dir(strcat(folder,"*.jpg"));
        imgs = cell(length(files),1);
        for i = 1:length(files)
            imgs{i} = imread(strcat(folder, files(i).name));
        end
    else
        data = matfile("..\testbilder\util test\adaptiveThreshold.mat");
        imgs = data.thrTest;
    end

    if ~exist("testArray", "var")
        testArray = 1:length(imgs);
    end

    % 
    % figure();

    for i = testArray
        img = imgs{i};

        THRESHOLD_BOXSIZE = [50 50];
        imgsize = size(img);
        threshimg = img(round(imgsize(1)/2-THRESHOLD_BOXSIZE(1)/2):round(imgsize(1)/2+THRESHOLD_BOXSIZE(1)/2), ...
            round(imgsize(2)/2-THRESHOLD_BOXSIZE(2)/2):round(imgsize(2)/2+THRESHOLD_BOXSIZE(2)/2));

        % Matlab graythresh
        img1 = imbinarize(img, graythresh(threshimg));

        % Otsu's method
        img2 = img > otsuThresholdVal(threshimg);

        % simple thresholds
        thr = simpleThresholds(threshimg);
        img3 = img > thr(1);
        img4 = img > thr(2);

        % Matlab adaptive
        T = adaptthresh(img, 0.4, 'ForegroundPolarity', 'bright');
        img5 = imbinarize(img, T);

        m = 3; n = 3; subp = 1;

    %     subplot(m,n,subp);
    %     imshow(img);
    %     title('Original');
    %     subp = subp + 1;
    %     
    %     subplot(m,n,subp);
    %     imshow(img1);
    %     title('Graythresh');
    %     subp = subp + 1;
    %     
    %     subplot(m,n,subp);
    %     imshow(img2);
    %     title('Otsu');
    %     subp = subp + 1;
    %         
    %     subplot(m,n,subp);
    %     imshow(img3);
    %     title('Mean');
    %     subp = subp + 1;
    %     
    %     subplot(m,n,subp);
    %     imshow(img4);
    %     title('Offset');
    %     subp = subp + 1;
    %     
    %     subplot(m,n,subp);
    %     imshow(img5);
    %     title('Matlab Adaptive');
    %     subp = subp + 1;

        cap = Bottlecap("1",[0 0],0);
        cap.imgTrimmed = img;
        cap = filterBottleCapCode(cap);

    end
end

