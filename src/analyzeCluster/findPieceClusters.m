function [pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters)
% FINDPIECECLUSTERS Identifica los clusters que probablemente corresponden a piezas completas.
%
%   Entrada:
%     - clusters: celda de estructuras con campos .x, .y, nx, ny, curv, i0, i1
%
%   Salida:
%     - pieceClusters: subset de clusters considerados piezas
%     - pieceEdges: estructura 'edges' con todos los puntos combinados
%     - numPieces: número de clusters considerados como piezas
%     - remainingClusters: clusters no considerados como piezas (potenciales interiores, ruido, etc.)

    numPoints = cellfun(@(e) numel(e.x), clusters);
    [sortedPoints, idx] = sort(numPoints, 'descend');

    % Cluster con más puntos
    maxPoints = sortedPoints(1);
    pieceClusters = {};
    usedIndices = [];  % ← para registrar los índices de clusters usados

    all_x = [];
    all_y = [];
    all_nx = [];
    all_ny = [];
    all_curv = [];
    all_i0 = [];
    all_i1 = [];

    for i = 1:numel(clusters)
        if sortedPoints(i) >= maxPoints - 100
            originalIdx = idx(i);
            c = clusters{originalIdx};
            if isfield(clusters{originalIdx}, 'indices')
                c.indices = clusters{originalIdx}.indices;
            end
            pieceClusters{end+1} = c; %#ok<AGROW>
            usedIndices(end+1) = originalIdx; %#ok<AGROW>

            all_x = [all_x; c.x(:)];
            all_y = [all_y; c.y(:)];
            all_nx = [all_nx; c.nx(:)];
            all_ny = [all_ny; c.ny(:)];
            all_curv = [all_curv; c.curv(:)];
            all_i0 = [all_i0; c.i0(:)];
            all_i1 = [all_i1; c.i1(:)];
        else
            break;
        end
    end

    pieceEdges = struct( ...
        'x', all_x, ...
        'y', all_y, ...
        'nx', all_nx, ...
        'ny', all_ny, ...
        'curv', all_curv, ...
        'i0', all_i0, ...
        'i1', all_i1 ...
    );

    numPieces = numel(pieceClusters);

    % Eliminar los clusters usados (piezas) y devolver los restantes
    mask = true(1, numel(clusters));
    mask(usedIndices) = false;
    remainingClusters = clusters(mask);
end
