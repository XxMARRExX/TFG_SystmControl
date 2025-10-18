function pointsInv = applyInverseProcrustesTransform(points, transform)
% APPLYINVERSEPROCRUSTESTRANSFORM Reverts Procrustes transformation.
%
%   Inputs:
%       - points: Nx2 matrix OR structured input with fields:
%           • .exterior.x , .exterior.y
%           • .innerContours{i}.x , .innerContours{i}.y
%           (and possibly .e, .error, etc.)
%       - transform: struct returned by procrustes()
%
%   Output:
%       - pointsInv: same structure as input, but coordinates transformed
%                    back to the original image space.
    pointsInv = points;  % copiar estructura base

    % ---- Exterior ----
    if isfield(points, "exterior")
        P = [points.exterior.x(:), points.exterior.y(:)];
        % Asegurar que c es 1x2
        if size(transform.c, 1) > 1
            c = transform.c(1, :);
        else
            c = transform.c;
        end
        
        P_inv = (P - c) / transform.b * transform.T';
        pointsInv.exterior.x = P_inv(:,1);
        pointsInv.exterior.y = P_inv(:,2);
    end

    % ---- Inner contours ----
    if isfield(points, "innerContours")
        for k = 1:numel(points.innerContours)
            if isempty(points.innerContours{k}), continue; end
            ic = points.innerContours{k};
            P = [ic.x(:), ic.y(:)];
            % Asegurar que c es 1x2
            if size(transform.c, 1) > 1
                c = transform.c(1, :);
            else
                c = transform.c;
            end
            
            P_inv = (P - c) / transform.b * transform.T';
            pointsInv.innerContours{k}.x = P_inv(:,1);
            pointsInv.innerContours{k}.y = P_inv(:,2);
            % Mantiene todos los demás campos (.e, .error, etc.)
            otherFields = setdiff(fieldnames(ic), {'x','y'});
            for f = 1:numel(otherFields)
                fieldName = otherFields{f};
                pointsInv.innerContours{k}.(fieldName) = ic.(fieldName);
            end
        end
    end
end
