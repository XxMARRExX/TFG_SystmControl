function edgesFiltered = filterEdgesByBoundingBox(edges, bbox)
%FILTEREDGESBYBOUNDINGBOX Filters edge points that lie within a given bounding box.
%
%   Inputs:
%       edges - Struct with fields 'x', 'y', and optionally others (e.g., 'nx', 'curv', ...).
%       bbox  - 2x4 matrix representing the bounding box corners [x; y].
%
%   Output:
%       edgesFiltered - Subset of 'edges' where points are inside the bbox.

    xPoints = edges.x(:);
    yPoints = edges.y(:);

    % Build closed polygon from bounding box corners
    xBox = [bbox(1, :) bbox(1, 1)];
    yBox = [bbox(2, :) bbox(2, 1)];

    % Determine which points fall inside the bounding box
    insideMask = inpolygon(xPoints, yPoints, xBox, yBox);

    edgesFiltered = struct();

    % Copy only the fields present in 'edges', filtered by mask
    fieldNames = fieldnames(edges);
    for i = 1:numel(fieldNames)
        name = fieldNames{i};
        edgesFiltered.(name) = edges.(name)(insideMask);
    end
end
