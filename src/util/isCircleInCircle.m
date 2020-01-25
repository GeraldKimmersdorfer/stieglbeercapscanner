function res = isCircleInCircle(x1, y1, r1, x2, y2, r2)
%ISCIRCLEINCIRCLE Checks if circle2 is contained by circle1 and returns
%true if yes.
%
%   source found @https://stackoverflow.com/questions/33490334/check-if-a-circle-is-contained-in-another-circle
%
%   @author: Gerald Kimmersdorfer
res = false;
d = sqrt( (x2-x1)^2 + (y2-y1)^2 );
if r1 > ( d + r2 )
    res = true;
end
end

