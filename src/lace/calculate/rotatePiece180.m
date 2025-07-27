function edgesRot = rotatePiece180(edges)
% ROTATEDETECTEDGES180 Applies a 180° rotation (central symmetry) to all detected points.
%
% Input:
%   - edges: structure with:
%       • edges.exterior.x , .y
%       • edges.innerContours{h}.x , .y
%
% Output:
%   - edgesRot: same structure, rotated 180° around the global centroid
%
% The rotation is computed as a central symmetry:
%   P_rotated = 2 * c - P
% where c is the centroid of all detected points (exterior + inner).

    % 1. Collect all points to compute the global centroid
    Px = edges.exterior.x(:);
    Py = edges.exterior.y(:);

    for k = 1:numel(edges.innerContours)
        ic = edges.innerContours{k};
        if ~isempty(ic)
            Px = [Px; ic.x(:)];  %#ok<AGROW>
            Py = [Py; ic.y(:)];
        end
    end

    centroid = [mean(Px), mean(Py)];  % [cx, cy]

    % 2. Define rotation: P' = 2·c − P
    mirrorX = @(x) 2 * centroid(1) - x;
    mirrorY = @(y) 2 * centroid(2) - y;

    % 3. Apply rotation to a copy of the input structure
    edgesRot = edges;

    % 3.a Exterior
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
