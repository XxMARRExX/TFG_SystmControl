function [edgesBest, bestOriDeg, bestRMSE] = pickBestEdgeOrientation(pieceClusters, svgPaths, nSamples)
% PICKBESTEDGEORIENTATION Selects 0° or 180° orientation based on RMSE with the SVG model.
%
%   [edgesBest, bestOriDeg, bestRMSE] = pickBestEdgeOrientation(pieceClusters, svgPaths, nSamples)
%
% Inputs:
%   - pieceClusters : cell array containing a single detected piece
%   - svgPaths      : cell array of SVG model paths
%   - nSamples      : number of points to sample per SVG contour (default = 400)
%
% Outputs:
%   - edgesBest  : best orientation (original or 180°-rotated)
%   - bestOriDeg : 0 or 180
%   - bestRMSE   : RMSE between the detected piece and the SVG model

    if nargin < 3, nSamples = 400; end

    % 1. Sample the SVG model (outer + inner contours)
    [Pext, Pin] = sampleSvgExIn(svgPaths, nSamples);
    PsvgAll     = [Pext; vertcat(Pin{:})];

    % 2. Extract edges of the detected piece
    edges = pieceClusters{1}.edges;

    % 3. Orientation 0°
    Pdet0 = gatherDetPoints(edges);
    rmse0 = rmseNoRotation(Pdet0, PsvgAll);

    % 4. Orientation 180°
    edges180 = rotateDetectedEdges180(edges);
    Pdet180  = gatherDetPoints(edges180);
    rmse180  = rmseNoRotation(Pdet180, PsvgAll);

    % 5. Select the best orientation
    if rmse180 < rmse0
        edgesBest  = edges180;
        bestOriDeg = 180;
        bestRMSE   = rmse180;
    else
        edgesBest  = edges;
        bestOriDeg = 0;
        bestRMSE   = rmse0;
    end

    fprintf('→ Chosen orientation: %3d°   |   RMSE = %.4f\n', bestOriDeg, bestRMSE);
end



% ======================================================================
%                           H E L P E R S
% ======================================================================
function rmse = rmseNoRotation(Pdet, Psvg)
% RMSENOROTATION Computes RMSE after centroid alignment (no rotation).
    cd  = mean(Pdet, 1);         % centroid of detection
    cs  = mean(Psvg, 1);         % centroid of model
    P1  = Pdet - cd;
    P2  = Psvg - cs;
    idx = knnsearch(P2, P1);     % nearest neighbors in model
    d2  = sum((P1 - P2(idx,:)).^2, 2);
    rmse = sqrt(mean(d2));
end

% ----------------------------------------------------------------------

function P = gatherDetPoints(edges)
% GATHERDETPOINTS Aggregates all edge points (exterior + inner contours).
    P = [edges.exterior.x(:), edges.exterior.y(:)];
    for k = 1:numel(edges.innerContours)
        ic = edges.innerContours{k};
        if ~isempty(ic)
            P = [P; ic.x(:), ic.y(:)]; %#ok<AGROW>
        end
    end
end

% ----------------------------------------------------------------------

function [Pext, Pin] = sampleSvgExIn(paths, k)
% SAMPLESVGEXIN Separates SVG paths into outer and inner and samples them.
    if nargin < 2, k = 400; end
    Pext = samplePath(paths{1}, k);
    Pin  = cell(1, numel(paths) - 1);
    for j = 2:numel(paths)
        Pin{j - 1} = samplePath(paths{j}, k);
    end
end

function P = samplePath(V, k)
% SAMPLEPATH Samples k evenly spaced points along a path.
    t  = linspace(0, 1, size(V,1));
    tq = linspace(0, 1, k);
    vx = interp1(t, V(:,1), tq, 'linear');
    vy = interp1(t, V(:,2), tq, 'linear');
    P  = [vx(:), vy(:)];
end
