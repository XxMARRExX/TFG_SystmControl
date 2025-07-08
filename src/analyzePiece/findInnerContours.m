function innerContours = findInnerContours(regionMap, clusters, pieceClusters, varargin)
% FINDINNERCONTOURS Detecta contornos interiores (agujeros) usando regionMap y clusters.
%
%   Parámetros opcionales:
%       'RingRadius'     - Radio del anillo exterior (default: 20 px)
%       'MinPointsRing'  - Mínimo de puntos en anillo para validar cluster (default: 20)
%       'Verbose'        - Mostrar tiempos y logs (default: true)

    p = inputParser;
    addParameter(p, 'RingRadius', 20);
    addParameter(p, 'MinPointsRing', 20);
    addParameter(p, 'Verbose', true);
    parse(p, varargin{:});
    prm = p.Results;

    [H,W] = size(regionMap);
    numPieces = numel(pieceClusters);

    holeMask = regionMap == 2;

    if ~any(holeMask(:))
        if prm.Verbose
            fprintf('[INFO] No hay agujeros detectados en regionMap.\n');
        end
        innerContours = cell(1,numPieces);
        return;
    end

    fprintf('[INFO] Iniciando detección de agujeros...\n');
    t0 = tic;

    CC = bwconncomp(holeMask);
    fprintf('[INFO] Número de agujeros detectados: %d\n', CC.NumObjects);

    % Crear estructura de salida
    innerContours = cell(1, numPieces);
    for p = 1:numPieces
        innerContours{p}.contornos = {};
        innerContours{p}.indices = {};
    end

    seDil = strel('disk', prm.RingRadius);

    % Precalculo de coordenadas de clusters para evitar sub2ind dentro del bucle
    clusterCoords = cell(numel(clusters), 1);
    for k = 1:numel(clusters)
        c = clusters{k};
        x = round(c.x);
        y = round(c.y);
        valid = x >= 1 & x <= W & y >= 1 & y <= H;
        clusterCoords{k} = [x(valid), y(valid)];
    end
    fprintf('[INFO] Preprocesamiento de clusters completado.\n');
    toc(t0);

    %% Procesar cada agujero
    for h = 1:CC.NumObjects
        fprintf('\n[INFO] Procesando agujero %d/%d\n', h, CC.NumObjects);
        tHole = tic;

        % Crear anillo dilatado
        t1 = tic;
        holePix = false(H, W);
        holePix(CC.PixelIdxList{h}) = true;

        ringMask = imdilate(holePix, seDil) & ~holePix;
        fprintf('[DEBUG] -> Creación del anillo: %.3f s\n', toc(t1));

        % Buscar cluster con más puntos en el anillo
        t2 = tic;
        bestCnt = 0;
        bestClIdx = -1;

        for k = 1:numel(clusters)
            coords = clusterCoords{k};
            if isempty(coords), continue; end
            idx = sub2ind([H W], coords(:,2), coords(:,1));  % (y, x)
            ptsInRing = sum(ringMask(idx));


            if ptsInRing > bestCnt
                bestCnt = ptsInRing;
                bestClIdx = k;
            end
        end

        fprintf('[DEBUG] -> Selección de cluster: %.3f s (Mejor: %d puntos)\n', toc(t2), bestCnt);

        % ¿Cluster válido?
        if bestCnt < prm.MinPointsRing || bestClIdx == -1
            fprintf('[WARNING] -> Ningún cluster válido encontrado para este agujero.\n');
            continue;
        end

        cluster = clusters{bestClIdx};

        %% Asociar a pieza más cercana
        t3 = tic;
        cx = mean(cluster.x);
        cy = mean(cluster.y);
        bestIdx = 1;
        minD = inf;

        for p = 1:numPieces
            pc = pieceClusters{p};
            d = hypot(mean(pc.x) - cx, mean(pc.y) - cy);
            if d < minD
                minD = d;
                bestIdx = p;
            end
        end
        fprintf('[DEBUG] -> Asociación a pieza más cercana: %.3f s\n', toc(t3));

        % Guardar
        innerContours{bestIdx}.contornos{end+1} = cluster;

        if isfield(cluster, 'indices')
            innerContours{bestIdx}.indices{end+1} = cluster.indices;
        else
            innerContours{bestIdx}.indices{end+1} = NaN;
        end

        fprintf('[INFO] -> Procesamiento agujero %d COMPLETADO en %.3f s\n', h, toc(tHole));
    end

    fprintf('\n[INFO] Detección de agujeros COMPLETADA en %.3f s.\n', toc(t0));

end
