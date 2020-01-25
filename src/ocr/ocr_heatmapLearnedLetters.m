%HEATMAP LEARNED LETTER
%To give a better understanding about how the letter masks look like: this
%function plots all of the letter templates saved in the LEARNED_TEMPLATES
%Matrix.
%
% THIS IS JUST A HELPER FUNCTION THAT IS NOT PART OF THE ACTUAL ASSIGNMENT.
% IT CAN THEREFORE CONTAIN FUNCTIONS OF THE IMAGE-PROCESSING-TOOLBOX. IT IS
% NOT USED BY ANY CORE-FUNCTIONS!
% Note: It's just also packaged for better understand
%
%author: Gerald KIMMERSDORFER, 01326608
load('ocr/LEARNED_TEMPLATES');
figure('name', 'All learned templates', 'Position', [0 0 1800 1000]);

m = 4;
n = ceil(length(LEARNED_TEMPLATES)/m);
for i = 1:length(LEARNED_TEMPLATES)
    obj = LEARNED_TEMPLATES(1,i);
    subplot(m,n,i);
    heatmap(obj.mask);
    title(strcat('"', obj.letter, '" (', int2str(obj.layers), ' Layers)'));
end