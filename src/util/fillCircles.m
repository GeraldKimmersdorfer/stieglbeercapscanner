function outImage = fillCircles(image, centers, radii)
    for n=1 : length(radii)    
        radius = radii(n, 1)*0.6;
        xc = centers(n, 2);
        yc = centers(n, 1);
        for ii = xc-int16(radius):xc+(int16(radius))
            for jj = yc-int16(radius):yc+(int16(radius))
                tempR = sqrt((double(ii) - double(xc)).^2 + (double(jj) - double(yc)).^2);
                if(tempR <= double(int16(radius)))
                    image(ii,jj)=0;
                end
            end
        end
    end
    outImage = image;
end