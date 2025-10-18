function sortedCorners = formatCorners(bbox2x4)
% FORMATCORNERS Converts a 2x4 corner matrix into 4x2 format ordered counterclockwise.
%
% Input:
%   - bbox2x4: 2x4 matrix, where each column is a corner [x; y]
%
% Output:
%   - sortedCorners: 4x2 matrix, each row is a corner [x, y] ordered counterclockwise

    % 1. Transpose to 4x2 format
    corners = bbox2x4';  % 4x2

    % 2. Compute centroid
    center = mean(corners, 1);

    % 3. Compute angles relative to centroid
    angles = atan2(corners(:,2) - center(2), corners(:,1) - center(1));

    % 4. Sort by angle to get counterclockwise order
    [~, idx] = sort(angles);
    sortedCorners = corners(idx, :);
end
