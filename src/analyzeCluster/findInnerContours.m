function innerContours = findInnerContours(regionMap, clusters, pieceClusters, varargin)
% FINDINNERCONTOURS  Detecta contornos interiores (agujeros) usando el
%   "regionMap" (0 = fondo, 1 = pieza, 2 = agujero) y la nube de clusters
%   detectados por DBSCAN.
%
% Estrategia nueva
% ----------------
%  1.  Para cada componente conectado de la etiqueta 2 (agujero) se crea
%      un "anillo" exterior dilatando 20 px y restando el agujero.
%  2.  Entre todos los clusters se selecciona **el que más puntos tenga
%      dentro de ese anillo** ⇒ borde real del agujero.
%  3.  Ese único cluster se asocia a la pieza más cercana y se devuelve.

    p = inputParser;
    addParameter(p,'RingRadius',20);    % nº de píxeles para el anillo exterior
    addParameter(p,'MinPointsRing',20);  % mínimo de puntos del cluster que deben caer en el anillo
    parse(p,varargin{:});
    prm = p.Results;

    [H,W] = size(regionMap);
    numPieces   = numel(pieceClusters);

    %% Etiquetar cada agujero (región == 2)
    holeMask = regionMap == 2;
    if ~any(holeMask(:)), innerContours = cell(1,numPieces); return; end
    CC = bwconncomp(holeMask);

    % Crear estructura de salida
    innerContours = cell(1,numPieces);
    for p = 1:numPieces
        innerContours{p}.contornos = {};
        innerContours{p}.indices   = {};
    end

    seDil = strel('disk',prm.RingRadius);

    %% Para cada agujero independiente:
    for h = 1:CC.NumObjects
        holePix   = false(H,W);  holePix(CC.PixelIdxList{h}) = true;
        ringMask  = imdilate(holePix,seDil) & ~holePix;   % anillo exterior

        bestCnt   = 0;
        bestClIdx = -1;

        % Recorremos clusters y contamos cuántos puntos caen en el anillo
        for k = 1:numel(clusters)
            c = clusters{k};
            x = round(c.x);  y = round(c.y);
            valid = x>=1 & x<=W & y>=1 & y<=H;
            if ~any(valid), continue; end
            idx   = sub2ind([H W],y(valid),x(valid));
            ptsInRing = sum(ringMask(idx));
            if ptsInRing > bestCnt
                bestCnt   = ptsInRing;
                bestClIdx = k;
            end
        end

        % ¿Hay cluster válido?
        if bestCnt < prm.MinPointsRing || bestClIdx==-1, continue; end
        cluster = clusters{bestClIdx};

        %% Asociar cluster a la pieza más cercana (por centroide)
        cx = mean(cluster.x);  cy = mean(cluster.y);
        bestIdx = 1;  minD = inf;
        for p = 1:numPieces
            pc = pieceClusters{p};
            d  = hypot(mean(pc.x)-cx, mean(pc.y)-cy);
            if d < minD
                minD   = d;
                bestIdx = p;
            end
        end

        % Guardar
        innerContours{bestIdx}.contornos{end+1} = cluster;
        if isfield(cluster,'indices')
            innerContours{bestIdx}.indices{end+1} = cluster.indices;
        else
            innerContours{bestIdx}.indices{end+1} = NaN;
        end
    end
end
