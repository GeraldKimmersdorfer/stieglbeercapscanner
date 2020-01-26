function bottlecaps = findBottleCaps(img)
    global logger debug;
    logger.setFuncName(mfilename);

    % === PARAMETERS ===
    CIRCLE_RANGE = [11 60];
    IMAGE_SIZE = [500 500];
    SENSITIVITY_ON_NORMAL = 0.8;
    SENSITIVITY_ON_THRESHOLD = 0.7;
    SENSITIVITY_ON_SOBEL = 0.95;
    % FILTERING:
    MIN_CENTER_CIRCLE_RADIUS = 75;
    CIC_RADIUS_SIZE_FACTOR = 1.05;
    CIC_IMAGE_SIZE = [50 50];
    CIC_CIRCLE_RANGE = [floor(CIC_IMAGE_SIZE(1)/5) ceil(CIC_IMAGE_SIZE(1)/2)];
    SENSITIVITY_ON_CIC = 0.9;
    % the circles radi get multiplied with that number at the end (to get
    % rid of the white border), deprecated though due the use of the
    % function letterFiltering.
    INNER_CIRCLE_RADI_MULTIPLICATOR = 1.0;  
    % JUST FOR DEBUG:
    BOUNDRY_TO_INNERCIRCLE_RATIO = 2.7;

    [img_scaled, sFactor] = scalefitImage(img, IMAGE_SIZE);
    
    [centers_none, radii_none, ~] = imfindcircles(img_scaled, CIRCLE_RANGE, 'Sensitivity', SENSITIVITY_ON_NORMAL, 'ObjectPolarity','dark');
    logger.debug(strcat(int2str(length(radii_none)), " circles found on normal picture"));
    
    img_thresh = imbinarize(img_scaled, graythresh(img_scaled));
    [centers_thresh, radii_thresh, ~] = imfindcircles(img_thresh, CIRCLE_RANGE, 'Sensitivity', SENSITIVITY_ON_THRESHOLD, 'ObjectPolarity','dark');
    logger.debug(strcat(int2str(length(radii_thresh)), " circles found on threshold picture"));
    
    img_sobel = sobel(img_scaled);
    [centers_sobel, radii_sobel, ~] = imfindcircles(img_sobel, CIRCLE_RANGE, 'Sensitivity', SENSITIVITY_ON_SOBEL);
    logger.debug(strcat(int2str(length(radii_sobel)), " circles found on sobel picture"));
    
    if debug
        % save log image with detected circles
        img_log = img_scaled;
        img_log = insertShape(img_log, 'Circle', [centers_sobel radii_sobel], 'LineWidth', 2, 'Color', 'blue');
        img_log = insertShape(img_log, 'FilledCircle', [centers_sobel radii_sobel], 'Color', 'blue', 'opacity', 0.2);
        img_log = insertShape(img_log, 'Circle', [centers_none radii_none], 'LineWidth', 2, 'Color', 'yellow');
        img_log = insertShape(img_log, 'FilledCircle', [centers_none radii_none], 'Color', 'yellow', 'opacity', 0.2);
        img_log = insertShape(img_log, 'Circle', [centers_thresh radii_thresh], 'LineWidth', 2, 'Color', 'green');
        img_log = insertShape(img_log, 'FilledCircle', [centers_thresh radii_thresh], 'Color', 'green', 'opacity', 0.2);
        logger.imglog(img_log, 'detected circles');
    end

    % merge the results and scale it to actual size
    centers = [centers_thresh; centers_none; centers_sobel] ./ sFactor;
    radii = [radii_thresh; radii_none; radii_sobel] ./ sFactor;
    
    % FILTER OUT THE RESULTS BY DOING THE FOLLOWING:
    
    % Remove all circles that are smaller than the set min-radius
    selector = radii < MIN_CENTER_CIRCLE_RADIUS;
    centers(selector,:) = [];
    radii(selector) = [];
    logger.debug(strcat(int2str(sum(selector)), " circles deleted because they are smaller than MIN_CENTER_CIRCLE_RADIUS, ", int2str(length(radii)), " remaining"));
    
    n = length(radii);
    [centers,radii] = filterOutsideCircles(centers,radii,img);
    logger.debug(strcat(int2str(n - length(radii)), " circles deleted because they were partly outside the picture, ", int2str(length(radii)), " remaining"));
    
    % Remove all contained and touching circles
    n = length(radii);
    [centers,radii] = filterConnectingCircles(centers,radii);
    logger.debug(strcat(int2str(n - length(radii)), " circles deleted because they were either contained or touched a different circle, ", int2str(length(radii)), " remaining"));
    
    if debug
        img_log = img;
        img_log = insertShape(img_log, 'Circle', [centers radii], 'LineWidth', 2, 'Color', 'blue');
        img_log = insertShape(img_log, 'FilledCircle', [centers radii], 'Color', 'blue', 'opacity', 0.2);
        logger.imglog(img_log, 'filtered circles');
    end
    
    % FILTER OUT THE RESULT BY LOOKING FOR THE INNER CIRCLE OF THE STIEGL
    % BEERCAP AGAIN
    n = length(radii);
    selector = false(n,1);
    imgsize = size(img);
    for i1 = 1:n
        radiNew = radii(i1) * CIC_RADIUS_SIZE_FACTOR;
        imgOffset = uint16([max(centers(i1,1) - radiNew,0),max(centers(i1,2) - radiNew,0)]);
        circleImage = img(...
            imgOffset(2) : min(imgOffset(2) + 2 * radiNew, imgsize(1)), ...
            imgOffset(1) : min(imgOffset(1) + 2 * radiNew, imgsize(2)));
        [circleImageScaled, sFactor2] = scalefitImage(circleImage, CIC_IMAGE_SIZE);
        [newCenter, newRadi, ~] = imfindcircles(circleImageScaled, CIC_CIRCLE_RANGE, 'Sensitivity', SENSITIVITY_ON_CIC, 'ObjectPolarity','dark');
        [newCenter, newRadi] = filterConnectingCircles(newCenter,newRadi);
        
        if length(newRadi) == 1
            centers(i1,:) = newCenter ./ sFactor2 + double(imgOffset);
            radii(i1) = newRadi ./ sFactor2;
        else
            selector(i1) = true;
        end
    end
    centers(selector,:) = [];
    radii(selector) = [];
    logger.debug(strcat(int2str(sum(selector)), " circles deleted because inner circle couldn't be found, ", int2str(length(radii)), " remaining"));
    
    % Remove all circles that are smaller than the set min-radius again
    selector = radii < MIN_CENTER_CIRCLE_RADIUS;
    centers(selector,:) = [];
    radii(selector) = [];
    logger.debug(strcat(int2str(sum(selector)), " circles deleted because they are again smaller than MIN_CENTER_CIRCLE_RADIUS, ", int2str(length(radii)), " remaining"));
    
    if debug
        img_log = img;
        img_log = insertShape(img_log, 'Circle', [centers radii], 'LineWidth', 2, 'Color', 'blue');
        img_log = insertShape(img_log, 'FilledCircle', [centers radii], 'Color', 'blue', 'opacity', 0.2);
        logger.imglog(img_log, 'inner Circle Filter');
    end

    % Remove circles that are not bound by a boundry line
    centers = centers .* sFactor;
    radii = radii .* sFactor;
    n = length(radii);
    [centers,radii] = filterUnboundCircles(centers,radii,img_sobel);
    centers = centers ./ sFactor;
    radii = radii ./ sFactor;
    logger.debug(strcat(int2str(n - length(radii)), " circles deleted because inside the possible bottlecap zone they were not bound on the sobel image ", int2str(length(radii)), " remaining"));
    
    if debug
        img_log = img;
        img_log = insertShape(img_log, 'Circle', [centers radii], 'LineWidth', 2, 'Color', 'blue');
        img_log = insertShape(img_log, 'FilledCircle', [centers radii], 'Color', 'blue', 'opacity', 0.2);
        logger.imglog(img_log, 'after Outer Boundry Filter');
    end
    
    % fill Bottlecap-Array
    n = length(radii);
    bottlecaps = cell(n,1);
    for i = 1:n
        radii(i) = radii(i) * INNER_CIRCLE_RADI_MULTIPLICATOR;
        b = Bottlecap(int2str(i), centers(i,:), radii(i));
        b.outerRadius = radii(i) * BOUNDRY_TO_INNERCIRCLE_RATIO;
        b.outerCenter = centers(i,:);
        bottlecaps{i} = b;
    end
    
    if debug
        img_log = createOutputImage(img, bottlecaps);
        logger.imglog(img_log, 'found Bottlecaps And Inner Circle Reduced');
    end
    
    logger.endOfFunction();
    
%     not really necessary anymore due  good filtering    
%     if ~isempty(radii)
%         bottlecaps = findOuterBounds(img_sobel, centers .* sFactor, radii .* sFactor);
%         bottlecaps = Bottlecap.getRescaled(bottlecaps, 1 / sFactor);
%     end 
end

