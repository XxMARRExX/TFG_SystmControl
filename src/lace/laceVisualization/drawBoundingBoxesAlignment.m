function drawBoundingBoxesAlignment(cornersSVG, cornersPieceAligned)
% DRAWBOUNDINGBOXESALIGNMENT Visualizes the alignment between the SVG and the detected piece bounding boxes.
%
% Inputs:
%   - cornersSVG:          4x2 matrix, corners of the SVG model bounding box
%   - cornersPiezaAligned: 4x2 matrix, corners of the aligned piece bounding box (after Procrustes)

    % 1. Prepare figure
    figure; hold on; axis equal;
    title("Bounding Box Alignment: SVG (green) vs Piece (red)");

    % 2. Draw SVG bounding box
    loopSVG = [cornersSVG; cornersSVG(1,:)];  % close the loop
    plot(loopSVG(:,1), loopSVG(:,2), 'g-', 'LineWidth', 2, ...
        'DisplayName', 'BBox SVG');

    % 3. Draw aligned piece bounding box
    loopP = [cornersPieceAligned; cornersPieceAligned(1,:)];
    plot(loopP(:,1), loopP(:,2), 'r--', 'LineWidth', 2, ...
        'DisplayName', 'BBox Piece (aligned)');

    % 4. Finalize
    legend('show', 'Location', 'best');
end
