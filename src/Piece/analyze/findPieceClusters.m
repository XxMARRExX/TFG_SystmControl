function [pieceClusters, pieceEdges, numPieces, remainingClusters] = findPieceClusters(clusters)
%FINDPIECECLUSTERS Identifies clusters that likely correspond to complete pieces.
%
%   Inputs:
%       clusters - Cell array of structs with fields 'x', 'y', 'nx', 'ny', 'curv', 'i0', 'i1'.
%
%   Outputs:
%       pieceClusters     - Subset of clusters considered as full pieces.
%       pieceEdges        - Struct with all edges from selected clusters merged.
%       numPieces         - Number of selected piece clusters.
%       remainingClusters - Clusters not considered as pieces (possibly holes or noise).

    % Compute number of points per cluster
    numPointsPerCluster = cellfun(@(c) numel(c.x), clusters);
    [sortedCounts, sortIdx] = sort(numPointsPerCluster, 'descend');

    % Initialize output containers
    pieceClusters = {};
    usedIndices = [];

    all_x = []; all_y = [];
    all_nx = []; all_ny = [];
    all_curv = [];
    all_i0 = []; all_i1 = [];

    % Heuristic threshold: accept clusters close to the largest one
    maxPoints = sortedCounts(1);
    threshold = maxPoints - 100;

    for i = 1:numel(clusters)
        if sortedCounts(i) >= threshold
            originalIdx = sortIdx(i);
            currentCluster = clusters{originalIdx};

            % Preserve optional field 'indices' if present
            if isfield(currentCluster, 'indices')
                currentCluster.indices = currentCluster.indices;
            end

            pieceClusters{end+1} = currentCluster;
            usedIndices(end+1) = originalIdx;

            % Accumulate edge data
            all_x    = [all_x;  currentCluster.x(:)];
            all_y    = [all_y;  currentCluster.y(:)];
            all_nx   = [all_nx; currentCluster.nx(:)];
            all_ny   = [all_ny; currentCluster.ny(:)];
            all_curv = [all_curv; currentCluster.curv(:)];
            all_i0   = [all_i0; currentCluster.i0(:)];
            all_i1   = [all_i1; currentCluster.i1(:)];
        else
            break;  % Stop once we pass the threshold
        end
    end

    % Create unified edge structure for the selected clusters
    pieceEdges = struct( ...
        'x',    all_x, ...
        'y',    all_y, ...
        'nx',   all_nx, ...
        'ny',   all_ny, ...
        'curv', all_curv, ...
        'i0',   all_i0, ...
        'i1',   all_i1 ...
    );

    numPieces = numel(pieceClusters);

    % Identify and return unused clusters
    clusterMask = true(1, numel(clusters));
    clusterMask(usedIndices) = false;
    remainingClusters = clusters(clusterMask);
end
