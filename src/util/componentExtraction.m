function [L,components] = componentExtraction(logimg)
%COMPONENTEXTRACTION Connected-Component extraction with two-pass connected
%component labeling
%
%   Applies an connected-component algorithm on the given logical image.
%   The connected components get extracted as Component-Objects and
%   returned in the components-Array. The returned Matrix L is the original
%   matrix with the labled component-indices.
%   
%   (for more information on the algorithm see:
%   https://www.youtube.com/watch?v=hMIrQdX4BkE)
%
%   @author: Gerald Kimmersdorfer

% add 1 px border on each side so neighbourhood of pixel can be checked
% without an array index-error
imgsize = size(logimg);
img = zeros(imgsize+2, 'uint32');
img(2:imgsize(1)+1,2:imgsize(2)+1) = logimg;

CC = 0;
linked = {};
for y = 2:imgsize(1)+1
    for x = 2:imgsize(2)+1
        if img(y,x) == 1
            % get relevant neighbours
            reln = [img(y-1,x-1), img(y-1,x), img(y-1,x+1), img(y,x-1)];
            reln = unique(reln(reln > 0));
            
            if isempty(reln)
                % no neighbour is labeled
                CC = CC + 1;
                img(y,x) = CC;
                linked{CC} = CC;
            else
                % at least one neighbour is labeled (use lowest lable)
                mylabel = min(reln);
                img(y,x) = mylabel;
                if length(reln) > 1
                    % theres a conflict so add the main label (always the lowest) for the
                    % component to the replace list
                    for i = 1:length(reln)
                        linked{reln(i)} = unique([linked{reln(i)} reln]);
                    end
                end
            end
        end
    end
end

% remove border
img = img(2:imgsize(1)+1, 2:imgsize(2)+1);

% flatten link lists and create replacement list
replace = zeros(1,length(linked));
n = 1;
for i = 1:length(linked)
    flatLinked = [];
    godeeper = true;
    while godeeper
        godeeper = false;
        flatLinked = linked{i};
        for i2 = 1:length(linked{i})
            subi = linked{i}(i2);
            if subi == i, continue; end
            if ~isempty(linked{subi})
                godeeper = true;
                flatLinked = unique([flatLinked linked{subi}]);
                linked{subi} = [];
            end
        end
        linked{i} = flatLinked;
    end
    increaseCounter = false;
    for i2 = 1:length(linked{i})
        subi = linked{i}(i2);
        replace(subi) = n;
        increaseCounter = true;
    end
    if increaseCounter
        n = n + 1;
    end
end
n = n - 1;

% replace all aliases with the linked label
for y = 1:imgsize(1)
    for x = 1:imgsize(2)
        if img(y,x) > 0
            img(y,x) = replace(img(y,x));
        end
    end
end
L = img;

% create component objects
components(1,n) = Component;
for i = 1:n
    components(i) = Component(L,i);
end

end

