function pieceClusters = findInnerContours(regionMap, clusters, pieceClusters, varargin)
% FINDINNERCONTOURS (DEBUG) Detecta contornos interiores (agujeros),
% añade contornos interiores en pieceClusters{p}.interiores

    p = inputParser;
    addParameter(p,'RingRadius',20);
    addParameter(p,'MinPointsRing',20);
    addParameter(p,'MaxDistanceCluster',200);
    parse(p,varargin{:});
    prm = p.Results;

    [H,W] = size(regionMap);
    numPieces = numel(pieceClusters);

    % Asegurar campo 'interiores' vacío
    for pIdx = 1:numPieces
        pieceClusters{pIdx}.interiores = {};
    end

    % --- Detección de agujeros ---
    disp('Iniciando detección de agujeros...');
    holeMask = regionMap == 2;
    if ~any(holeMask(:))
        disp('No hay agujeros detectados.');
        return;
    end

    CC = bwconncomp(holeMask);
    disp(['Número de agujeros detectados: ', num2str(CC.NumObjects)]);
    seDil = strel('disk', prm.RingRadius);

    % --- Estadísticas iniciales ---
    disp(['Número total de clusters: ', num2str(numel(clusters))]);
    clusterSizes = cellfun(@(c) length(c.x), clusters);
    disp(['Tamaño medio de un cluster: ', num2str(mean(clusterSizes))]);
    disp(['Tamaño máximo de un cluster: ', num2str(max(clusterSizes))]);
    disp(['Parámetro RingRadius: ', num2str(prm.RingRadius)]);
    disp(['Parámetro MaxDistanceCluster: ', num2str(prm.MaxDistanceCluster)]);

    % --- Precalcular centroides de clusters ---
    tic;
    clusterCentroids = cellfun(@(c) [mean(c.x), mean(c.y)], clusters, 'UniformOutput', false);
    clusterCentroids = cat(1, clusterCentroids{:}); % Nx2 matriz
    disp(['Tiempo para precalcular centroides de clusters: ', num2str(toc), ' segundos']);
    
    statsHoles = regionprops(holeMask, 'Area');
    validHoles = find([statsHoles.Area] > 75); % Solo agujeros con más de 75 píxeles
    CC.PixelIdxList = CC.PixelIdxList(validHoles);
    CC.NumObjects = numel(validHoles);

    % --- Procesamiento de agujeros ---
    for h = 1:CC.NumObjects
        disp(['\nProcesando agujero ', num2str(h), ' de ', num2str(CC.NumObjects)]);
        holePix = false(H,W);
        holePix(CC.PixelIdxList{h}) = true;

        tic;
        ringMask = imdilate(holePix, seDil) & ~holePix; % Anillo alrededor del agujero
        disp([' - Tiempo para crear ringMask: ', num2str(toc), ' segundos']);

        % --- Centroide del agujero ---
        [hy, hx] = find(holePix);
        centerHoleX = mean(hx);
        centerHoleY = mean(hy);

        % --- Filtro rápido de clusters cercanos ---
        tic;
        dists = hypot(clusterCentroids(:,1) - centerHoleX, clusterCentroids(:,2) - centerHoleY);
        closeClustersIdx = find(dists <= prm.MaxDistanceCluster);
        disp([' - Clusters cercanos encontrados: ', num2str(length(closeClustersIdx))]);
        disp([' - Tiempo para calcular clusters cercanos: ', num2str(toc), ' segundos']);

        if isempty(closeClustersIdx)
            disp(' - No hay clusters cercanos para este agujero.');
            continue;
        end

        % --- Buscar el cluster que mejor se ajusta ---
        bestCnt = 0;
        bestClIdx = -1;

        tic;
        for k = closeClustersIdx'
            c = clusters{k};
            xv = round(c.x);
            yv = round(c.y);
            inBounds = xv >= 1 & xv <= W & yv >= 1 & yv <= H;
            idx = sub2ind([H W], yv(inBounds), xv(inBounds));
            ptsInRing = sum(ringMask(idx));
            if ptsInRing > bestCnt
                bestCnt = ptsInRing;
                bestClIdx = k;
            end
        end
        disp([' - Tiempo para evaluar clusters cercanos: ', num2str(toc), ' segundos']);
        disp([' - Mejor ajuste: ', num2str(bestCnt), ' puntos en el anillo']);

        if bestCnt < prm.MinPointsRing
            disp(' - Mejor cluster no tiene suficientes puntos, se ignora.');
            continue;
        end

        cluster = clusters{bestClIdx};

        % --- Asociar al cluster de pieza más cercano ---
        cx = mean(cluster.x);
        cy = mean(cluster.y);

        [~, bestPiece] = min(cellfun(@(pc) hypot(mean(pc.x)-cx, mean(pc.y)-cy), pieceClusters));
        pieceClusters{bestPiece}.interiores{end+1} = cluster;

        disp([' - Cluster asociado al contorno interior de la pieza ', num2str(bestPiece)]);
    end

    disp('Finalizado procesamiento de agujeros.');
end
