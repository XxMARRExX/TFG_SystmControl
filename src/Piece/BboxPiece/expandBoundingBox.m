function bBoxExpanded = expandBoundingBox(bBox, margin)

    % Centro del bbox (promedio de los 4 vértices)
    center = mean(bBox, 2);

    % Direcciones: lados del bbox
    v1 = bBox(:,2) - bBox(:,1);   % lado corto o largo (depende)
    v2 = bBox(:,4) - bBox(:,1);   % lado perpendicular

    % Normalización
    u1 = v1 / norm(v1);
    u2 = v2 / norm(v2);

    % Expandir cada esquina
    for i = 1:4
        vec = bBox(:,i) - center;
        % Descomponer en base (u1, u2)
        a1 = dot(vec, u1);
        a2 = dot(vec, u2);
        % Expandir
        vecExp = (a1 + sign(a1)*margin)*u1 + (a2 + sign(a2)*margin)*u2;
        bBoxExpanded(:,i) = center + vecExp;
    end
end
