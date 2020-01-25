function [code,likelyhood,failure] = ocr_readCode(img)
%OCR_READCODE Tries to read a certain amount of letters in an image and
%returns the corresponding string
%
%   This function takes a binary image, extracts the letters with the
%   connected component algorithm, sorts those components in the correct
%   order, and tries to identify those components with the help of the
%   ocr_readChar function. If for whatever reason the process is not
%   successfull an error message will be delivered in the
%   failure-parameter. The parameter likelyhood contains a statistical
%   number on how well the code could have been verified
%
%   @author: Gerald Kimmersdorfer, 01326608

failure = [];
code = [];
likelyhood = 0;

% === PARAMETERS ===
LINE_COUNT = 3;         % how many lines to look for

% THE FOLLOWING PARAGRAPH IS RELEVANT FOR TRAININGS-MODE. HOWEVER THIS IS
% NOT PART OF THE ACTUAL ASSIGNMENT! YOU CAN READ MORE ABOUT THAT IN THE
% OCR_READCHAR.M-FILE
clear('global', 'SKIPTRAINING');
global CURRENT_BOTTLECAP_IMAGE;
CURRENT_BOTTLECAP_IMAGE = img;

comp = letterExtraction(img);

if isempty(comp)
    failure = strcat("letterExtraction failed");
else
    % SORT THE LETTERS IN CORRECT ORDER
    sorted = [];
    linecount = 0;
    while ~isempty(comp)
        line = [];
        n = length(comp);
        % get the upmost letter:
        mini = 1;
        for i = 2:n
            if comp(i).pos(1) < comp(mini).pos(1)
                mini = i;
            end
        end
        currentLine = comp(mini).pos(1) + comp(mini).size(1)/2;
        % get all letters on that line and order it correctly
        for ci = n:-1:1
            if comp(ci).onHorizontalLine(currentLine)
                inserted = false;
                for i2 = 1:length(line)
                    if comp(ci).pos(2) < line(i2).pos(2)
                        line = [line(1:i2-1) comp(ci) line(i2:end)];
                        inserted = true;
                        break; % don't have to look further because the list should be sorted
                    end
                end
                if ~inserted
                    line = [line comp(ci)];
                end
                comp(ci) = [];   % delete element
            end
        end
        sorted = [sorted line];
        linecount = linecount + 1;
    end
    
    if linecount ~= LINE_COUNT
        failure = strcat("can't find ",int2str(LINE_COUNT)," lines");
    else
        load('LEARNED_TEMPLATES.mat','LEARNED_TEMPLATES');
        n = length(sorted);
        likelyhoods = zeros(1,n);
        code = blanks(n);
        for i = 1:length(sorted)
            [newchar, likelychar] = ocr_readChar(sorted(i), LEARNED_TEMPLATES);
            if ~isempty(newchar)
                code(i) = newchar;
                likelyhoods(i) = likelychar;
            end
        end
        failedLetters = find(code == ' ');
        if ~isempty(failedLetters)
            failure = strcat("couldn't recognize letters ' ", int2str(failedLetters), " '");
        else
            likelyhood = sum(likelyhoods) / length(likelyhoods);
        end
    end
end
end

