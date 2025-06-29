function bBoxExpanded = calculateExpandedBoundingBox(edges, scale, margin)
    points = [edges.x, edges.y];
    bBoxPiece = minBoundingBox(points');
    bBoxPieceRescaled = bBoxPiece / scale;
    bBoxExpanded = expandBoundingBox(bBoxPieceRescaled, margin);
end
