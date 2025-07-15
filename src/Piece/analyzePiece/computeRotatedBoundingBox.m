function box = computeRotatedBoundingBox(edges, line, expansionX, expansionY)
    if nargin < 3, expansionX = 0.10; end
    if nargin < 4, expansionY = 0.05; end

    pts = [edges.x(:), edges.y(:)];
    theta = atan(line.m);

    R = [cos(-theta), -sin(-theta); sin(-theta), cos(-theta)];
    pts_rot = (R * pts')';

    x_rot = pts_rot(:,1);
    y_rot = pts_rot(:,2);

    x_low = prctile(x_rot, 2); x_high = prctile(x_rot, 98);
    y_low = prctile(y_rot, 2); y_high = prctile(y_rot, 98);

    idx_central = (x_rot >= x_low) & (x_rot <= x_high) & ...
                  (y_rot >= y_low) & (y_rot <= y_high);

    x_clean = x_rot(idx_central);
    y_clean = y_rot(idx_central);

    x_min = min(x_clean); x_max = max(x_clean);
    y_min = min(y_clean); y_max = max(y_clean);
    ancho = x_max - x_min;
    alto  = y_max - y_min;

    x_min = x_min - expansionX * ancho / 2;
    x_max = x_max + expansionX * ancho / 2;
    y_min = y_min - expansionY * alto / 2;
    y_max = y_max + expansionY * alto / 2;

    box_rot = [
        x_min, y_min;
        x_max, y_min;
        x_max, y_max;
        x_min, y_max;
        x_min, y_min
    ];

    box = (R' * box_rot')';
end
