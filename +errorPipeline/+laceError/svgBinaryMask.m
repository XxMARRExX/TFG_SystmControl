function result = svgBinaryMask(svgPaths, pxPerUnit, marginMm)
% svgBinaryMask() Generates a binary mask of the piece from SVG contours.
% Each contour is rasterized at a given resolution and filled by parity rule.
%
%   Inputs:
%       - svgPaths: cell array of Nx2 real coordinates (in mm)
%       - pxPerUnit: pixels per unit (e.g., 10 px/mm)
%       - marginMm: optional margin around the piece in millimeters (default = 5)
%
%   Output:
%       - result: structure with fields:
%           - mask: binary image (1 = piece, 0 = background)
%           - xmin: minimum x coordinate (real)
%           - ymin: minimum y coordinate (real)
%           - pxPerUnit: used resolution (pixels per unit)

    if nargin < 3
        marginMm = 5; % default margin in mm
    end

    % --- Concatenate all points to compute global bounding box ---
    allPts = vertcat(svgPaths{:});
    xmin = floor(min(allPts(:,1)) - marginMm);
    xmax = ceil(max(allPts(:,1)) + marginMm);
    ymin = floor(min(allPts(:,2)) - marginMm);
    ymax = ceil(max(allPts(:,2)) + marginMm);

    % --- Compute mask size in pixels ---
    width  = round((xmax - xmin) * pxPerUnit) + 3;
    height = round((ymax - ymin) * pxPerUnit) + 3;

    % --- Initialize binary mask ---
    pieceMask = false(height, width);

    % --- Rasterize each SVG contour ---
    for i = 1:numel(svgPaths)
        pts = svgPaths{i};

        % Skip empty or malformed paths
        if isempty(pts) || size(pts, 2) < 2
            continue;
        end

        % Extract and clean coordinates
        x = pts(:,1);
        y = pts(:,2);
        validIdx = isfinite(x) & isfinite(y);
        x = x(validIdx);
        y = y(validIdx);

        % Skip if less than 3 valid points (not enough for a polygon)
        if numel(x) < 3
            continue;
        end

        % Convert to pixel coordinates
        x = round((x - xmin) * pxPerUnit) + 2;
        y = round((y - ymin) * pxPerUnit) + 2;

        % Clip coordinates to mask limits
        x = max(min(x, width), 1);
        y = max(min(y, height), 1);

        % Rasterize current path and apply parity fill
        mask = poly2mask(x, y, height, width);
        pieceMask = xor(pieceMask, mask);
    end

    % --- Result structure ---
    result.mask = pieceMask;
    result.xmin = xmin;
    result.ymin = ymin;
    result.pxPerUnit = pxPerUnit;
end
