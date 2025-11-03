function ptsOut = undoRotation(ptsIn, oriDeg, center)
% undoRotation() Undoes a 180° rotation or a general rotation around a given center.
%
%   Inputs:
%       - ptsIn: Nx2 matrix OR structure with fields:
%           • .exterior.x , .exterior.y
%           • .innerContours{i}.x , .y
%           (and optionally other fields like .e)
%       - oriDeg: rotation angle (0 or 180)
%       - center: [1x2] rotation center
%
%   Output:
%       - ptsOut: same type as input (matrix or struct)
%
%   Notes:
%       - If oriDeg = 180 → central symmetry (faster).
%       - Keeps all other fields (like .e) untouched.

    ptsOut = ptsIn; % conservar la estructura o matriz base

    if isstruct(ptsIn)
        % --- Exterior contour ---
        if isfield(ptsIn, "exterior")
            P = [ptsIn.exterior.x(:), ptsIn.exterior.y(:)];
            P_rot = rotatePoints(P, oriDeg, center);
            ptsOut.exterior.x = P_rot(:,1);
            ptsOut.exterior.y = P_rot(:,2);
        end

        % --- Inner contours ---
        if isfield(ptsIn, "innerContours")
            for i = 1:numel(ptsIn.innerContours)
                if isempty(ptsIn.innerContours{i}), continue; end
                ic = ptsIn.innerContours{i};
                P = [ic.x(:), ic.y(:)];
                P_rot = rotatePoints(P, oriDeg, center);
                ptsOut.innerContours{i}.x = P_rot(:,1);
                ptsOut.innerContours{i}.y = P_rot(:,2);
                % Conservar cualquier otro campo (por ejemplo, .e)
                otherFields = setdiff(fieldnames(ic), {'x','y'});
                for f = 1:numel(otherFields)
                    fname = otherFields{f};
                    ptsOut.innerContours{i}.(fname) = ic.(fname);
                end
            end
        end

    else
        % --- Si es una matriz Nx2 normal ---
        ptsOut = rotatePoints(ptsIn, oriDeg, center);
    end
end


function P_rot = rotatePoints(P, oriDeg, center)
% rotatePoints() Applies inverse rotation or symmetry around a center.
    if oriDeg == 180
        % Simetría central (más rápida y precisa)
        P_rot = 2*center - P;
    elseif oriDeg ~= 0
        % Rotación genérica
        R = [cosd(oriDeg) sind(oriDeg); -sind(oriDeg) cosd(oriDeg)];
        P_rot = (R * (P - center)')' + center;
    else
        % Sin rotación
        P_rot = P;
    end
end
