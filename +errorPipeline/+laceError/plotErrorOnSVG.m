function imgOut = plotErrorOnSVG(svgPaths, edgesWithError, threshold)
% plotErrorOnSVG() Visualizes the contour errors (exterior + interiors) aligned with the SVG model.
%
%   Inputs:
%       - svgPaths: cell array with SVG contours (in real coordinates)
%       - edgesWithError: struct with fields:
%           .exterior (x, y, e)
%           .innerContours{...} (x, y, e)
%       - threshold: base error threshold (mm)
%
%   Output:
%       - imgOut: RGB image of the generated figure (axes + legend + title)

    % --- Create invisible figure ---
    fig = figure('Visible', 'off');
    ax = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    title(ax, 'Error sobre cada punto detectado');
    xlabel(ax, 'x (mm)');
    ylabel(ax, 'y (mm)');

    % --- 1. Dibujar el modelo SVG (línea fina gris) ---
    for i = 1:numel(svgPaths)
        plot(ax, svgPaths{i}(:,1), svgPaths{i}(:,2), '-', ...
            'Color', [0 0 0], 'LineWidth', 0.5);
    end

    % --- 2. Unir puntos y errores (exterior + interiores) ---
    pts = [edgesWithError.exterior.x(:), edgesWithError.exterior.y(:)];
    e   = edgesWithError.exterior.e(:);

    if isfield(edgesWithError, 'innerContours')
        for i = 1:numel(edgesWithError.innerContours)
            ic = edgesWithError.innerContours{i};
            if ~isempty(ic)
                pts = [pts; ic.x(:), ic.y(:)]; %#ok<AGROW>
                e   = [e;   ic.e(:)];          %#ok<AGROW>
            end
        end
    end

    % --- 3. Crear colormap (verde, amarillo, naranja, rojo) ---
    cmap = [
        0.2 0.8 0.2;   % verde
        1.0 1.0 0.2;   % amarillo
        1.0 0.6 0.1;   % naranja
        1.0 0.2 0.2    % rojo
    ];

    % --- 4. Asignar color por nivel de error ---
    mag = abs(e);
    colorIdx = 4*ones(size(mag));
    colorIdx(mag <= 3*threshold) = 3;
    colorIdx(mag <= 2*threshold) = 2;
    colorIdx(mag <= threshold)   = 1;

    % --- 5. Dibujar todos los puntos de una vez ---
    scatter(ax, pts(:,1), pts(:,2), 20, cmap(colorIdx,:), 'filled');

    % --- 6. Leyenda con colores definidos ---
    hModel = plot(ax, NaN,NaN,'-','Color',[0 0 0],'LineWidth',0.5); % modelo SVG
    hGreen  = scatter(ax, NaN, NaN, 20, cmap(1,:), 'filled');
    hYellow = scatter(ax, NaN, NaN, 20, cmap(2,:), 'filled');
    hOrange = scatter(ax, NaN, NaN, 20, cmap(3,:), 'filled');
    hRed    = scatter(ax, NaN, NaN, 20, cmap(4,:), 'filled');

    legend(ax, [hModel, hGreen, hYellow, hOrange, hRed], { ...
        'Modelo SVG', ...
        sprintf('e ≤ %.1f mm (Dentro tolerancia)', threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', threshold, 2*threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', 2*threshold, 3*threshold), ...
        sprintf('e > %.1f mm', 3*threshold) ...
    }, 'Location', 'northeast');

    % --- Capture only axes content (avoid double frame) ---
    frame = getframe(ax);
    imgOut = frame.cdata;

    % --- Close figure ---
    close(fig);
end
