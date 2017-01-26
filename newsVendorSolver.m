%(C) Raphael Stern, John LaVanne, William Barbour, November 2016
%Function to solve the newsvendor problem
function orderQuantity = newsVendorSolver(dailyDemand, dailyVar, price, cost, salvage) 

    totalDemand = sum(dailyDemand);
    totalVar = sum(dailyVar);

    orderQuantity = norminv((price - cost)/(price - salvage), totalDemand, sqrt(totalVar));
end