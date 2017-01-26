%Function to find the most profitable (lowest
%((dist/speed)+negTime)/E[truffels] = time/$$
%returns a restaurant ID

function [mostProfitableNode, minCost] = getMostProfit(refLat, refLong, lat, long, expDemand, speed, negTime)

minCost = inf;
for i = 1:length(lat)
        cost = ((getDist([refLat, refLong], [lat(i), long(i)])/speed)+negTime)/expDemand(i);
        if (minCost > cost && cost > eps)
            minCost = cost;
            mostProfitableNode = i;
        else
            %do nothing
        end
end
end