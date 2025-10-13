function sortedCorners = calculateBboxSVG(svgPaths)
% calculateBboxSVG() Fits a rotated minimum bounding box to all valid SVG paths
% and returns its corners in counterclockwise order.
%
%   Input:
%       - svgPaths: cell array of Nx2 matrices (SVG path coordinates)
%
%   Output:
%       - sortedCorners: 4x2 matrix with box corners ordered counterclockwise

    % --- 1. Concatenate all valid points ---
    allPoints = [];

    for i = 1:numel(svgPaths)
        path = svgPaths{i};

        % Skip empty or malformed paths
        if isempty(path) || size(path,2) < 2
            continue;
        end

        % Clean coordinates (remove NaN/Inf)
        x = path(:,1);
        y = path(:,2);
        validIdx = isfinite(x) & isfinite(y);

        if any(validIdx)
            allPoints = [allPoints; x(validIdx), y(validIdx)]; %#ok<AGROW>
        end
    end

    % --- 2. Handle empty or invalid input ---
    if isempty(allPoints)
        error('calculateBboxSVG:NoValidPoints', ...
              'No valid points found in SVG paths (NaN, Inf or empty paths).');
    end

    % --- 3. Fit rotated bounding rectangle ---
    modelSVG = fitrect2D(allPoints);

    % --- 4. Compute local corner coordinates (relative to center) ---
    w = modelSVG.Dimensions(1) / 2;
    h = modelSVG.Dimensions(2) / 2;
    localCorners = [-w -h; w -h; w h; -w h];  % 4x2

    % --- 5. Apply rotation and translation ---
    rotated = (modelSVG.Orientation * localCorners')';  % 4x2
    centerMat = repmat(modelSVG.Center(:)', 4, 1);
    corners = rotated + centerMat;

    % --- 6. Reorder corners counterclockwise ---
    center = mean(corners, 1);
    angles = atan2(corners(:,2) - center(2), corners(:,1) - center(1));
    [~, idx] = sort(angles);
    sortedCorners = corners(idx, :);
end
