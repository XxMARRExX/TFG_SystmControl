function showSVGOnCanvas(canvas, svgPaths)
% showSVGOnCanvas() Displays SVG paths directly on a UIAxes canvas.
%
%   Inputs:
%       - canvas: UIAxes where the SVG will be plotted
%       - svgPaths: cell array of Nx2 double paths (from readSVG)

    % Limpiar lienzo
    cla(canvas);
    hold(canvas, 'on');
    axis(canvas, 'equal');
    grid(canvas, 'on');
    title(canvas, 'Modelo SVG cargado');
    xlabel(canvas, 'X');
    ylabel(canvas, 'Y');

    % Dibujar todos los paths
    hPaths = gobjects(numel(svgPaths), 1);
    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            hPaths(i) = plot(canvas, path(:,1), path(:,2), ...
                'Color', [0.3 0.3 0.3], ...
                'LineWidth', 1);
        end
    end

    % Ajustar límites para ocupar el canvas completo
    allPoints = vertcat(svgPaths{:});
    if ~isempty(allPoints)
        xmin = min(allPoints(:,1));
        xmax = max(allPoints(:,1));
        ymin = min(allPoints(:,2));
        ymax = max(allPoints(:,2));

        margin = 0.05;
        dx = xmax - xmin;
        dy = ymax - ymin;

        canvas.XLim = [xmin - margin*dx, xmax + margin*dx];
        canvas.YLim = [ymin - margin*dy, ymax + margin*dy];
    end

    % Leyenda opcional
    idxFirst = find(hPaths ~= 0, 1, 'first');
    if ~isempty(idxFirst)
        legend(canvas, hPaths(idxFirst), {'SVG Paths'}, ...
            'Location', 'northeast', 'Box', 'on', 'Interpreter', 'none');
    end

    hold(canvas, 'off');
end
