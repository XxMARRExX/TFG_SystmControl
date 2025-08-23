function configCanvas(app)
    ax = app.UIAxes;
    
    % Configurar como lienzo plano
    cla(ax);
    axis(ax, 'equal');
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
    ax.XTick = [];
    ax.YTick = [];
    ax.Box = 'on';
    ax.Interactions = [ ...
        dataTipInteraction; ...
        panInteraction; ...
        zoomInteraction ...
    ];
    
    % Evitar el zoom fuera de los límites (lo controlamos manualmente)
    ax.Toolbar.Visible = 'off';  % Opcional: ocultar barra de herramientas del axes
end
