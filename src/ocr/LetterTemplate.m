classdef LetterTemplate
    %LETTERTEMPLATE Contains the mask and the corresponding letter of a
    %letter template
    %author: Gerald KIMMERSDORFER, 01326608
    
    properties
        mask    % the b/w image of that letter
        letter  % the corresponding letter as a char
        layers  % the number of letter-images that helped build the mask-matrix
    end
    
    methods
        function obj = LetterTemplate(mask, letter)
            %LETTERTEMPLATE Construct an instance with the given mask image and
            %letter char
            obj.mask = mask;
            obj.letter = letter;
            obj.layers = 1;
        end
        
        function obj = AddLayer(obj, mask)
            mask = int8(mask);
            mask(mask == 0) = -1;
            obj.mask = obj.mask + mask;
            obj.layers = obj.layers + 1;
        end
        
        function correlation = correlate(obj, mask)
            %CORRELATION returns a value that specifies how many pixel fit
            %the objects mask. (0 equals none, 1 equals all)
            
            %Solution with sums and equal(also counts white cells):
            %correlation = (sum(obj.mask == mask) / sum(size(obj.mask)));
            
            %Solution with selection mask (just counts black overlaps):
            %(BAD CAUSE OUTSIDE PIXELS ARE NOT ACCOUNTED FOR)
            %correlation = sum(sum(obj.mask(mask))) / sum(sum(obj.mask));
            
            %Solution with negative treatment
            maxPossible = sum(sum(obj.mask(obj.mask > 0)));
            correlation = 0;
            if maxPossible == 0, return; end %Mask is probably not trained yet
            abscorr = sum(sum(obj.mask(mask)));
            if abscorr < 0, abscorr = 0; end
            correlation = abscorr / maxPossible;
            
            assert(correlation >= 0 && correlation <= 1);
        end
    end
end

