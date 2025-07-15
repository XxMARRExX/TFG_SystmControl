function plotTransformedPoints(points2D, pointsTransformed)
% PLOTTRANSFORMEDPOINTS Visualiza los puntos antes y después del cambio de sistema de referencia

    figure;
    tiledlayout(1,2, 'Padding', 'compact', 'TileSpacing', 'compact');

    % --- Original ---
    nexttile;
    plot(points2D(:,1), points2D(:,2), 'k.', 'MarkerSize', 6);
    title('Antes del cambio de S.R.');
    xlabel('X'); ylabel('Y'); axis equal;
    grid on;

    % --- Transformado ---
    nexttile;
    plot(pointsTransformed(:,1), pointsTransformed(:,2), 'b.', 'MarkerSize', 6);
    title('Después del cambio de S.R. (SVG)');
    xlabel('X_{SVG}'); ylabel('Y_{SVG}'); axis equal;
    grid on;
end
