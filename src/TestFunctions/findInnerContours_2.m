function cleanClusters = findInnerContours_2(clusters, imgSize, refImgSize, minMeanDistBase)
% CLEANCLUSTERSBYMORPHOLOGY Filtra clusters dispersos con umbral adaptativo
%
%   cleanClusters = cleanClustersByMorphology(clusters, imgSize, refImgSize, minMeanDistBase)
%
%   Entrada:
%       - clusters: celda de clusters con campos .x y .y
%       - imgSize: tamaño de la imagen actual [alto, ancho]
%       - refImgSize: tamaño de la imagen de referencia [alto, ancho]
%       - minMeanDistBase: umbral base para la imagen de referencia
%
%   Salida:
%       - cleanClusters: celda con clusters dispersos (posibles contornos interiores)

    % Calcular escalado basado en diagonal
    diagRef = norm(refImgSize);
    diagImg = norm(imgSize);
    scale = diagImg / diagRef;
    
    % Umbral adaptado
    minMeanDist = minMeanDistBase * scale;

    cleanClusters = {};
    
    for i = 1:numel(clusters)
        cluster = clusters{i};
        x = cluster.x(:);
        y = cluster.y(:);
        
        if numel(x) < 3
            continue;
        end
        
        % Calcular dispersión
        D = pdist([x y]);
        meanDist = mean(D);
        
        if meanDist < minMeanDist
            % Muy denso -> probablemente ruido -> eliminar
            continue;
        end
        
        % Disperso -> probablemente contorno interior -> conservar
        cleanClusters{end+1} = cluster;
    end
end