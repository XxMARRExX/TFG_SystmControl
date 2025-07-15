function edgesRot = rotateDetectedEdges180(edges)
% ROTATEDETECTEDGES180  Rota todos los puntos detectados 180° (π rad)
%                       alrededor del centroide global.
%
%   edgesRot = rotateDetectedEdges180(edges)
%
% edges : estructura con el formato que usas en tu pipeline:
%           • edges.exterior.x , edges.exterior.y
%           • edges.innerContours{h}.x , .y
%
% edgesRot : estructura del mismo formato, ya rotada 180°.
%
%  La rotación 180° es una simetría central:  P' = 2·c - P
%  donde c es el centroide de TODOS los puntos detectados.
% -------------------------------------------------------------------------

    % ---------- 1. reunir TODOS los puntos para sacar el centroide -------
    Px = edges.exterior.x(:);
    Py = edges.exterior.y(:);
    ctr = [mean(Px) , mean(Py)];     % centroide global [cx cy]

    % ---------- 2. aplicar simetría central (rotación 180°) -------------
    rot = @(v) 2*ctr(1) - v;         % helper para x; análogo para y

    edgesRot = edges;                % copiar metadatos

    % exterior
    edgesRot.exterior.x = rot(edges.exterior.x);
    edgesRot.exterior.y = 2*ctr(2) - edges.exterior.y;

    % interiores
    for k = 1:numel(edges.innerContours)
        ic = edges.innerContours{k};
        if isempty(ic), continue, end
        ic.x = rot(ic.x);
        ic.y = 2*ctr(2) - ic.y;
        edgesRot.innerContours{k} = ic;
    end
end
