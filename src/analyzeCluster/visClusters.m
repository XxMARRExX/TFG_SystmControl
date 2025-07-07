function visEdgeClusters(img, clusters)
% VISEDGECLUSTERS Muestra una imagen con los clusters de bordes coloreados (sin mostrar ruido).
%
%   Entrada:
%     - img: imagen original (grayscale o RGB)
%     - clusters: celda de estructuras con campos .x y .y (uno por cluster)
%     - ~: parámetro ignorado (antes era noisePoints)

    figure;
    imshow(img); hold on;
    title('Clusters de bordes detectados (DBSCAN)');
    
    cmap = lines(numel(clusters));  % Colores distintos por cluster
    
    % Dibujar cada cluster
    for i = 1:numel(clusters)
        e = clusters{i};
        plot(e.x, e.y, '.', 'Color', cmap(i,:), 'DisplayName', sprintf('Cluster %d', i));
    end

    hold off;
end
