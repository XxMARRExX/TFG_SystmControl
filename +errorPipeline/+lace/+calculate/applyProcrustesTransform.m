function [clustersTransformed, cornersTransformed] = applyProcrustesTransform(pieceClusters, cornersPiece, transform)
% APPLYPROCRUSTESTRANSFORM
% Applies the Procrustes similarity transform (scale b, rotation T, translation c)
% to:
%   1) all exterior and interior edge points in each piece (pieceClusters)
%   2) the piece's bounding-box corners (cornersPiece)
%
% INPUTS
%   pieceClusters   : cell array with fields edges.exterior and edges.innerContours
%   transform       : struct from procrustes (fields: b, T, c)
%   cornersPiece    : 4x2 or 2x4 matrix of bbox corners in the same SR as the piece points
%
% OUTPUTS
%   clustersTransformed : same structure as pieceClusters, but transformed to the SVG SR
%   cornersTransformed  : 4x2 matrix of bbox corners transformed to the SVG SR

    clustersTransformed = pieceClusters;

    % Ensure c is 1x2 (MATLAB may return 4x2 with identical rows)
    if size(transform.c,1) > 1
        transform.c = transform.c(1,:);
    end

    % Vectorized transform for an N x 2 point set
    applyT = @(P) transform.b * (P * transform.T) + transform.c;

    % --- (1) Transform all pieces: exterior and inner contours ---
    for p = 1:numel(pieceClusters)
        % Exterior
        Pext = [pieceClusters{p}.edges.exterior.x(:), pieceClusters{p}.edges.exterior.y(:)];
        Pext_t = applyT(Pext);
        clustersTransformed{p}.edges.exterior.x = Pext_t(:,1);
        clustersTransformed{p}.edges.exterior.y = Pext_t(:,2);

        % Inner contours (if any)
        innerC = pieceClusters{p}.edges.innerContours;
        for i = 1:numel(innerC)
            Pi = [innerC{i}.x(:), innerC{i}.y(:)];
            Pi_t = applyT(Pi);
            clustersTransformed{p}.edges.innerContours{i}.x = Pi_t(:,1);
            clustersTransformed{p}.edges.innerContours{i}.y = Pi_t(:,2);
        end
    end

    cornersTransformed = applyT(cornersPiece);
end
