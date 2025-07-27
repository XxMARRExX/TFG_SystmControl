function bBoxExpanded = calculateExpandedBoundingBox(edges, scale, margin)
%CALCULATEEXPANDEDBOUNDINGBOX Computes the expanded bounding box of a set of edges.
%
%   Inputs:
%       edges - Struct with fields 'x' and 'y' (e.g., from subpixelEdges).
%       scale - Rescaling factor applied to the image prior to edge detection.
%       margin - Margin (in pixels or units) to expand the bounding box.
%
%   Output:
%       bBoxExpanded - 2xN matrix with coordinates of the expanded bounding box.

    points = [edges.x, edges.y];

    bBoxRescaled = minBoundingBox(points');
    bBoxOriginal = bBoxRescaled / scale;

    bBoxExpanded = expandBoundingBox(bBoxOriginal, margin);
end
