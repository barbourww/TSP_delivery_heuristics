function [tsp_sol, tspDist, trufflesSold, dep_cost] = build_deprec_tsp(warehouseID, restLocations, restNames, dayDemand, weekDayStr)
%Raphael Stern, October 18, 2016
%Code to construct a TSP solution using the modified insertion hueristic

    tic
    long = restLocations(:,1);
    lat = restLocations(:,2);
    dayDemand = [0; dayDemand];

    numLoc = length(lat);
    %C: TSP tour
    C = [];
    %V: set(all nodes) - set(TSP tour)
    V = 1:numLoc;
    V = V(V(dayDemand~=0)); %remove all restaurants that are closed (have no demand)
    %tracking of total tspDist
    tspDist = 0;
    
    %units: hr
    negotiationTime = 0.25;
    %units: mph
    driveSpeed = 5;
    %units: hr
    timeRemaining = 8;
    %units: lbs
    trufflesSold = 0;
    %units: $/lbs/hr
    depFac = 0.01;
    
    %
    %Step 1: build tour of two nodes
    %
    %initialize C as the start node
    C = [C, warehouseID];
    %remove node from remainder set
    V = V(V~=warehouseID);
    
    %Charge negotiation time at startRest
    %If using warehouse, don't charge negotiation time at starting location.
    %timeRemaining = timeRemaining - negotiationTime
    trufflesSold = trufflesSold + dayDemand(warehouseID);
    
    %disp('Building TSP solution starting at  the warehosue')
    %disp('-------------------------------------------')

    %First insertion - get the next nearest node (node 2)
    %nearestRest is a V index
    [nearestRest, ~] = getMostProfit(lat(warehouseID), long(warehouseID), lat(V), long(V), dayDemand(V), driveSpeed, negotiationTime);
    %change V index to restaurant ID
    nearestRestID = V(nearestRest);
    %append node 2 to the TSP tour
    C = [C, nearestRestID];
    %and remove it from the remainder
    V = V(V~=nearestRestID);
    %get distance to node 2
    d12 = getDist([lat(warehouseID), long(warehouseID)], [lat(nearestRestID), long(nearestRestID)]);
    tspDist = tspDist + d12;
    %charge the time to visit and negotiation time at 2
    timeRemaining = timeRemaining -  negotiationTime - d12/driveSpeed;
    trufflesSold = trufflesSold + dayDemand(nearestRestID);

    %Place starting city at end, since TSP is a circuit, and must end at starting location
    %Can change to end at JFK airport
    C = [C, warehouseID];
    d21 = getDist([lat(nearestRestID), long(nearestRestID)], [lat(warehouseID), long(warehouseID)]);
    tspDist = tspDist + d21;
    %charge drive time back to start node
    timeRemaining = timeRemaining - d21/driveSpeed;
    
    %Plot map for incremental buildout
    %plot_map(lat, long, dayOfWeek, C, warehouseID, weekDayStr, tspDist, trufflesSold, 'modifiedTSP')

    %Step 2: find closest node to insert
    while ~isempty(V)       
        %track best node to attempt insertion at the end of the selection search
        closestID = [];             %restaurant ID
        minCost = inf;              %"cost" of best next node (minimize bc demand in denominator)
        
        %track best location to insert selected node
        minInsertJ = inf;           %cost of insertion (minimize across existing TSP)
        insertionLocationJ = [];    %best insertion location
        
        %
        %selection
        %
        %for all nodes currently in the circuit, find the best node to attempt insertion
        for i=1:length(C)
            %loop amongst ranking of best nodes with respect to each node in C
            %for each one found, find its best insertion location and check feasibility
            %a feasible node must be found for each node in C so we ensure
            %   that we don't end up with an empty insertion
            breakFlag = false;
            while ~isempty(V) && ~breakFlag
                %node candidate selection
                [n_j, c_j] = getMostProfit(lat(C(i)), long(C(i)), lat(V), long(V), dayDemand(V), driveSpeed, negotiationTime);
                %n_j is an index of V
                %c_j is a "cost"
                neighborID = V(n_j);        %neighbor is a restaurant ID

                if c_j <= minCost
                    %Check that minimum insertion distance/time is feasible
                    %Step 3: find location to insert -- this is based on distance
                    minInsertK = inf;
                    minCostK = inf;
                    insertionLocationK = [];
                    
                    %
                    %insertion search
                    %
                    for k=1:length(C)-1
                        insertDist = getDist([lat(C(k)), long(C(k))], [lat(neighborID), long(neighborID)])...
                            + getDist([lat(neighborID), long(neighborID)], [lat(C(k+1)), long(C(k+1))])...
                            - getDist([lat(C(k)), long(C(k))], [lat(C(k+1)), long(C(k+1))]);
                        %generate proposed tour so depeciated cost can be calculated
                        C_p = [C(1:k), neighborID, C(k+1:end)];
                        insertCost = getDeprecCost(C_p, lat, long, dayDemand, driveSpeed, negotiationTime, depFac);
                       
                        %if improved from current best, update best
                        
                        %check insertion only on minimum distance
                        %if insertDist <= minInsertK
                        %    minInsertK = insertDist;
                        %    insertionLocationK = k;
                        %end 
                        
                        %check insertion cost, accounting for depreciation
                        if insertCost <= minCostK
                            minCostK = insertCost;
                            minInsertK = insertDist;
                            insertionLocationK = k;
                        end 
                    end
                    k=0;
                    
                    %Node J is feasible
                    if (minInsertK / driveSpeed) + negotiationTime < timeRemaining
                        %update best node J
                        minCost = c_j;
                        closestID = neighborID;
                        %update insertion info for best node J
                        minInsertJ = minInsertK;
                        insertionLocationJ = insertionLocationK;
                        breakFlag = true;
                    %Node J is infeasible
                    else
                        %take it out of V bc by triang ineqal it will never
                        %be feasible
                        V = V(V~=neighborID);
                        %continue with while loop
                    end
                else
                    breakFlag = true;
                end
            end
        end
        i=0;
        
        if ~isempty(insertionLocationJ)
            %Insert new node in "best" location
            C = [C(1:insertionLocationJ), closestID, C(insertionLocationJ+1:end)];
            V = V(V~=closestID);
            %d_a is old node connection
            d_a = getDist([lat(C(insertionLocationJ)), long(C(insertionLocationJ))], [lat(C(insertionLocationJ+2)), long(C(insertionLocationJ+2))]);
            %d_b is the link leading to the newly inserted node
            d_b = getDist([lat(C(insertionLocationJ)), long(C(insertionLocationJ))], [lat(closestID), long(closestID)]);
            %d_c is the link leading away from the newly inserted node
            d_c = getDist([lat(closestID), long(closestID)], [lat(C(insertionLocationJ+2)), long(C(insertionLocationJ+2))]);
            %add new distance to total TSP distance
            tspDist = tspDist + d_b + d_c - d_a;
            %charge additional drive time and negotiation time to timeRemaining
            timeRemaining = timeRemaining - negotiationTime - (d_b + d_c - d_a)/driveSpeed;
            trufflesSold = trufflesSold + dayDemand(closestID);
        end
	%Plot solution on a map
    %plot_map(lat, long, dayOfWeek, C, warehouseID, weekDayStr, tspDist, trufflesSold, 'modifiedTSP')    

    end
    
    %modify C to not include the warehouse, 
    %   and to shift by 1 b/c the warehouse is now artificially at index 1
    tsp_sol = C(2:end-1)-1;
    dep_cost = getDeprecCost(tsp_sol, lat, long, dayDemand, driveSpeed, negotiationTime, depFac);
    
%     disp('-------------------------------------------')
%     disp(sprintf('TSP solution found!'))
%     disp(sprintf('Total time to find solution: %3.2f seconds', toc))
%     disp(sprintf('Total distance traveled: %5f mi', tspDist))
%     allOneString = sprintf('%.0f,' , tsp_sol);
%     allOneString = allOneString(1:end-1);% strip final comma
%     disp(strcat('The best TSP routing is: ', allOneString))

    %Plot solution on a map
    plot_map(lat, long, dayDemand, C, warehouseID, weekDayStr, tspDist, trufflesSold, 'depreciatedTSP')
    
end


