function dist = getNYCdist(loc1, loc2)
    
    %radians, hard coded for NYC, from internet
    %equivalent to 28.911 degrees
    theta = 0.50459214;
    loc3 = [loc1(1), loc2(2)];

    d_12 = haversine(loc1, loc2);
    d_13 = haversine(loc1, loc3);
    d_23 = haversine(loc2, loc3);
    
    alpha = pi/2-atan(d_23/d_13);
    
    b = d_12*sin(alpha-theta);
    a = d_12*cos(alpha-theta);
    
    dist = abs(a)+abs(b);
end



