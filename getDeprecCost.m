function costDeprec = getDeprecCost(cProp, lat, long, expDemand, speed, negTime, depFac)

dRun = 0.0;
cRun = 0.0;
for i = 1:length(cProp)-1
        dRun = dRun + getDist([lat(cProp(i)), long(cProp(i))], [lat(cProp(i+1)), long(cProp(i+1))]);
        cRun = cRun + (dRun * speed + negTime) * expDemand(cProp(i));
end
costDeprec = cRun * depFac;
end