%(C) Raphael Stern, John LaVanne, William Barbour, November 2016
%Code used to solve the facility locaiton problem

%clear all
%close all
%clc
function [warehosueLong, warehouseLat] = facilityLocation(storefrontLongitude, storefrontLatitude, totalWeeklyDemand)
    %Load data
    load('restaurantLocations.mat')
    load('storefrontLocations.mat')
    load('restaurant_demand.mat')

    %Set parameters
    numRest = length(Latitude);
    numStore = length(storefrontLatitude);

    %Compute demand -- summing expected demand over all days
    %h = Sunday+Monday+Tuesday+Wednesday+Thursday+Friday+Saturday;
    h = totalWeeklyDemand;

    %Compute distance matrix
    d = [];
    for restID = 1:numRest
        for storeID = 1:numStore
           d(storeID, restID) = getDist([Latitude(restID), Longitude(restID)],...
               [storefrontLatitude(storeID), storefrontLongitude(storeID)]); 
        end
    end

    %Build objective coefficent matrix
    f=zeros(numStore, 1);
    for i=1:numStore
        for j=1:numRest
            f(i) = f(i)+d(i,j)*h(j);
        end
    end

    %Build constraings
    A_eq = ones(1, numStore);
    b_eq = 1;
    lb = zeros(numStore, 1);
    ub = ones(numStore, 1);
    A = [];
    b = [];
    intcon = 1:numStore;

    %Solve LP
    [x, ~, ~, ~] = intlinprog(f, intcon, A, b, A_eq, b_eq, lb, ub);

    figure
    hold on
    plot(Longitude, Latitude, '.b', 'MarkerSize', 25)
    plot(storefrontLongitude, storefrontLatitude, '^g', 'MarkerSize', 10, 'MarkerFaceColor', [0, 0.8, 0], 'MarkerEdgeColor', [0, 0.8, 0])
    plot(storefrontLongitude(logical(x)), storefrontLatitude(logical(x)), 'p', 'MarkerEdgeColor',...
        'r', 'MarkerFaceColor', 'r', 'MarkerSize', 18)
    legend('Restaurants', 'Possible storefronts', 'Selected storefront')
    plot_google_map
    
    print('maps/facility_location_map', '-dpng')
    close
   

    clc
    disp('------------------------------------------------------')
    disp('Solving for optimal storefront location')
    disp(sprintf('The optimal location is facility numbner %i', find(x)))
    disp('------------------------------------------------------')

    warehosueLong = storefrontLongitude(logical(x));
    warehouseLat = storefrontLatitude(logical(x));

end

