function cleanClusters = cleanClustersByMorphology(clusters, imgSize, minMeanDist)
% CLEANCLUSTERSBYMORPHOLOGY Conserva clusters dispersos (posibles contornos interiores).
%
%   cleanClusters = cleanClustersByMorphology(clusters, imgSize, minMeanDist)
%
%   Entrada:
%       - clusters: celda de clusters con campos .x y .y
%       - imgSize: tamaño de la imagen
%       - minMeanDist: distancia media mínima para considerar cluster disperso y válido
%
%   Salida:
%       - cleanClusters: celda con clusters dispersos (posibles contornos interiores)

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
