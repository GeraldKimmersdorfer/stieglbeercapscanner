function [capImage] = getBottleCapImage(fullImage, cap)
%GETBOTTLECAPIMAGE Crop Cap-Image out of picture
%   AUTHOR: David
%   Expects an instance of Bottlecap and the full grayscale image as attribute and returns a gray
%   scale image of the cropped inner circle (which contains the code)
%   parameters:
%       fullImage = unedited image with all bottlecaps
%       cap = bottlecap object with values from one bottlecap
%
%   output:
%       capImage = cropped image of bottlecap
I = fullImage;
imageSize = size(I);

% Values from bottlecap
center = cap.innerCenter;
radius = cap.innerRadius;
ci = [center(2),center(1), radius];

% create mask
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
croppedImage = uint8(zeros(size(I)));

% create masked image
if size(I,3)==3
    croppedImage(:,:,1) = I(:,:,1).*mask;
    croppedImage(:,:,2) = I(:,:,2).*mask; 
    croppedImage(:,:,3) = I(:,:,3).*mask;
else
    croppedImage(:,:,1) = I(:,:,1).*mask;
end

p1max = center(1) + radius;
p1min = center(1) - radius;
p2max = center(2) + radius;
p2min = center(2) - radius;

% crop to borders of bottlecap
croppedImage(:,1:uint64(p1min),:) = [];
croppedImage(1:uint64(p2min),:,:) = [];
croppedImage(:,uint64(p1max-p1min+1):end,:) = [];
croppedImage(uint64(p2max-p2min+1):end,:,:) = [];

capImage = croppedImage;
end

