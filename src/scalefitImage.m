function [output,factor] = scalefitImage(img, maxsize, stretch)
%SCALEIMAGE Scaled the image so that it fits in the desired boundaries.
%   AUTHOR: Martin
%
%   parameters:
%       img: the image that should be changed so that it fits in the
%       boundaries.
%       maxwidth: the maxwidth of the output image
%       maxheight: the maxheight of the output image
%
%   output:
%       output: the scaled image that has height < maxheight and width <
%       maxwidth

if ~exist('stretch','var')
    stretch = true;
end

oldW = size(img,2);
oldH = size(img,1);

if stretch == false && oldW < maxsize(1) && oldH < maxsize(2)
    output = img;
    factor = 1;
    return;
end

newW = maxsize(1);
factor = newW / oldW;
newH = factor * oldH;
if newH > maxsize(2)
    newH = maxsize(2);
    factor = newH / oldH;
    newW = NaN;
else
    newH = NaN;
end

output = imresize(img, [newH newW]);

% in_rows = size(img,1);
% in_cols = size(img,2);
% 
% % decide whether width or height is bigger and then calculate the zoom for
% % the output image.
% if(in_rows > in_cols) 
%     zoom=in_rows/maxheight;
% else
%     zoom=in_cols/maxwidth;
% end
% 
% out_rows = floor(in_rows / zoom);
% out_cols = floor(in_cols / zoom);
% 
% [cf, rf] = meshgrid(1 : out_cols, 1 : out_rows);
% 
% rf = rf * zoom;
% cf = cf * zoom;
% 
% r = floor(rf);
% c = floor(cf);
% 
% r(r < 1) = 1;
% c(c < 1) = 1;
% r(r > in_rows - 1) = in_rows - 1;
% c(c > in_cols - 1) = in_cols - 1;
% 
% delta_R = rf - r;
% delta_C = cf - c;
% 
% in1_ind = sub2ind([in_rows, in_cols], r, c);
% in2_ind = sub2ind([in_rows, in_cols], r+1,c);
% in3_ind = sub2ind([in_rows, in_cols], r, c+1);
% in4_ind = sub2ind([in_rows, in_cols], r+1, c+1);       
% 
% output = zeros(out_rows, out_cols, size(img, 3));
% output = cast(output, class(img));
% 
% for idx = 1 : size(img, 3)
%     chan = double(img(:,:,idx));
%     tmp = chan(in1_ind).*(1 - delta_R).*(1 - delta_C) + ...
%                    chan(in2_ind).*(delta_R).*(1 - delta_C) + ...
%                    chan(in3_ind).*(1 - delta_R).*(delta_C) + ...
%                    chan(in4_ind).*(delta_R).*(delta_C);
%     output(:,:,idx) = cast(tmp, class(img));
% end

end

