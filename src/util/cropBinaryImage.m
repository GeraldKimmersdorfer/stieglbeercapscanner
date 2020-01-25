function img = cropBinaryImage(img, tosquare)
%CROPBINARYIMAGE Removes all black borders from a binary image
%
% @author: Gerald Kimmersdorfer

if ~exist("tosquare", "var"), tosquare = false; end

[r, c] = find(img);
img = img(min(r):max(r), min(c):max(c));
if tosquare
    imgsize = size(img);
    newimg = zeros(max(imgsize));
    if imgsize(2) > imgsize(1)
        of = floor((imgsize(2) - imgsize(1)) / 2) + 1;
        newimg(of:(of + imgsize(1) - 1), :) = img;
    else
        of = floor((imgsize(1) - imgsize(2)) / 2) + 1;
        newimg(:, of:(of + imgsize(2) - 1)) = img;
    end
    img = newimg;
end
img = logical(img);
end

