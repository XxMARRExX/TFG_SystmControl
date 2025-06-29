function edgesFiltered = filterEdgesByBoundingBox(edges, bbox)
% Filtra los puntos de 'edges' que caen dentro del bounding box.
% Funciona incluso si 'edges' no tiene todos los campos posibles.

    % Coordenadas de puntos
    xq = edges.x(:);
    yq = edges.y(:);

    % Bounding box cerrado
    xv = [bbox(1,:) bbox(1,1)];
    yv = [bbox(2,:) bbox(2,1)];

    % Máscara de puntos dentro del polígono
    in = inpolygon(xq, yq, xv, yv);

    % Inicializar resultado
    edgesFiltered = struct();

    % Copiar campos existentes
    campos = fieldnames(edges);
    for k = 1:numel(campos)
        campo = campos{k};
        edgesFiltered.(campo) = edges.(campo)(in);
    end
end
