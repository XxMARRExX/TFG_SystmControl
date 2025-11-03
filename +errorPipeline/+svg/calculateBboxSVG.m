function sortedCorners = calculateBboxSVG(svgPaths)
% calculateBboxSVG() Fits a rotated minimum bounding box to all SVG paths and returns its corners in counterclockwise order.
%
%   Inputs:
%       - svgPaths: cell array of Nx2 matrices (SVG path coordinates)
%
%   Output:
%       - sortedCorners: 4x2 matrix with the box corners ordered counterclockwise

    % 1. Concatenate all path points
    allPoints = vertcat(svgPaths{:});  % Nx2

    % 2. Remove invalid (NaN or Inf) coordinates
    allPoints = allPoints(all(isfinite(allPoints), 2), :);

    % 3. Fit a rotated bounding rectangle
    modelSVG = fitrect2D(allPoints);

    % 4. Compute local corner coordinates (relative to center)
    w = modelSVG.Dimensions(1) / 2;
    h = modelSVG.Dimensions(2) / 2;
    localCorners = [-w -h; w -h; w h; -w h];  % 4x2

    % 5. Apply rotation and translation to global coordinates
    rotated = (modelSVG.Orientation * localCorners')';  % 4x2
    centerMat = repmat(modelSVG.Center(:)', 4, 1);
    corners = rotated + centerMat;                

    % 6. Reorder corners counterclockwise based on angles from centroid
    center = mean(corners, 1);
    angles = atan2(corners(:,2) - center(2), corners(:,1) - center(1));
    [~, idx] = sort(angles);
    sortedCorners = corners(idx, :);
end
