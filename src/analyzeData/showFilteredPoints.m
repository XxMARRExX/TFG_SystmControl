function showFilteredPoints(allPoints, selectedPoints)
%SHOWFILTEREDPOINTS Displays a 2D comparison between original and filtered points.
%
%   Inputs:
%       allPoints      - Struct with fields 'x' and 'y' (original/unfiltered set).
%       selectedPoints - Struct with fields 'x' and 'y' (filtered subset).
%
%   This function opens a new figure showing both point sets with different colors.

    xAll = allPoints.x;
    yAll = allPoints.y;

    xSel = selectedPoints.x;
    ySel = selectedPoints.y;

    % Create figure and plot points
    figure;
    hold on;
    axis equal;
    grid on;

    scatter(xAll, yAll, 10, 'r.', 'DisplayName', 'All points');
    scatter(xSel, ySel, 10, 'b.', 'DisplayName', 'Selected points');

    % Axis labels and title
    xlabel('X coordinate');
    ylabel('Y coordinate');
    legend('Location', 'best');
    title('Filtered points from original set');
end
