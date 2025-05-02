function [edgesC] = filterByNormalThreshold(edges, maxNormalDeviation)

    %% Filtrar puntos cuya normal está orientada verticalmente (bordes horizontales)
    idx_valido = abs(edges.ny) > maxNormalDeviation;

    %% Asignar directamente los campos filtrados
    edgesC.x = edges.x(idx_valido);
    edgesC.y = edges.y(idx_valido);
    edgesC.nx = edges.nx(idx_valido);
    edgesC.ny = edges.ny(idx_valido);
    edgesC.curv = edges.curv(idx_valido);
    edgesC.i0 = edges.i0(idx_valido);
    edgesC.i1 = edges.i1(idx_valido);
end
