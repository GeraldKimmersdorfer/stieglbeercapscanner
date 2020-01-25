function charret = ocr_trainLetter(mask)
%OCR_READCHAR Asks the user about what letter he can see.
%
%   This function offers a prompt where the user can define on what letter
%   he/she can see. With that information the letter masks gets additional
%   information about how letters can look like.
%
%   THIS IS JUST A HELPER FUNCTION THAT IS NOT PART OF THE ACTUAL ASSIGNMENT.
%   IT CAN THEREFORE CONTAIN FUNCTIONS OF THE IMAGE-PROCESSING-TOOLBOX. IT IS
%   NOT USED BY ANY CORE-FUNCTIONS!
%   Note: It's just also packed for better understand
%
%   @author: Gerald Kimmersdorfer, 01326608

    global SKIPTRAINING;
    global CURRENT_BOTTLECAP_IMAGE;
    global TRAIN_FIGURE;
    
    charret = '';
    if ~isempty(SKIPTRAINING)
        return;
    end
    
    if isempty(TRAIN_FIGURE)
        TRAIN_FIGURE = figure('Name','LEARNING-MODE: Letter-Recognition','Color','black', 'Position', [0,0,800,600]);
    else
        try
            figure(TRAIN_FIGURE);
        catch
            TRAIN_FIGURE = figure('Name','LEARNING-MODE: Letter-Recognition','Color','black', 'Position', [0,0,800,600]);
        end
    end
    if isempty(CURRENT_BOTTLECAP_IMAGE)
        imshow(mask);
    else
        subplot(1,2,1); imshow(CURRENT_BOTTLECAP_IMAGE);
        subplot(1,2,2); imshow(mask);
    end
    
    letter = inputdlg("What letter can you see? (First letter counts)");
    if isempty(letter) 
        SKIPTRAINING = true;
        return;
    end
    letter = letter{1,1};
    charret = letter;
    
    load('ocr/LEARNED_TEMPLATES');
    foundLetter = false;
    for i = 1:length(LEARNED_TEMPLATES)
        if strcmp(LEARNED_TEMPLATES(i).letter, letter)
            LEARNED_TEMPLATES(i) = LEARNED_TEMPLATES(i).AddLayer(mask);
            foundLetter = true;
            break;
        end
    end
    if foundLetter
        disp(strcat('Added new Layer to Mask of "', letter, '"'));
        save('ocr/LEARNED_TEMPLATES', 'LEARNED_TEMPLATES');
    else
        disp(strcat('Could not find corresponding template to "', letter, '"'));
    end
end

