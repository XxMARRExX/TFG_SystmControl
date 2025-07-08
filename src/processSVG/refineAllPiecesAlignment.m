function transformadas = refineAllPiecesAlignment(transformadas, contoursSVG)
% Ajusta (s,θ,tx,ty) cada pieza usando los centros de agujeros
%
%  • transformadas : struct array con
%         .x_svg, .y_svg                 (exterior rápido)
%         .x_svg_interior{j}, .y_svg_interior{j}  (agujeros rápidos)
%  • contoursSVG   : celda {x,y} con los contornos del SVG
%                    (se usa para hallar los centros rojos)
%
%  Devuelve transformadas con los campos anteriores ya refinados

    % --- centros de agujeros en el SVG (rojo) ---
    [Xsvg,Ysvg] = deal(contoursSVG(:,1), contoursSVG(:,2));
    [idxExt, idxInt] = identifyContours(Xsvg, Ysvg);
    key_svg = zeros(numel(idxInt),2);
    for k = 1:numel(idxInt)
        key_svg(k,:) = [ mean(Xsvg{idxInt(k)}), mean(Ysvg{idxInt(k)}) ];
    end

    % ---------- bucle por cada pieza detectada ----------
    for p = 1:numel(transformadas)

        % centros de los agujeros detectados (azul, tras T rápida)
        nH = numel(transformadas(p).x_svg_interior);
        key_det = zeros(nH,2);
        for h = 1:nH
            key_det(h,:) = [ mean(transformadas(p).x_svg_interior{h}), ...
                             mean(transformadas(p).y_svg_interior{h}) ];
        end
        if size(key_det,1) < 2,  continue; end   % necesita ≥2 puntos
        
        % --- si no hay la MISMA cantidad de agujeros, saltamos ---
        if size(key_det,1) ~= size(key_svg,1)
            continue   % deja la transformación rápida tal cual
        end

        % ---------- ajuste fino ----------
        [P_extF, P_intF] = refineAlignmentByKeypoints( ...
                [transformadas(p).x_svg ; transformadas(p).y_svg], ...
                cellfun(@(x,y)[x;y], ...
                        transformadas(p).x_svg_interior, ...
                        transformadas(p).y_svg_interior, 'uni',0), ...
                key_det, key_svg);

        % guardar exterior
        transformadas(p).x_svg = P_extF(1,:);
        transformadas(p).y_svg = P_extF(2,:);
        % guardar interiores
        for h = 1:numel(P_intF)
            transformadas(p).x_svg_interior{h} = P_intF{h}(1,:);
            transformadas(p).y_svg_interior{h} = P_intF{h}(2,:);
        end
    end
end
