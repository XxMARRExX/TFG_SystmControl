function [P_out, P_int_out] = refineAlignmentByKeypoints(P_det, P_int_det, key_det, key_svg)
% Ajuste similitud 2D (s,θ,tx,ty) entre key_det y key_svg
%   P_det      : 2×N exterior rápido
%   P_int_det  : celda {2×Ni} interiores rápidos
%   key_det    : K×2 centros detectados   (K≥2)
%   key_svg    : K×2 centros en el SVG    (orden correcto)

    % semilla con procrustes
    [~,~,tr] = procrustes(key_svg, key_det,'Scaling',true,'Reflection',false);
    x0 = [tr.b , atan2(tr.T(2,1),tr.T(1,1)) , tr.c(1) , tr.c(2)];  % [s θ tx ty]

    % coste
    f = @(x) reshape( (x(1)*[cos(x(2)) -sin(x(2)); sin(x(2)) cos(x(2))]*key_det.' ...
                      + x(3:4)').' - key_svg , [],1);
    opts = optimoptions('lsqnonlin','Display','off');
    x  = lsqnonlin(f, x0, [], [], opts);

    % matriz final
    s = x(1);  th = x(2);  tx = x(3);  ty = x(4);
    R = s*[cos(th) -sin(th); sin(th) cos(th)];

    % aplicar a exterior
    P_out = R*P_det + [tx;ty];

    % aplicar a interiores
    P_int_out = cell(size(P_int_det));
    for k = 1:numel(P_int_det)
        P_int_out{k} = R*P_int_det{k} + [tx;ty];
    end
end
