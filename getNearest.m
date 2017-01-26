function [nearestNode, minDist] = getNearest(refLat, refLong, lat, long)

minDist = inf;

tol = 0.00001;

for i = 1:length(lat)
        dist = getDist([refLat, refLong], [lat(i), long(i)]);
        if (minDist > dist && dist > tol)
            minDist = dist;
            nearestNode = i;
        else
            %do nothing
        end
end
end