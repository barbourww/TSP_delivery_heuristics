%(C) Raphael Stern, John LaVanne, William Barbour, November, 2016
%Main code to compute the TSP solution for a truffle salsemen in New York
%City. This code can be generalized for other problems.

%We employ three heuristics and compare the results of each...
%1. min-distance selection with min-distance insertion
%2. min-cost selection with min-distance insertion
%3. min-cost selection with depreciation-considered insertion

%Restaurant locations are those of the 60 1-, 2-, and 3-star Michelin
%   restaurants located in Manhattan.

%Assumptions:
%1) Manhattan distance is applicable on rotated coordinate plane (
%2) Expected amount of truffles (lbs) purchased by each restauraunt are
%   known from historical behavior
%3) 
clear all
close all
clc

%%% Parameters
trufflePrice = 10000;
truffleCost = 7000;
salvageValue = 6000;

load('restaurantLocations.mat')
load('restaurant_demand.mat')
load('storefrontLocations.mat')
warehouseID = 1;

%%% Find warehosue location -- solve facility location problem

weeklyDemand = Sunday+Monday+Tuesday+Wednesday+Thursday+Friday+Saturday;
[warehouseLong, warehouseLat] = facilityLocation(storefrontLongitude, storefrontLatitude, weeklyDemand);
Longitude = [warehouseLong; Longitude];
Latitude = [warehouseLat; Latitude];
disp('Step 1: Find the optimal warehouse location')

daysOfWeek = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};

%%% Build a TSP tour for every day of the week, using min cost insertion heuristic
disp('Step 2: Solve the TSP tours for each day of the week')
for weekDay = 1:length(daysOfWeek)
    disp(sprintf('Solving the TSP problem for %s using min dist', daysOfWeek{weekDay}))
    
    [tsp_sol, tspDist, trufflesSold, depCost] = ...
        build_min_insert_tsp(warehouseID, [Longitude, Latitude], ...
        Restaurant_name, eval(daysOfWeek{weekDay}), daysOfWeek{weekDay});
    
    % solve a newsvendor problem
    dayDemand = eval(daysOfWeek{weekDay});
    orderQuantity = newsVendorSolver(dayDemand(tsp_sol), 0.2*dayDemand(tsp_sol), trufflePrice, truffleCost, salvageValue);
    
    fileID = fopen(sprintf('output/tspsol_%s_minCost.txt', daysOfWeek{weekDay}), 'w');
    fprintf(fileID, 'TSP Solution:\n-------------------\n');
    fprintf(fileID, '%2i,  ', tsp_sol);
    fprintf(fileID, '\n-------------------\n\nRestaurant names:\n');
    fprintf(fileID, '%s\n', Restaurant_name{tsp_sol});
    fprintf(fileID, '\n\nTotal distance traveled: %2.2f mi\n', tspDist);
    fprintf(fileID, 'Total truffle sales: %2.2f lbs\n', trufflesSold);
    fprintf(fileID, 'Solving the newsvendor problem, order quantity: %2.2f lbs\n', orderQuantity);
    fprintf(fileID, 'Depreciated value: %2.2f $\n', depCost);
    fclose(fileID);
    
end


%%% Build a TSP tour for every day of the week, using modified insertion heuristic
for weekDay = 1:length(daysOfWeek)
    disp(sprintf('Solving the TSP problem for %s using modified heuristic', daysOfWeek{weekDay}))
    
    [tsp_sol, tspDist, trufflesSold, depCost] = ...
        build_tsp(warehouseID, [Longitude, Latitude], ...
        Restaurant_name, eval(daysOfWeek{weekDay}), daysOfWeek{weekDay});
    
    % solve a newsvendor problem
    dayDemand = eval(daysOfWeek{weekDay});
    orderQuantity = newsVendorSolver(dayDemand(tsp_sol), 0.2*dayDemand(tsp_sol), trufflePrice, truffleCost, salvageValue);
    
    fileID = fopen(sprintf('output/tspsol_%s_modifiedHeuristic.txt', daysOfWeek{weekDay}), 'w');
    fprintf(fileID, 'TSP Solution:\n-------------------\n');
    fprintf(fileID, '%2i,  ', tsp_sol);
    fprintf(fileID, '\n-------------------\n\nRestaurant names:\n');
    fprintf(fileID, '%s\n', Restaurant_name{tsp_sol});
    fprintf(fileID, '\n\nTotal distance traveled: %2.2f mi\n', tspDist);
    fprintf(fileID, 'Total truffle sales: %2.2f lbs\n', trufflesSold);
    fprintf(fileID, 'Solving the newsvendor problem, order quantity: %2.2f lbs\n', orderQuantity);
    fprintf(fileID, 'Depreciated value: %2.2f $\n', depCost);
    fclose(fileID);
end


%%% Build a TSP tour for every day of the week, using modified and depreciated 
%%% insertion heuristic
for weekDay = 1:length(daysOfWeek)
    disp(sprintf('Solving the TSP problem for %s using modified depreciated heuristic', daysOfWeek{weekDay}))
    
    [tsp_sol, tspDist, trufflesSold, depCost] = ...
        build_deprec_tsp(warehouseID, [Longitude, Latitude], ...
        Restaurant_name, eval(daysOfWeek{weekDay}), daysOfWeek{weekDay});
    
    % solve a newsvendor problem
    dayDemand = eval(daysOfWeek{weekDay});
    orderQuantity = newsVendorSolver(dayDemand(tsp_sol), 0.2*dayDemand(tsp_sol), trufflePrice, truffleCost, salvageValue);
    
    fileID = fopen(sprintf('output/tspsol_%s_modifiedDeprecHeuristic.txt', daysOfWeek{weekDay}), 'w');
    fprintf(fileID, 'TSP Solution:\n-------------------\n');
    fprintf(fileID, '%2i,  ', tsp_sol);
    fprintf(fileID, '\n-------------------\n\nRestaurant names:\n');
    fprintf(fileID, '%s\n', Restaurant_name{tsp_sol});
    fprintf(fileID, '\n\nTotal distance traveled: %2.2f mi\n', tspDist);
    fprintf(fileID, 'Total truffle sales: %2.2f lbs\n', trufflesSold);
    fprintf(fileID, 'Solving the newsvendor problem, order quantity: %2.2f lbs\n', orderQuantity);
    fprintf(fileID, 'Depreciated value: %2.2f $\n', depCost);
    fclose(fileID);
end

%%Print restuarants in TSP tour (in order)
%for i=1:length(tsp_sol)
%    disp([sprintf('%1d. ', i) Restaurant_name{tsp_sol(i)}])
%end

%%% Solve newsvendor problem
disp(sprintf('\n-------------------------------\nStep 3: Solve the newsvendor problem\n'))
