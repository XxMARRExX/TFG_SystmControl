function model = fitrect2D(points2D)
% FITRECT2D Fits a minimum-area rotated rectangle to a set of 2D points.
%
% Input:
%   - points2D: Nx2 array of 2D points [x, y]
%
% Output (struct 'model'):
%   - Center:      1x2 center of the rectangle
%   - Dimensions:  1x2 [width, height] of the box (aligned to its axes)
%   - Orientation: 2x2 rotation matrix (global orientation)
%   - Angle:       scalar angle in radians (rotation from X axis)

    % 1. Compute convex hull
    k = convhull(points2D(:,1), points2D(:,2));
    hullPoints = points2D(k,:);

    minArea = inf;

    % 2. Try each edge of the convex hull as rectangle base
    for i = 1:length(hullPoints)-1
        % 2.a Compute edge angle
        edge = hullPoints(i+1,:) - hullPoints(i,:);
        theta = -atan2(edge(2), edge(1));

        % 2.b Rotate hull to align edge with X axis
        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
        rotPoints = (R * hullPoints')';

        % 2.c Compute axis-aligned bounding box in rotated frame
        minXY = min(rotPoints);
        maxXY = max(rotPoints);
        area  = prod(maxXY - minXY);

        % 2.d Keep the configuration with minimum area
        if area < minArea
            minArea   = area;
            bestR     = R;
            bestMin   = minXY;
            bestMax   = maxXY;
            bestTheta = theta;
        end
    end

    % 3. Compute final rectangle properties in original coordinates
    model.Center      = bestR' * ((bestMin + bestMax)' / 2);  % unrotate center
    model.Dimensions  = bestMax - bestMin;
    model.Orientation = bestR';                               % rotation from box to world
    model.Angle       = bestTheta;                            % in radians
end
