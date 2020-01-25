function newImg = removeSmallObjects(img, minSize)
%REMOVESMALLOBJECTS Returns an image that is the same as the input image,
%but it removes objects from the picture which are smaller than the minSize
%parameter in pixel.
%   AUTHOR: Martin
%
%   parameter:
%       img: the input img with noise
%       minSize: the minimum size that are allowed for objects in the
%       image
%   
%   output:
%       newImg: the result image, where all small objects are removed

A = img;

visited = false(size(A));
[rows,cols] = size(A);
B = zeros(rows,cols);
ID_counter = 1;

% creates a new image the same size as the input image and marks the pixel
% of the found objects with the corresponding object id
for row = 1 : rows
    for col = 1 : cols
        % mark as visited if not 0
        if A(row,col) == 0
            visited(row,col) = true;

        % if already visited
        elseif visited(row,col)
            continue;

        else
            stack = [row col];
            
            while ~isempty(stack)
                loc = stack(1,:);
                stack(1,:) = [];

                if visited(loc(1),loc(2))
                    continue;
                end

                visited(loc(1),loc(2)) = true;
                B(loc(1),loc(2)) = ID_counter;

                [locs_y, locs_x] = meshgrid(loc(2)-1:loc(2)+1, loc(1)-1:loc(1)+1);
                locs_y = locs_y(:);
                locs_x = locs_x(:);

                out_of_bounds = locs_x < 1 | locs_x > rows | locs_y < 1 | locs_y > cols;

                locs_y(out_of_bounds) = [];
                locs_x(out_of_bounds) = [];

                is_visited = visited(sub2ind([rows cols], locs_x, locs_y));

                locs_y(is_visited) = [];
                locs_x(is_visited) = [];

                is_1 = A(sub2ind([rows cols], locs_x, locs_y));
                locs_y(~is_1) = [];
                locs_x(~is_1) = [];

                stack = [stack; [locs_x locs_y]];
            end

            ID_counter = ID_counter + 1;
        end
    end
end

% checks the amount of pixels for each object
for i = 1 : ID_counter
    counter = 0;
    for row = 1 : rows
        for col = 1 : cols
            if (B(row, col) == i)
                counter = counter + 1;
            end
        end
    end
    
    % if the size of the object is to small, remove it
    if (counter < minSize)
        B(B == i) = 0;
    end
end

B(B ~= 0) = 1;

newImg = B;

end