function [filteredEdges] = filterByNormalThreshold(edges)

    %% Filtrar puntos cuya normal está orientada verticalmente (bordes horizontales)
    idx_valido = abs(edges.ny) > 0.90;

    %% Asignar directamente los campos filtrados
    filteredEdges.x = edges.x(idx_valido);
    filteredEdges.y = edges.y(idx_valido);
    filteredEdges.nx = edges.nx(idx_valido);
    filteredEdges.ny = edges.ny(idx_valido);
    filteredEdges.curv = edges.curv(idx_valido);
    filteredEdges.i0 = edges.i0(idx_valido);
    filteredEdges.i1 = edges.i1(idx_valido);
end
