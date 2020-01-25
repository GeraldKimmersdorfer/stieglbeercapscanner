classdef Component
    %COMPONENT Holds data of one extraxted labled componenent.
    %author: Gerald KIMMERSDORFER, 01326608
    
    properties
        id      % the id of that component inside the component-matrix
        size    % the outer-rectangle size of that component
        pos     % the position in the actual image of that component
        area    % the amount of filled pixels of that component
        image   % the logical image of that component
        tag     % true/false wether its a relevant component (user/defined)
    end
    
    methods(Static)
        function debugInfo(var)
            %DEBUGINFO Shows an array of Components in a figure for
            %debugging purposes
            if ismatrix(var)
                m = 4;
                n = ceil(length(var)/m);
                figure('Position', [0 0 1800 1000]);
                for i = 1:length(var)
                    subplot(m,n,i);
                    imshow(var(i).image);
                    title(var(i).toString());
                end
            else
                figure;
                imshow(var.image);
                title(var.toString());
            end
        end
    end
    
    methods
        function obj = Component(L,num)
            %COMPONENT Construct an instance of this class with the data
            %extracted out of the Label-Matrix L and the corresponding
            %component-number num
            if nargin == 0, return; end
            img = L==num;
            [r,c] = find(img);
            obj.id = num;
            obj.pos = [min(r), min(c)];
            obj.size = [max(r)-obj.pos(1), max(c)-obj.pos(2)];
            obj.image = img(obj.pos(1):(obj.pos(1)+obj.size(1)),...
                obj.pos(2):(obj.pos(2)+obj.size(2)));
            obj.area = sum(sum(obj.image));
            obj.tag = true;
        end
        
        function res = onHorizontalLine(obj, y)
            %ONHORIZONTALLINE Returns true if the object gets cut through
            %by a specified y
            res = false;
            if obj.pos(1) < y && (obj.pos(1) + obj.size(1)) > y
                res = true;
            end
        end
        
        function res = toString(obj)
            %TOSTRING Returns a textual representation of the object
            res = strcat( int2str(obj.id), '|', ...
                int2str(obj.size(1)), 'x', int2str(obj.size(2)), '(', num2str(obj.getAspectRatio()), ')|', ...
                int2str(obj.pos(1)), ',', int2str(obj.pos(2)), '|', ...
                int2str(obj.area), '|', num2str(obj.tag)); 
        end
        
        function res = getAspectRatio(obj)
            %GETASPECTRATIO Returns the aspect-ratio factor width/height of
            %the object
            res = obj.size(2) / obj.size(1);
        end
       
    end
end

