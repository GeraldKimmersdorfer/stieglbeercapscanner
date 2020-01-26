function [bwimage] = createGrayImage(unscaled_rgb_image)
%CREATEGRAYIMAGE  Converts a rgb image into a grayscale image.
%It converts rgb values to grayscale values by forming a weighted sum of the r, g, and b components:
%0.299 * r + 0.587 * g + 0.114 * b
%   AUTHOR: Martin
%  
%   parameters:
%       unscaled_rgb_image: the image that should be converted
%
%   output:
%       bwimage: the created grayscale image

redChannel = unscaled_rgb_image(:, :, 1);
greenChannel = unscaled_rgb_image(:, :, 2);
blueChannel = unscaled_rgb_image(:, :, 3);

for x = 1:size(unscaled_rgb_image, 1)
    for y = 1:size(unscaled_rgb_image, 2)
        bwimage(x, y) = (redChannel(x, y) * .299) + (greenChannel(x, y) * .587) + (blueChannel(x, y) * .114);
    end
end
      
bwimage = uint8(bwimage);

end

