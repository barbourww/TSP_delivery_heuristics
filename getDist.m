function dist = getDist(loc1, loc2)
%Gives the Manhatan distance between loc1 and loc2 ([long1, lat1] and
%[long2, lat2]).

%uncomment to use manhattan distance
%loc3 = [loc1(1), loc2(2)]; %a fictitions location
%dist = haversine(loc1, loc3) + haversine(loc3, loc2);

%uncomment to use euclidean distance
%dist = haversine(loc1, loc2);

%unbcomment to use NYC road dist
dist = getNYCdist(loc1, loc2);
end