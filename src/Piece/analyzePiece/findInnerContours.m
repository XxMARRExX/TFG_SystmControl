function cleanClusters = findInnerContours(clusters, imgSize, refImgSize, minMeanDistBase)
%FINDINNERCONTOURS Filters clusters based on spatial dispersion to detect inner contours.
%
%   cleanClusters = findInnerContours(clusters, imgSize, refImgSize, minMeanDistBase)
%
%   Inputs:
%       clusters         - Cell array of clusters (structs with fields 'x' and 'y').
%       imgSize          - Size of current image [height, width].
%       refImgSize       - Reference image size used to define the base threshold.
%       minMeanDistBase  - Base threshold of mean distance between points (in pixels).
%
%   Output:
%       cleanClusters    - Cell array of clusters that are sufficiently dispersed
%                          (likely to represent inner contours rather than dense noise).

    % Compute adaptive threshold based on image scale
    refDiag = norm(refImgSize);
    imgDiag = norm(imgSize);
    scaleFactor = imgDiag / refDiag;
    minMeanDist = minMeanDistBase * scaleFactor;

    cleanClusters = {};

    % Loop through clusters and filter based on mean pairwise distance
    for i = 1:numel(clusters)
        cluster = clusters{i};
        x = cluster.x(:);
        y = cluster.y(:);

        if numel(x) < 3
            continue;  % Not enough points to define shape
        end

        % Compute average distance between all point pairs
        distances = pdist([x y]);
        meanDist = mean(distances);

        % Keep only clusters that are spatially dispersed
        if meanDist >= minMeanDist
            cleanClusters{end+1} = cluster;
        end
    end
end
