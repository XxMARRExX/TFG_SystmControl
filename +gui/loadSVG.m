function plotSVGInApp(ax, svgPaths)
% gui.plotSVGInApp - Dibuja los caminos SVG sobre un UIAxes de App Designer.
%
%   plotSVGInApp(ax, svgPaths)
%
%   Inputs:
%     - ax       : UIAxes donde se desea dibujar.
%     - svgPaths : Cell array con trayectorias [Nx2] del SVG.

    % Validación básica
    if nargin < 2 || isempty(ax) || isempty(svgPaths)
        warning("Parámetros inválidos en gui.plotSVGInApp");
        return;
    end

    % Preparar el eje
    cla(ax);
    hold(ax, 'on');
    axis(ax, 'equal');
    title(ax, 'Modelo SVG cargado');
    xlabel(ax, 'X');
    ylabel(ax, 'Y');

    % Dibujar los caminos
    hPaths = gobjects(numel(svgPaths), 1);

    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            hPaths(i) = plot(ax, path(:,1), path(:,2), ...
                'Color', [0.3 0.3 0.3], ...
                'LineWidth', 1);
        end
    end

    % Añadir leyenda del primer path válido
    idxFirst = find(hPaths ~= 0, 1, 'first');
    if ~isempty(idxFirst)
        lgd = legend(ax, hPaths(idxFirst), {'SVG Paths'}, 'Location', 'northeast');
        set(lgd, 'Interpreter','none', 'Box','on');
    end

    hold(ax, 'off');
end
