function svgPathsInv = invertSvgPathsTransform(svgPaths, transform, oriDeg, bboxCenter, rotatedFlag)
% invertSvgPathsTransform() Transforms SVG paths back to the original image space.
%
%   Applies the same rotation as the detected piece (if rotatedFlag = true)
%   and then the inverse of the Procrustes transformation to return the
%   SVG model to the coordinate system of the original image.
%
%   Inputs:
%       - svgPaths: cell array where each element is an [Nx2] matrix of [x, y].
%       - transform: struct returned by procrustes() (maps piece → SVG).
%       - oriDeg: rotation angle applied to the piece (usually 180).
%       - bboxCenter: [1x2] center used for rotation (same as rotatePiece180).
%       - rotatedFlag: logical flag (true if the piece was rotated 180°).
%
%   Output:
%       - svgPathsInv: cell array with each path in the coordinate system
%                      of the original image.
%
%   Notes:
%       - NaN rows (subpath separators) are preserved.
%       - Transformation order: rotation (if applied) → inverse Procrustes.

    svgPathsInv = cell(size(svgPaths));

    % --- Normalize translation vector (ensure 1x2) ---
    if size(transform.c, 1) > 1
        transform.c = transform.c(1, :);
    end

    for i = 1:numel(svgPaths)
        P = svgPaths{i};
        if isempty(P)
            svgPathsInv{i} = P;
            continue;
        end

        % --- Handle NaN subpath separators ---
        nanMask = any(isnan(P), 2);
        Pvalid = P(~nanMask, :);
        if isempty(Pvalid)
            svgPathsInv{i} = P;
            continue;
        end

        % --- 1. Apply rotation (same as piece) ---
        if rotatedFlag
            % Rotar 180° respecto al centro del bbox (simetría central)
            Pvalid = 2 * bboxCenter - Pvalid;
        end

        % --- 2. Apply inverse Procrustes transformation ---
        %     X = (Y - c) / b * T'
        PvalidInv = (Pvalid - transform.c) / transform.b * transform.T';

        % --- Rebuild path keeping NaN structure ---
        Pnew = nan(size(P));
        Pnew(~nanMask, :) = PvalidInv;
        svgPathsInv{i} = Pnew;
    end
end
