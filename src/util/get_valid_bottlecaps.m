function [bottlecaps] = get_valid_bottlecaps(bottlecaps, tolerance, biImg)
%GETVALIDBOTTLECAPS Calculates wheter or not the given circles represent bottlecaps
%and returns valid ones
%   Author: Levent
%   
%   around the outer circle we imagine an inner and outer bound to
%   calculate the white pixels inbetween, "to count the pixels of the
%   circle" if this has to few pixels there has probably been a mistake and
%   the outer bound is incorrect (= most likely due to image noise)
%
%   parameters:
%       bottlecaps = nx1 array of Bottlecap.m
%       tolerance = int (amount of tolerance zone)
%       biImg = sobel image
%
%   output:
%       bottlecaps = set Error Flag and message if anything goes wrong
    
    [imgX, imgY] = size(biImg);
    ind = 1;
    len = length(bottlecaps);
    
    for i=1:len
        p = bottlecaps(i).outerCenter;
        
        if(p(1) == 0 && p(2) == 0) 
            continue;
        end
        r = int32(bottlecaps(i).outerRadius);
        rT = r+tolerance;
        rWT = r-tolerance;
        
        minY = max(1,p(1)-rT);
        maxY = min(imgY,p(1)+rT);
        minX = max(1,p(2)-rT);
        maxX = min(imgX,p(2)+rT);
        
        a = maxX-minX;
        b = maxY-minY;
        
        c = abs(b-a); %check if horizontal and vertical diameters are about the same
        
        %area = a*b;
        
        sum = 0;
        for curY = minY:maxY
           for curX = minX:maxX
               curP(1) = double(curY);
               curP(2) = double(curX);
               dist = norm(curP-p);
               if((dist > rWT) && (dist < rT) && (biImg(curX, curY) > 0))
                   sum=sum+1;
               end
           end
        end
        
        umfang = pi*r*2;
        
        upperLimit = umfang*5; %weil die raender nicht nur 1 px breit sind (weil sobel filter runter scaling + fill circles
        lowerLimit = umfang*3;
        
        bcP = sum;
        
        if(upperLimit-bcP > 0 && bcP-lowerLimit > 0 && c < max(a, b)*0.05)       
           bottlecaps(i).error = false;
        else
           bottlecaps(i).error = true;
           bottlecaps(i).errormsg = 'Outer Boundary wasnt valid.';
        end
    end
end

