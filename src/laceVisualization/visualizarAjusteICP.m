function visualizarAjusteICP(pointsAligned, svgPaths, innerContours, varargin)
% VISUALIZARAJUSTEICP - Visualiza el ajuste de puntos alineados frente al modelo SVG,
% incluyendo los contornos internos si se proporcionan.
%
%   visualizarAjusteICP(pointsAligned, svgPaths, innerContours)
%   visualizarAjusteICP(..., 'Title', 'Título personalizado')
%
% Entradas:
%   - pointsAligned: Nx2 puntos alineados (salida de ICP)
%   - svgPaths: celda de paths del modelo SVG (output de importSVG)
%   - innerContours: celda de structs con campos .x y .y (contornos internos alineados)
%
% Opcional:
%   - 'Title': título de la gráfica (por defecto 'Ajuste ICP con contornos internos')

    % Parámetros opcionales
    p = inputParser;
    addParameter(p, 'Title', 'Ajuste ICP con contornos internos');
    parse(p, varargin{:});
    plotTitle = p.Results.Title;

    % Visualización
    figure; hold on; axis equal; grid on;

    % Puntos alineados (contorno exterior)
    plot(pointsAligned(:,1), pointsAligned(:,2), 'r.', 'MarkerSize', 10);

    % Paths del SVG
    for i = 1:numel(svgPaths)
        plot(svgPaths{i}(:,1), svgPaths{i}(:,2), 'b-');
    end

    % Contornos internos, si se proporcionan
    if ~isempty(innerContours)
        for i = 1:numel(innerContours)
            c = innerContours{i};
            plot(c.x, c.y, 'r.', 'MarkerSize', 6);
        end
    end

    % Leyenda y etiquetas
    legend({'Contorno exterior alineado', 'Modelo SVG', 'Contornos internos'}, ...
           'Location', 'Best');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    title(plotTitle);
end
