function refinedPieces = cleanOuterContourWithAlphaShape(pieces, alphaRadius)
    % Refines the external contour of each piece using alpha shape
    % Inputs:
    %   - pieces: cell array of structs with fields .x and .y
    %   - alphaRadius: alpha radius for alphaShape (optional)
    % Output:
    %   - refinedPieces: cleaned cell array

    if nargin < 2
        alphaRadius = 15;  % Adjustable depending on resolution
    end

    refinedPieces = cell(size(pieces));

    for i = 1:numel(pieces)
        data = pieces{i};
        x = data.x;
        y = data.y;

        % Create alphaShape
        shp = alphaShape(x, y, alphaRadius);

        % Extract polygon boundary as coordinates
        [bf, P] = boundaryFacets(shp);  % bf = boundary facets (indices), P = points
        xv = P(:,1);
        yv = P(:,2);

        % Use inpolygon to keep only inner points
        inside = inpolygon(x, y, xv, yv);

        % Save filtered structure
        f = fieldnames(data);
        for k = 1:numel(f)
            refinedPieces{i}.(f{k}) = data.(f{k})(inside);
        end
    end
end
