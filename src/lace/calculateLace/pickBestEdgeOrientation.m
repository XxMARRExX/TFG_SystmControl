function [edgesBest, bestOriDeg, bestRMSE] = pickBestEdgeOrientation(edges, svgPaths, nSamples)
% PICKBESTEDGEORIENTATION  Elige entre 0° y 180° según el RMSE con el SVG.
%
%   [edgesBest, bestOriDeg, bestRMSE] = pickBestEdgeOrientation(edges, svgPaths, nSamples)
%
% edges     : estructura de bordes detectados (tal y como la usas).
% svgPaths  : cell array con los paths del modelo SVG.
% nSamples  : nº de muestras por contorno SVG (def = 400).
%
% Devuelve
%   edgesBest  : misma estructura, rotada 180° solo si mejora el RMSE.
%   bestOriDeg : 0  o  180  (orientación ganadora).
%   bestRMSE   : RMSE (sin rotación extra) con esa orientación.
%
% La métrica de error usa solo traslación (centroide-a-centroide) para que
% la inversión 180° sea realmente distinguible.
% -------------------------------------------------------------------------

    if nargin < 3, nSamples = 400; end

    % —— muestrear el SVG (contorno exterior + agujeros) ————————
    [Pext, Pin] = sampleSvgExIn(svgPaths, nSamples);
    PsvgAll     = [Pext ; vertcat(Pin{:})];

    % —— puntos detectados (orientación 0°) ————————————————
    Pdet0   = gatherDetPoints(edges);
    rmse0   = rmseNoRot(Pdet0, PsvgAll);

    % —— orientación 180° ——————————————————————————————
    edges180 = rotateDetectedEdges180(edges);           % usa tu función
    Pdet180  = gatherDetPoints(edges180);
    rmse180  = rmseNoRot(Pdet180, PsvgAll);

    % —— comparación y salida ————————————————————————————
    if rmse180 < rmse0
        edgesBest  = edges180;
        bestOriDeg = 180;
        bestRMSE   = rmse180;
    else
        edgesBest  = edges;
        bestOriDeg = 0;
        bestRMSE   = rmse0;
    end

    fprintf('→ Orientación elegida: %3d°   |   RMSE = %.4f\n', bestOriDeg, bestRMSE);
end
% ======================================================================
%                           H E L P E R S
% ======================================================================
function rmse = rmseNoRot(Pdet, Psvg)
% RMSE tras alinear solo los centroides (sin rotación).
    cd  = mean(Pdet,1);
    cs  = mean(Psvg,1);
    P1  = Pdet - cd;                % centra ambas nubes
    P2  = Psvg - cs;
    idx = knnsearch(P2, P1);        % nearest neighbour en Psvg
    d2  = sum((P1 - P2(idx,:)).^2, 2);
    rmse = sqrt(mean(d2));
end
% ----------------------------------------------------------------------
function P = gatherDetPoints(ed)
% Reúne exterior + interiores en una sola matriz N×2.
    P = [ed.exterior.x(:) , ed.exterior.y(:)];
    for k = 1:numel(ed.innerContours)
        ic = ed.innerContours{k};
        if ~isempty(ic)
            P = [P ; ic.x(:) , ic.y(:)]; %#ok<AGROW>
        end
    end
end
% ----------------------------------------------------------------------
function [Pext, Pin] = sampleSvgExIn(paths, k)
% Divide el SVG en exterior e interiores y los remuestrea.
    if nargin < 2, k = 400; end
    Pext = samplePath(paths{1}, k);
    Pin  = cell(1, numel(paths)-1);
    for j = 2:numel(paths)
        Pin{j-1} = samplePath(paths{j}, k);
    end
end
function P = samplePath(V, k)
% Remuestrea k puntos equiespaciados en el parámetro (0–1).
    t  = linspace(0,1,size(V,1));
    tq = linspace(0,1,k);
    vx = interp1(t, V(:,1), tq, 'linear');
    vy = interp1(t, V(:,2), tq, 'linear');
    P  = [vx(:) vy(:)];
end
% ----------------------------------------------------------------------
