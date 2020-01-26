function outimg = createOutputImage(baseimg, caps)
%OUTPUTRESULTS Outputs all the codes in a txt-file and shows an image that
%shows which codes could be extracted correctly and not. (see concept for
%more information)
%   AUTHOR: David

outimg = baseimg;

for i = 1:length(caps)
    %% get colors depending on status
    cap = caps{i};
    color = 'red';
    textColor = 'white';
    if cap.error == BottlecapError.None
        color = 'green';
        textColor = 'black';
    elseif cap.error == BottlecapError.AlreadyUsed
        color = 'yellow';
        textColor = 'black';
    end
    
    %% Draw Transparent inner & outer - circles
    outimg = insertShape(outimg, 'FilledCircle', [cap.outerCenter cap.outerRadius], 'Color', color, 'opacity', 0.4);
    outimg = insertShape(outimg, 'Circle', [cap.outerCenter cap.outerRadius], 'LineWidth', 8, 'Color', color, 'opacity', 0.5);
    outimg = insertShape(outimg, 'FilledCircle', [cap.innerCenter cap.innerRadius], 'Color', color, 'opacity', 0.1);
    outimg = insertShape(outimg, 'Circle', [cap.innerCenter cap.innerRadius], 'LineWidth', 10, 'Color', color);
    
    %% write code and/or error msg on picture
    textPos = cap.innerCenter;
    textPos = textPos + [0 , cap.innerRadius + 20];
    if ~isempty(cap.code)
        outimg = insertText(outimg, textPos,  cap.code, ...
            'TextColor', textColor, ...
            'FontSize', uint8(cap.innerRadius / 4), ...
            'BoxColor', color, ...
            'BoxOpacity', 0, ...
            'AnchorPoint', 'CenterTop');
        textPos(2) = textPos(2) + cap.innerRadius / 2;
    end
    if ~isempty(cap.errormsg)
        outimg = insertText(outimg, textPos,  cap.errormsg, ...
            'TextColor', textColor, ...
            'FontSize', uint8(cap.innerRadius / 6), ...
            'BoxColor', color, ...
            'BoxOpacity', 0, ...
            'AnchorPoint', 'CenterTop');
    end

end


end