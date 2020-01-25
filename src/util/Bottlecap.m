classdef Bottlecap
    %BOTTLECAP Contains Information about one bottlecap in the picture
    %   stores and contains the information about the innercircle
    %   (center+radius) and the outer circle(center+radius), also can
    %   contain an error message and error flag
    %   also contains String code which is successfully read by the entire
    %   process
    %   additionally there are helping methods like rescaling, validity
    %   check and cloning
    properties(Constant)
       orMaper = @(bc, d) bc.outerRadius;
       ocMaper = @(bc, d) bc.outerCenter(d);
    end
    properties
        id              % a unique identifier for that bottlecap object
        
        innerCenter     % a 2D-vector that represents the middle of the inner circle
        outerCenter     % a 2D-vector that represents the middle of the outer circle
        innerRadius     % a numeric value defining the radius of the inner circle
        outerRadius     % a numeric value defining the radius of the outer circle
        
        imgTrimmed      % the clipped bottlecap grayscale image
        imgOtsu         % the center-piece of the image which is used to calculate the threshold value
        imgBinary       % the clipped bottlecap b/w image
        imgFiltered     % the filtered logical bottlecap b/w image with just the letters
        imgRotated      % the rotated imgFiltered
        imgOCR          % the used image for ocr-recognition (for debug purposes)
        
        code            % a string that contains the bottlecap code
        
        runtime         % a double that contains the amount of seconds it took to process this bottlecap
        
        error           % a BottlecapError-Enumeration of which error occured (if any)
        errormsg        % a string that contains why a bottlecap could not be interpreted correctly (e.g. ocr failed, because...)
    end
    
    methods(Static)
        function [out] = map(bottlecaps, mappingFkt, dimension)
            %% maps bottlecaps using a desired funktion
            len = length(bottlecaps);
            out(1:len, 1:dimension) = 0;
            for i = 1:len
               for d = 1:dimension
                  out(i, d) = mappingFkt(bottlecaps(i), d); 
               end
            end
        end
        
        function [out] = getOnlyValid(bottlecaps)
           %% filters out caps with errors
           ind = 1;
           out = Bottlecap.empty;
           for b = bottlecaps
                if(~b.error)
                    out(ind) = b;
                    ind=ind+1;
                end
           end
        end
        
        function [out] = getRescaled(bottlecaps, rF)
           %% basic rescaling of caps with a scaling factor
           len = length(bottlecaps);
           out = bottlecaps;
           for i = 1:len
               out(i) = out(i).rescale(rF);
           end
        end
    end
    methods
        function obj = Bottlecap(id, innerCenter, innerRadius)
            %BOTTLECAP Construct an instance of this class
            %   Detailed explanation goes here
            obj.id = id;
            obj.innerCenter = innerCenter;
            obj.innerRadius = innerRadius;
            obj.error = BottlecapError.None;
            obj.errormsg = '';
            obj.runtime = 0;
        end
        
        function [obj] = clone(caps)
            %% simple clone operation for debug output or other stuff you want to do
            for i = 1:length(caps)
                cap = caps(i);
                o = Bottlecap(cap.innerCenter, cap.innerRadius);
                o.error = cap.error;
                o.errormsg = cap.errormsg;
                o.outerCenter = cap.outerCenter;
                o.outerRadius = cap.outerRadius;
                o.code = cap.code;
                obj(i) = o;
            end
        end
        
        function obj = setError(obj,type,msg)
            obj.error = type;
            obj.errormsg = msg;
        end
        
        function img = debugInfo(obj, asimg)
            if ~exist('asimg', 'var')
                asimg = false;
            end
            f = figure('name', strcat("Debug-Info of bottlecap '", obj.id, "'"), 'Position', [0 0 1600 800]);
            
            if asimg
                set(f, 'Visible', 'off');
            end
            
            m = 2;
            n = 3;
            
            subplot(m,n,1);
            imshow(obj.imgTrimmed);
            title("trimmed bottlecap picture");
            subplot(m,n,2);
            imshow(obj.imgBinary);
            title("bottlecap-picture with applied threshold filter");
            subplot(m,n,3);
            imshow(obj.imgFiltered);
            title("letter-filtered bottlecap-picture");
            subplot(m,n,4);
            imshow(obj.imgRotated);
            title("rotated binary bottlecap-picture");
            subplot(m,n,5);
            imshow(obj.imgOCR);
            if isempty(obj.code)
                title("ocr wasn't successfull");
            else
                title(strcat("used for OCR (code='", obj.code, "')"));
            end
            subplot(m,n,6);
            imshow(obj.imgOtsu);
            title(strcat("used image for globald threshold"));
            
            if asimg
                frame = getframe(f);
                img = frame2im(frame);
                close(f);
            end
        end
        
        function obj = getBounds(self)
            %% gets bounds as a square bound including everything 
            x1 = self.outerCenter(2)-self.outerRadius;
            x2 = self.outerCenter(2)+self.outerRadius;
            y1 = self.outerCenter(1)-self.outerRadius;
            y2 = self.outerCenter(1)+self.outerRadius;
            
            obj = Bounds(x1,x2,y1,y2);
        end
        
        function out = rescale(self, sF)
            %% simple rescaling of all values to the given factor
            self.innerCenter = self.innerCenter*sF;
            self.outerCenter = self.outerCenter*sF;
            self.innerRadius = self.innerRadius*sF;
            self.outerRadius = self.outerRadius*sF;
            out = self;
        end
    end
end