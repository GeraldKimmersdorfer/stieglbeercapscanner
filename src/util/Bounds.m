classdef Bounds
    %BOUNDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lowerX % lower X bound
        upperX % upper X bound
        lowerY % lower Y bound
        upperY % upper Y bound
    end
    methods
        function obj = Bounds(lowerX,upperX,lowerY,upperY)
            %BOUNDS Construct an instance of this class
            %   Detailed explanation goes here
            obj.lowerX = lowerX;
            obj.upperX = upperX;
            obj.lowerY = lowerY;
            obj.upperY = upperY;
        end
        function out = rescale(self, sF)
            self.lowerX = self.lowerX*sF;
            self.upperX = self.upperX*sF;
            self.lowerY = self.lowerY*sF;
            self.upperY = self.upperY*sF;
            out = self;
        end
        function out = getTopLeft(self)
           out(1) = self.lowerY;
           out(2) = self.lowerX;
        end
        function out = getTopRight(self)
           out(1) = self.lowerY;
           out(2) = self.upperX;
        end
        function out = getBottomLeft(self)
           out(1) = self.upperY;
           out(2) = self.lowerX;
        end
        function out = getBottomRight(self)
           out(1) = self.upperY;
           out(2) = self.upperX;
        end
        function out = toString(self)
           out = ['(',num2str(self.lowerX),'/',num2str(self.lowerY),') (',num2str(self.upperX),'/',num2str(self.upperY),')'];
        end
    end
end

