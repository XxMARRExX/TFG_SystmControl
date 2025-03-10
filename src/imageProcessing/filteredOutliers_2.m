function [x_filtrado, y_filtrado, idx_valido] = filterOutliers_2(x, y, plotDensity)
    % Filtra puntos eliminando intervalos de X con demasiados puntos
    
    % 1. Definir parámetros del filtrado
    binSize = 10;  % Tamaño del intervalo en X (5 píxeles)
    maxPointsPerBin = 40;  % Máximo número de puntos permitidos por intervalo

    % 2. Crear histograma de densidad en X
    [counts, edges, binIdx] = histcounts(x, 'BinWidth', binSize);

    % 3. Marcar intervalos donde hay demasiados puntos
    binsToRemove = find(counts > maxPointsPerBin);

    % 4. Crear máscara para eliminar puntos en bins no válidos
    idx_valido = true(size(x));  % Inicialmente, todos los puntos son válidos

    for i = 1:length(binsToRemove)
        binID = binsToRemove(i);
        x_min = edges(binID);
        x_max = edges(binID + 1);
        idx_bin = (x >= x_min) & (x < x_max);
        idx_valido(idx_bin) = false;  % Eliminar puntos en bins sobrecargados
    end

    % 5. Filtrar los puntos finales
    x_filtrado = x(idx_valido);
    y_filtrado = y(idx_valido);

    % 6. Visualización opcional del filtrado
    if plotDensity
        figure;
        scatter(x, y, 'r.'); hold on;  % Puntos originales (rojo)
        scatter(x_filtrado, y_filtrado, 'b.');  % Puntos filtrados (azul)
        xlabel('Coordenada X');
        ylabel('Coordenada Y');
        legend('Puntos Originales', 'Puntos Filtrados');
        title('Filtrado basado en límites de densidad en X');
        grid on;
    end
end
