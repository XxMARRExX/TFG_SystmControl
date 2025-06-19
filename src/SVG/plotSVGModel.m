function plotSVGModel(svgPaths, exteriorContour)
% PLOTSVGMODEL Visualiza los paths de un SVG destacando el contorno exterior
%
%   plotSVGModel(svgPaths, exteriorContour)

    figure; hold on; axis equal;
    title('Capa 9: LoadSVG');
    xlabel('X'); ylabel('Y');

    % Dibujar todos los paths del SVG en gris claro
    hPaths = gobjects(numel(svgPaths), 1);  % handles para los paths
    for i = 1:numel(svgPaths)
        path = svgPaths{i};
        if ~isempty(path)
            hPaths(i) = plot(path(:,1), path(:,2), 'Color', [0.8 0.8 0.8], 'LineWidth', 0.75);
        end
    end

    % Dibujar contorno exterior en azul punteado
    hExterior = plot(exteriorContour(:,1), exteriorContour(:,2), 'b--', 'LineWidth', 2);

    % Usar el primer path solo para la leyenda
    idxFirst = find(hPaths ~= 0, 1, 'first');
    legend([hPaths(idxFirst), hExterior], {'Paths SVG', 'Contorno exterior'}, 'Location', 'best');
end
