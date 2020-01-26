function [binimg] = sobel(grayimg)
%SOBEL Applies a X and Y-Sobel filter to given grayscale image and detects
%edges. It returns then the edge detected image.
%   AUTHOR: Martin
%
%   parameters:
%       grayimg: the input image where the sobel filter should be executed.
%
%   output:
%       binimg: the result of sobel edge detection

temp=double(grayimg);

for i=1:size(temp,1)-2
    for j=1:size(temp,2)-2
        %Sobel mask for x-direction:
        Gx=((2*temp(i+2,j+1)+temp(i+2,j)+temp(i+2,j+2))-(2*temp(i,j+1)+temp(i,j)+temp(i,j+2)));
        %Sobel mask for y-direction:
        Gy=((2*temp(i+1,j+2)+temp(i,j+2)+temp(i+2,j+2))-(2*temp(i+1,j)+temp(i,j)+temp(i+2,j)));
     
        %The gradient of the image
        binimg(i,j)=sqrt(Gx.^2+Gy.^2);
    end
end

% apply threshold
thresh=175;
binimg=max(binimg, thresh);
binimg(binimg==round(thresh))=0;
binimg=uint8(binimg);

% remove noise from the image
binimg = removeSmallObjects(binimg, 20);

end

