function plotErrorOnOriginalImage(originalImage, svgPaths, edgesWithError, threshold)
% plotErrorOnOriginalImage() Displays the detected points (with error)
% and the SVG model over the original image.
%
%   Inputs:
%       - originalImage: matrix (grayscale or RGB) of the original piece image.
%       - svgPaths: cell array where each cell is an [Nx2] matrix (in the
%                   same coordinate system as the image).
%       - edgesWithError: struct containing:
%             .exterior (x, y, e)
%             .innerContours{...} (x, y, e)
%       - threshold: base error tolerance (e.g. in mm)
%
%   Overlays:
%       • original image (background)
%       • SVG model (thin light-blue line)
%       • detected points (colored by error magnitude, drawn above)

    figure('Color', 'w');
    imshow(originalImage, 'InitialMagnification', 'fit');
    hold on;
    title('Error de los puntos sobre la imagen original');
    axis on;
    grid off;

    % --- 1. Dibujar primero el modelo SVG (fondo, color azul claro) ---
    svgColor = [0.26 0.65 0.96];  % Azul claro (#42a5f5)
    for i = 1:numel(svgPaths)
        P = svgPaths{i};
        if isempty(P) || all(isnan(P(:)))
            continue;
        end
        plot(P(:,1), P(:,2), '-', ...
            'Color', svgColor, ...
            'LineWidth', 1.3);
    end

    % --- 2. Reunir todos los puntos con error ---
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

    % --- 3. Definir colormap discreto (verde → amarillo → naranja → rojo) ---
    cmap = [
        0.2 0.8 0.2;   % verde
        1.0 1.0 0.2;   % amarillo
        1.0 0.6 0.1;   % naranja
        1.0 0.2 0.2    % rojo
    ];

    % --- 4. Asignar color según nivel de error ---
    mag = abs(e);
    colorIdx = 4*ones(size(mag));
    colorIdx(mag <= 3*threshold) = 3;
    colorIdx(mag <= 2*threshold) = 2;
    colorIdx(mag <= threshold)   = 1;

    % --- 5. Dibujar los puntos (encima del SVG) ---
    h = scatter(pts(:,1), pts(:,2), 22, cmap(colorIdx,:), 'filled', ...
                'MarkerEdgeColor', 'k', 'MarkerEdgeAlpha', 0.25);
    h.UserData = e;

    % --- 6. Datacursor personalizado para ver el error ---
    dcm = datacursormode(gcf);
    dcm.UpdateFcn = @(~, event_obj) customTooltip(event_obj, h);

    % --- 7. Leyenda ---
    hModel  = plot(NaN,NaN,'-', 'Color',svgColor, 'LineWidth',1.3);
    hGreen  = scatter(NaN, NaN, 22, cmap(1,:), 'filled');
    hYellow = scatter(NaN, NaN, 22, cmap(2,:), 'filled');
    hOrange = scatter(NaN, NaN, 22, cmap(3,:), 'filled');
    hRed    = scatter(NaN, NaN, 22, cmap(4,:), 'filled');

    legend([hModel, hGreen, hYellow, hOrange, hRed], { ...
        'Modelo SVG', ...
        sprintf('e ≤ %.1f mm (Dentro tolerancia)', threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', threshold, 2*threshold), ...
        sprintf('%.1f < e ≤ %.1f mm', 2*threshold, 3*threshold), ...
        sprintf('e > %.1f mm', 3*threshold) ...
    }, 'Location', 'southeast');
end


function txt = customTooltip(event_obj, h)
    pos = get(event_obj, 'Position');
    idx = get(event_obj, 'DataIndex');
    e = h.UserData(idx);
    txt = {
        sprintf('X: %.2f', pos(1))
        sprintf('Y: %.2f', pos(2))
        sprintf('Error: %.3f mm', e)
    };
end
