function insideClusters = filterClustersInsideMask(clusters, mask, minInclusionRatio)
%FILTERCLUSTERSINSIDEMASK Filters clusters that are sufficiently contained within a mask.
%
%   Inputs:
%       clusters           - Cell array of structs with fields 'x', 'y', etc.
%       mask               - Binary or labeled mask image.
%       minInclusionRatio  - Minimum ratio [0–1] of points inside the mask to accept a cluster (default = 1).
%
%   Output:
%       insideClusters     - Cell array of clusters that meet the inclusion criteria.

    if nargin < 3
        minInclusionRatio = 1;
    end

    insideClusters = {};

    for i = 1:numel(clusters)
        cluster = clusters{i};

        % Round coordinates to nearest integer pixel
        x = round(cluster.x(:));
        y = round(cluster.y(:));

        % Validate that points are inside image bounds
        inBounds = x >= 1 & x <= size(mask, 2) & ...
                   y >= 1 & y <= size(mask, 1);

        if nnz(inBounds) == 0
            continue;  % No valid points
        end

        xValid = x(inBounds);
        yValid = y(inBounds);

        % Compute number of points inside the mask
        linearIdx = sub2ind(size(mask), yValid, xValid);
        numInside = sum(mask(linearIdx) > 0);  % If binary or labeled
        inclusionRatio = numInside / numel(xValid);

        % Accept cluster if it meets inclusion ratio
        if inclusionRatio >= minInclusionRatio
            filteredCluster = struct();
            fieldNames = fieldnames(cluster);

            for f = 1:numel(fieldNames)
                field = fieldNames{f};
                values = cluster.(field);

                % Filter vector fields matching point count
                if numel(values) == numel(inBounds)
                    values = values(inBounds);
                end

                filteredCluster.(field) = values;
            end

            insideClusters{end+1} = filteredCluster;
        end
    end
end
