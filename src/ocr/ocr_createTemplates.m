%CREATE TEMPLATES
%Creates the template-matrix filled with all the LetterTemplate-Objects
%which hold the masks and the corresponding char. Make sure to adapt the
%TEMPLATES_PATH variable to to folder which contains the different
%template-images. The first char of the file-name will be taken as the
%reference char.
%
% THIS IS JUST A HELPER FUNCTION THAT IS NOT PART OF THE ACTUAL ASSIGNMENT.
% IT CAN THEREFORE CONTAIN FUNCTIONS OF THE IMAGE-PROCESSING-TOOLBOX. IT IS
% NOT USED BY ANY CORE-FUNCTIONS!
% Note: It's just also packaged with the rest for understanding my code
% foundation.
%
%author: Gerald KIMMERSDORFER, 01326608

TEMPLATES_PATH = '..\testbilder\template matching\letters\v1\';
IMAGE_FILES_EXTENSION = '.bmp';

files = dir(strcat(TEMPLATES_PATH,'*',IMAGE_FILES_EXTENSION));

refSize = [];
LETTER_TEMPLATES = [];
for i = 1:length(files)
    mask = imread(strcat(files(i).folder, '\', files(i).name));
    letter = files(i).name(1);
    
    if size(mask,3) > 1
        mask = rgb2gray(mask);
    end
    
    mask = mask > 128;
    
    if isempty(refSize)
        refSize = size(mask);
    else
        if refSize ~= size(mask)
            error("all images need to be of same size");
        end
    end
    
    LETTER_TEMPLATES = [LETTER_TEMPLATES LetterTemplate(mask, letter)];
end

save ('ocr/LETTER_TEMPLATES','LETTER_TEMPLATES')

path = 'ocr/LEARNED_TEMPLATES.mat';
renewLearnedTemplates = true;
setLearnedTemplatesToEmptyMask = false;
if isfile(path)
    answer = questdlg('Bestehende LETTER_LEARNED_TEMPLATES überschreiben? ACHTUNG: Eventueller Lernfortschritt geht dadurch verloren?', ...
        'LETTER_LEARNED_TEMPLATES vorhanden', ...
        'Ja', 'Nein', 'Ja, aber mit leeren Masken', 'Nein');
    switch answer
        case 'Nein'
            renewLearnedTemplates = false;
        case 'Ja, aber mit leeren Masken'
            setLearnedTemplatesToEmptyMask = true;
    end
end
if renewLearnedTemplates
    LEARNED_TEMPLATES = LETTER_TEMPLATES;
    for i = 1:length(LEARNED_TEMPLATES)
        LEARNED_TEMPLATES(i).mask = int8(LEARNED_TEMPLATES(i).mask);
        if setLearnedTemplatesToEmptyMask
            LEARNED_TEMPLATES(i).mask = LEARNED_TEMPLATES(i).mask .* 0;
            LEARNED_TEMPLATES(i).layers = 0;
        end
    end
    save(path, 'LEARNED_TEMPLATES');
end
clear all
