function plotErrorOnSVG(svgPaths, edgesWithError, threshold)
% PLOTERRORONSVG Visualiza los errores del contorno exterior + interiores alineados con el SVG.
%
%   - svgPaths: cell array con los contornos del SVG (en coordenadas reales)
%   - edgesWithError: struct con:
%         .exterior (x, y, e)
%         .innerContours{...} (x, y, e)
%   - threshold: umbral base de error (mm)

    figure;
    hold on;
    axis equal;
    grid on;
    title('Error sobre cada punto detectado');
    xlabel('x (mm)');
    ylabel('y (mm)');

    % 1. Dibujar el modelo SVG (línea fina gris)
    for i = 1:numel(svgPaths)
        plot(svgPaths{i}(:,1), svgPaths{i}(:,2), '-', ...
            'Color', [0 0 0], 'LineWidth', 0.5);
    end

    % 2. Unir puntos y errores (exterior + interiores)
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

    % 3. Crear colormap (verde, amarillo, naranja, rojo)
    cmap = [
        0.2 0.8 0.2;   % verde
        1.0 1.0 0.2;   % amarillo
        1.0 0.6 0.1;   % naranja
        1.0 0.2 0.2    % rojo
    ];

    % 4. Asignar color por nivel de error (por defecto: rojo)
    mag = abs(e);
    colorIdx = 4*ones(size(mag));
    colorIdx(mag <= 3*threshold) = 3;
    colorIdx(mag <= 2*threshold) = 2;
    colorIdx(mag <= threshold)   = 1;

    % 5. Dibujar todos los puntos de una vez
    h = scatter(pts(:,1), pts(:,2), 20, cmap(colorIdx,:), 'filled');
    h.UserData = e;
    
    % Crear datacursor personalizado
    dcm = datacursormode(gcf);
    dcm.UpdateFcn = @(obj, event_obj) customTooltip(event_obj, h);


    % 6. Leyenda con colores definidos
    hModel = plot(NaN,NaN,'-','Color',[0 0 0],'LineWidth',0.5); % modelo SVG

    hGreen  = scatter(NaN, NaN, 20, cmap(1,:), 'filled');
    hYellow = scatter(NaN, NaN, 20, cmap(2,:), 'filled');
    hOrange = scatter(NaN, NaN, 20, cmap(3,:), 'filled');
    hRed    = scatter(NaN, NaN, 20, cmap(4,:), 'filled');

    legend([hModel, hGreen, hYellow, hOrange, hRed], { ...
        'Modelo SVG', ...
        sprintf('e ≤ %.1f mm (Dentro tolerancia)', threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', threshold, 2*threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', 2*threshold, 3*threshold), ...
        sprintf('e > %.1f mm', 3*threshold) ...
    }, 'Location', 'northeast');
end


function txt = customTooltip(event_obj, h)
    % Coordenadas
    pos = get(event_obj, 'Position');
    idx = get(event_obj, 'DataIndex');
    
    % Recuperar el error del UserData
    e = h.UserData(idx);
    
    % Texto del datatip
    txt = {
        ['X: ', num2str(pos(1), '%.3f')]
        ['Y: ', num2str(pos(2), '%.3f')]
        ['Error (e): ', num2str(e, '%.3f'), ' mm']
    };
end
