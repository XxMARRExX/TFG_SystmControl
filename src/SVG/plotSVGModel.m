function plotSVGModel(svgPaths)
% PLOTSVGMODEL Visualiza los paths de un SVG
%
%   plotSVGModel(svgPaths)

    figure; hold on; axis equal;
    title('Capa 9: LoadSVG');
    xlabel('X'); ylabel('Y');

    % Dibujar todos los paths del SVG en gris oscuro
    hPaths = gobjects(numel(svgPaths), 1);  % handles para los paths
    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            hPaths(i) = plot(path(:,1), path(:,2), 'Color', [0.3 0.3 0.3], 'LineWidth', 1);
        end
    end

    % Usar el primer path no vacío para la leyenda
    idxFirst = find(hPaths ~= 0, 1, 'first');
    if ~isempty(idxFirst)
        legend(hPaths(idxFirst), {'Paths SVG'}, 'Location', 'best');
    end
end
