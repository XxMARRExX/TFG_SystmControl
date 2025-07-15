function [xOrd,yOrd] = ordenarContornoCircular(x,y)
    % centro aproximado
    cx = mean(x);  cy = mean(y);
    % ángulo polar de cada punto
    ang = atan2(y-cy, x-cx);
    [~,ord] = sort(ang);
    xOrd = x(ord);
    yOrd = y(ord);
end
