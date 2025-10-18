function [edgesRot, bboxCenter] = rotatePiece180(edges, bboxCorners)
% ROTATEPIECE180 Applies a 180° rotation (central symmetry) around the bbox center.
%
%   edgesRot = rotatePiece180(edges, bboxCorners)
%
% Inputs:
%   - edges       : structure containing:
%       • edges.exterior.x , .y
%       • edges.innerContours{h}.x , .y
%   - bboxCorners : [4×2] matrix with the 4 corners of the bounding box (in order)
%
% Output:
%   - edgesRot    : rotated structure (symmetry around bbox center)
%
% Notes:
%   The rotation is applied as:
%       P_rotated = 2 * c - P
%   where c is the center of the bounding box.

    % 1. Compute bbox center
    bboxCenter = mean(bboxCorners, 1);  % [cx, cy]

    % 2. Define symmetry: P' = 2·c − P
    mirrorX = @(x) 2 * bboxCenter(1) - x;
    mirrorY = @(y) 2 * bboxCenter(2) - y;

    % 3. Apply rotation to a copy of the input structure
    edgesRot = edges;

    % 3.a Exterior contour
    edgesRot.exterior.x = mirrorX(edges.exterior.x);
    edgesRot.exterior.y = mirrorY(edges.exterior.y);

    % 3.b Inner contours
    for k = 1:numel(edges.innerContours)
        ic = edges.innerContours{k};
        if isempty(ic), continue; end
        ic.x = mirrorX(ic.x);
        ic.y = mirrorY(ic.y);
        edgesRot.innerContours{k} = ic;
    end
end
