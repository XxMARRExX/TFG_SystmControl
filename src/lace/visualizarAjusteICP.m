function visualizarAjusteICP(pointsAligned, svgPaths, varargin)
% VISUALIZARAJUSTEICP - Visualiza el ajuste de puntos alineados frente al modelo SVG
%
%   visualizarAjusteICP(pointsAligned, svgPaths)
%   visualizarAjusteICP(pointsAligned, svgPaths, 'Title', 'Título personalizado')
%
% Entradas:
%   - pointsAligned: Nx2 puntos alineados (ejemplo: salida de ICP)
%   - svgPaths: celda de paths del modelo SVG (output de importSVG)
%
% Opcional:
%   - 'Title': título de la gráfica (por defecto 'Ajuste fino mediante ICP 2D')

% Parámetros opcionales
p = inputParser;
addParameter(p, 'Title', 'Ajuste fino mediante ICP 2D');
parse(p, varargin{:});
plotTitle = p.Results.Title;

% Visualización
figure; hold on; axis equal; grid on;

% Puntos alineados
plot(pointsAligned(:,1), pointsAligned(:,2), 'r.', 'MarkerSize', 10);

% Paths del SVG
for i = 1:numel(svgPaths)
    plot(svgPaths{i}(:,1), svgPaths{i}(:,2), 'b-');
end

% Leyenda y etiquetas
legend('Detección ajustada fina (ICP)', 'Modelo SVG');
xlabel('X (mm)');
ylabel('Y (mm)');
title(plotTitle);

end
