function filteredClusters = filterClustersBySizeDistribution(clusters, varargin)
% FILTERCLUSTERSBYSIZEDISTRIBUTION Filtra clusters basados en su tamaño agrupado
%
% Esta función agrupa los clusters en dos grupos (ruido y reales) según su
% número de puntos. Si se detecta homogeneidad entre tamaños → se aceptan todos.
%
% Entradas:
%   clusters - Cell array de clusters (cada uno debe tener .x y .y)
%
% Parámetros opcionales:
%   'HomogeneityThreshold' - Diferencia mínima entre grupos para considerar homogéneo (default: 20)
%   'Verbose'              - Mostrar información de depuración (default: true)
%
% Salidas:
%   filteredClusters - Clusters filtrados (ruido eliminado si hay patrón claro)

    p = inputParser;
    addParameter(p, 'HomogeneityThreshold', 50);
    addParameter(p, 'Verbose', true);
    parse(p, varargin{:});
    prm = p.Results;

    numClusters = numel(clusters);
    clusterSizes = zeros(1, numClusters);

    % Calcular tamaños
    for k = 1:numClusters
        clusterSizes(k) = numel(clusters{k}.x);
    end

    if prm.Verbose
        fprintf('[INFO] Analizando %d clusters\n', numClusters);
    end

    if numClusters <= 2
        % Muy pocos clusters → aceptar todos directamente
        if prm.Verbose
            fprintf('[INFO] Pocos clusters → se aceptan todos.\n');
        end
        filteredClusters = clusters;
        return;
    end

    % Agrupar tamaños → k-means (2 grupos)
    [labels, centers] = kmeans(clusterSizes', 2, 'Replicates', 5);

    % Ordenar centros
    [centers, idxSort] = sort(centers);
    labelsMapped = zeros(size(labels));
    labelsMapped(labels == idxSort(1)) = 1; % Grupo pequeño
    labelsMapped(labels == idxSort(2)) = 2; % Grupo grande

    diffCenters = abs(centers(2) - centers(1));

    if prm.Verbose
        fprintf('[INFO] Tamaño medio grupos → Pequeños: %.1f | Grandes: %.1f | Diferencia: %.1f\n', ...
                centers(1), centers(2), diffCenters);
    end

    % Decidir → homogéneo o patrón claro de ruido
    if diffCenters < prm.HomogeneityThreshold
        % Homogéneo → aceptar todos
        if prm.Verbose
            fprintf('[INFO] Tamaños homogéneos → se aceptan todos los clusters.\n');
        end
        filteredClusters = clusters;
    else
        % Hay patrón claro → eliminar los pequeños
        filteredClusters = {};
        for k = 1:numClusters
            if labelsMapped(k) == 2 % Solo los del grupo grande
                filteredClusters{end+1} = clusters{k};
            else
                if prm.Verbose
                    fprintf('[DEBUG] Cluster %d eliminado por tamaño pequeño (%d puntos)\n', ...
                            k, clusterSizes(k));
                end
            end
        end
        if prm.Verbose
            fprintf('[INFO] %d clusters aceptados tras filtrado.\n', numel(filteredClusters));
        end
    end
end
