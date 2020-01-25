function scaled = binaryNearestNeighbourScale(unscaled, newsize)
%BINARYNEARESTNEIGHBOURSCALE Performs a rescaling operation on a
%logical/binary image
%
%   This function is a replacement for the Matlab imresize-function. It
%   takes a binary image and scales it down to a specified width and
%   height. The interpolation algorithm used is the neirest neighbour
%   algorithm which basically just calculates which point of the original
%   image-matrix is the closest to the respecting point in the transformed
%   image grid and colors this point accordingly by taking the average color of
%   all 4 possibilities.
%
%   A possible interpolation could be done by first applying a gaussian
%   filter to the image. Since its not necessary for the binary data though
%   this function will be kept as simple as it is.
%
%   @author: Gerald Kimmersdorfer, 01326608

img=double(unscaled);
oldsize=size(img);
newsize = double(newsize);
H = newsize(1);
W = newsize(2);

% Calculate Scaling factor
factor = (oldsize(1:2)-1)./(newsize-1);

% Create a rectangular grid in the new size
u = 0:newsize(1)-1;
v = 0:newsize(2)-1;
[U, V] = ndgrid(u, v);

% Creates two vectors that contain more or less the x- and y-addresses of
% the corresponding x- and y- addresses in the scaled image
u = u.*factor(1) + 1;
v = v.*factor(2) + 1;

% Compute the location of each new point relative to one nearest
% neighbor of the original image. The function fix just does a rounding
% towards zero.
U = U.*factor(1); U = U - fix(U);
V = V.*factor(2); V = V - fix(V);

% add a buffer row and column to prevent out of bounds errors
imgwrapper = zeros(oldsize(1)+1,oldsize(2)+1);
imgwrapper(1:oldsize(1),1:oldsize(2)) = img;
img = imgwrapper;

% Perform average interpolation of possible connected colors
N = (V-1) .* ((U-1) .* img(floor(u), floor(v), :) - ...
    U .* img(ceil(u), floor(v), :)) - ...
    V .* ((U-1).*img(floor(u), ceil(v), :) - ...
    U.*img(ceil(u), ceil(v), :));

% Since there could be different values than 0 or 1 at the edges now we
% have to binarize it again:
scaled = N > 0.5;
end