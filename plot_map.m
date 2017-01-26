function plot_map(lat, long, dayOfWeek, C, startRestID, weekDayStr, tspDist, trufflesSold, solver)
        %Plot solution on a map
        currentMap = figure;
        hold on
        scatter(long(C(1)), lat(C(1)), 'MarkerEdgeColor', 'r')
        plot(long(dayOfWeek~=0), lat(dayOfWeek~=0), '.b', 'MarkerSize', 15)
        for i=1:length(C)-1
            plot([long(C(i)), long(C(i+1))], [lat(C(i)), lat(C(i+1))], '.-k', 'MarkerSize', 20)
        end
        plot_google_map
        scatter(long(C(1)), lat(C(1)), 'MarkerEdgeColor', 'r')
        annotation('textbox', 'String', ...
            sprintf('Day of week: %s \nTotal distance: %2.2f mi \nTotal truffles sold: %2.2f lbs', ...
            weekDayStr, tspDist, trufflesSold), 'Position', [0.15 0.7 0.1 0.1], ...
            'FitBoxToText','on', 'BackgroundColor', 'white')
        print(sprintf('maps/map_startNode_%i_%s_%i_%s', startRestID, weekDayStr, length(C), solver), '-dpng')
        close
end