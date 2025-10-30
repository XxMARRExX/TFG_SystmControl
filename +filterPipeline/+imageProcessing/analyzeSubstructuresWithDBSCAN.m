function [clusters, noisePoints] = analyzeSubstructuresWithDBSCAN(edges, epsilon, minPts)
%ANALYZESUBSTRUCTURESWITHDBSCAN Applies DBSCAN clustering to subpixel edge points.
%
%   Inputs:
%       edges   - Struct with fields 'x', 'y', and optionally 'nx', 'ny', 'curv', 'i0', 'i1'.
%       epsilon - Neighborhood radius for DBSCAN (in pixels).
%       minPts  - Minimum number of points to form a cluster.
%
%   Outputs:
%       clusters     - Cell array of structs, each containing a cluster with fields from 'edges'.
%       noisePoints  - Struct with points classified as noise by DBSCAN.

    x = edges.x(:);
    y = edges.y(:);
    
    % Apply DBSCAN clustering
    pointLabels = dbscan([x, y], epsilon, minPts);
    numClusters = max(pointLabels);

    clusters = cell(1, numClusters);

    % Group points by cluster label
    for i = 1:numClusters
        clusterMask = (pointLabels == i);
        clusterIndices = find(clusterMask);

        clusters{i} = struct('x', edges.x(clusterMask), ...
            'y', edges.y(clusterMask), ...
            'indices', clusterIndices ...
        );
    end

    % Collect noise points (label == -1)
    noiseMask = (pointLabels == -1);
    noisePoints = struct('x', edges.x(noiseMask),'y', edges.y(noiseMask));
end
