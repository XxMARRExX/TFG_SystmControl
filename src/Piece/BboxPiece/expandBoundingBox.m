function bBoxExpanded = expandBoundingBox(bBox, margin)
%EXPANDBOUNDINGBOX Expands a bounding box outward by a given margin.
%
%   Inputs:
%       bBox   - 2x4 matrix with the 4 corner points of the bounding box (columns = points).
%       margin - Amount to expand in both directions (same units as the coordinates).
%
%   Output:
%       bBoxExpanded - 2x4 matrix with the expanded bounding box corners.

    % Compute the center of the bounding box
    center = mean(bBox, 2);

    % Define orthonormal base (u1, u2) from the edges of the box
    edge1 = bBox(:,2) - bBox(:,1);  
    edge2 = bBox(:,4) - bBox(:,1);  
    
    % Unit vector
    u1 = edge1 / norm(edge1);  
    u2 = edge2 / norm(edge2);  

    % Initialize output
    bBoxExpanded = zeros(2, 4);

    % Expand each corner point
    for i = 1:4
        vec = bBox(:,i) - center;           
        coeff1 = dot(vec, u1);              
        coeff2 = dot(vec, u2);              

        vecExpanded = (coeff1 + sign(coeff1) * margin) * u1 + ...
                      (coeff2 + sign(coeff2) * margin) * u2;

        bBoxExpanded(:,i) = center + vecExpanded;
    end
end
