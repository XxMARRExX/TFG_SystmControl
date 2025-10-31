classdef TabParams < handle
    
    properties
        tab;

        subpixelPanelPhase1;
        threshold_Ph1;
        smoothIters_Ph1;
        scale;
        margin;

        subpixelPanelPhase2;
        threshold_Ph2;
        smoothIters_Ph2;

        dbscanPanel;
        minPoints;
        epsilon;

        errorPanel;
        pixelTomm;
        tolerance;
    end
    
    methods
        function self = TabParams(tabGroup)
            
            % Pestaña nueva (una sola columna con scroll)
            self.tab = uitab(tabGroup, 'Title', 'Parámetros de configuración');
            self.tab.BackgroundColor = [1 1 1];
        
            % Contenedor base 1x1
            grid = uigridlayout(self.tab, [1, 1], ...
                'RowHeight', {'1x'}, 'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, 'Padding', [0 0 0 0], ...
                'BackgroundColor', [1 1 1]);
        
            % ScrollingPanel (uix) en la celda (1,1)
            scroll = uix.ScrollingPanel('Parent', grid, 'BackgroundColor', [1 1 1]);
            scroll.Layout.Row = 1; 
            scroll.Layout.Column = 1;

            % VBox interno (uix) que contendrá los grupos
            vbox = uix.VBox('Parent', scroll, ...
                'Spacing', 12, 'Padding', 10, 'BackgroundColor', [1 1 1]);

            self.buildSubpixelPhase1(vbox);
            self.buildSubpixelPhase2(vbox);
            self.buildDBSCANParams(vbox);
            self.buildErrorParams(vbox);
            
            % --- Altura de cada grupo
            set(vbox, 'Heights', [250 150 150 150]);  % -1 = flexible (ocupa hueco restante)
            
            vbox.SizeChangedFcn = @(~,~) self.updateScroll(scroll, vbox);
        end


        function value = getThreshold_Ph1(self)
            value = self.threshold_Ph1.Value;
        end
        

        function value = getSmoothIters_Ph1(self)
            value = self.smoothIters_Ph1.Value;
        end
        

        function value = getScale(self)
            value = self.scale.Value;
        end
        

        function value = getMargin(self)
            value = self.margin.Value;
        end


        function value = getThreshold_Ph2(self)
            value = self.threshold_Ph2.Value;
        end
        

        function value = getSmoothIters_Ph2(self)
            value = self.smoothIters_Ph2.Value;
        end


        function value = getMinPoints(self)
            value = self.minPoints.Value;
        end
        

        function value = getEpsilon(self)
            value = self.epsilon.Value;
        end


        function value = getPixelTomm(self)
            value = self.pixelTomm.Value;
        end
        
        
        function value = getTolerance(self)
            value = self.tolerance.Value;
        end
    end



    methods (Access = private)
        function updateScroll(self, scroll, vbox)
            pause(0.01); % Permite estabilizar layout (MATLAB necesita 1 ciclo de dibujo)
        
            % Altura real del VBox (suma de hijos)
            hVec = vbox.Heights;
            pad  = vbox.Padding;
            spac = vbox.Spacing;
            contentHeight = sum(hVec) + 2*pad + (numel(hVec)-1)*spac;
        
            % Actualizar scroll solo si es necesario
            if abs(contentHeight - scroll.MinimumHeights) > 1e-3
                scroll.MinimumHeights = contentHeight;
            end
        end


        function buildSubpixelPhase1(self, vbox)
        % buildSubpixelParams()  Crea el panel de parámetros Subpixel.
        %
        %   Inputs:
        %       - vbox: contenedor vertical (uix.VBox) donde se añadirá el panel.
        %
        %   Crea el panel "Subpixel" con los campos "Umbral" e "Iteraciones de suavizado".
        %
    
            % --- Panel principal ---
            self.subpixelPanelPhase1 = uipanel('Parent', vbox, ...
                'Title', 'Subpixel Fase 1', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]);                    
        
            % --- Layout interno del panel ---
            subpixelLayout = uigridlayout(self.subpixelPanelPhase1, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % --- Etiqueta y campo: Umbral ---
            umbralLabel = uilabel(subpixelLayout, ...
                'Text', 'Umbral', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            umbralLabel.Layout.Row = 1;
            umbralLabel.Layout.Column = 1;
        
            self.threshold_Ph1 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 5);
            self.threshold_Ph1.Layout.Row = 1;
            self.threshold_Ph1.Layout.Column = 2;
        
            % --- Etiqueta y campo: Iteraciones de suavizado ---
            smoothLabel = uilabel(subpixelLayout, ...
                'Text', 'Iteraciones de suavizado', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            smoothLabel.Layout.Row = 2;
            smoothLabel.Layout.Column = 1;
        
            self.smoothIters_Ph1 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Placeholder', '1', ...
                'Value', 5);
            self.smoothIters_Ph1.Layout.Row = 2;
            self.smoothIters_Ph1.Layout.Column = 2;

            % --- Etiqueta y campo: Scale ---
            scaleLabel = uilabel(subpixelLayout, ...
                'Text', 'Escala', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            scaleLabel.Layout.Row = 3;
            scaleLabel.Layout.Column = 1;
            
            self.scale = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 0.15);
            self.scale.Layout.Row = 3;
            self.scale.Layout.Column = 2;

            % --- Etiqueta y campo: Margin ---
            marginLabel = uilabel(subpixelLayout, ...
                'Text', 'Margen', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            marginLabel.Layout.Row = 4;
            marginLabel.Layout.Column = 1;
            
            self.margin = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 15);
            self.margin.Layout.Row = 4;
            self.margin.Layout.Column = 2;
        end


        function buildSubpixelPhase2(self, vbox)
        % buildSubpixelParams()  Crea el panel de parámetros Subpixel.
        %
        %   Inputs:
        %       - vbox: contenedor vertical (uix.VBox) donde se añadirá el panel.
        %
        %   Crea el panel "Subpixel" con los campos "Umbral" e "Iteraciones de suavizado".
        %
    
            % --- Panel principal ---
            self.subpixelPanelPhase2 = uipanel('Parent', vbox, ...
                'Title', 'Subpixel Fase 2', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]); 
        
            % --- Layout interno del panel ---
            subpixelLayout = uigridlayout(self.subpixelPanelPhase2, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % --- Etiqueta y campo: Umbral ---
            umbralLabel = uilabel(subpixelLayout, ...
                'Text', 'Umbral', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            umbralLabel.Layout.Row = 1;
            umbralLabel.Layout.Column = 1;
        
            self.threshold_Ph2 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 5);
            self.threshold_Ph2.Layout.Row = 1;
            self.threshold_Ph2.Layout.Column = 2;
        
            % --- Etiqueta y campo: Iteraciones de suavizado ---
            smoothLabel = uilabel(subpixelLayout, ...
                'Text', 'Iteraciones de suavizado', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            smoothLabel.Layout.Row = 2;
            smoothLabel.Layout.Column = 1;
        
            self.smoothIters_Ph2 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 3);
            self.smoothIters_Ph2.Layout.Row = 2;
            self.smoothIters_Ph2.Layout.Column = 2;
        end


        function buildDBSCANParams(self, vbox)
        % buildDBSCANParams()  Crea el panel de parámetros DBSCAN.
        %
        %   Inputs:
        %       - vbox: contenedor vertical (uix.VBox) donde se añadirá el panel.
        %
        %   Crea el panel "DBSCAN" con los campos "Epsilon" y "Mínimo de puntos".
        %
    
            % --- Panel principal ---
            self.dbscanPanel = uipanel('Parent', vbox, ...
                'Title', 'DBSCAN', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]);
        
            % --- Layout interno del panel ---
            dbscanLayout = uigridlayout(self.dbscanPanel, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % --- Etiqueta y campo: Epsilon ---
            epsilonLabel = uilabel(dbscanLayout, ...
                'Text', 'Epsilon', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', dbscanLayout.BackgroundColor);
            epsilonLabel.Layout.Row = 1;
            epsilonLabel.Layout.Column = 1;
        
            self.epsilon = uieditfield(dbscanLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 6);
            self.epsilon.Layout.Row = 1;
            self.epsilon.Layout.Column = 2;
        
            % --- Etiqueta y campo: Mínimo de puntos ---
            minPointsLabel = uilabel(dbscanLayout, ...
                'Text', 'Mínimo de puntos', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', dbscanLayout.BackgroundColor);
            minPointsLabel.Layout.Row = 2;
            minPointsLabel.Layout.Column = 1;
        
            self.minPoints = uieditfield(dbscanLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 4);
            self.minPoints.Layout.Row = 2;
            self.minPoints.Layout.Column = 2;
        end



        function buildErrorParams(self, vbox)
        % buildErrorParams()  Crea el panel de parámetros de Error.
        %
        %   Inputs:
        %       - vbox: contenedor vertical (uix.VBox) donde se añadirá el panel.
        %
        %   Crea el panel "Error" con los campos "px a mm" y "Tolerancia".
        %
    
            % --- Panel principal ---
            self.errorPanel = uipanel('Parent', vbox, ...
                'Title', 'Error', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]); 
        
            % --- Layout interno del panel ---
            errorLayout = uigridlayout(self.errorPanel, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % --- Etiqueta: px a mm ---
            pxammLabel = uilabel(errorLayout, ...
                'Text', 'Px a mm', ...
                'HorizontalAlignment', 'center', ...
                'BackgroundColor', errorLayout.BackgroundColor);
            pxammLabel.Layout.Row = 1;
            pxammLabel.Layout.Column = 1;
        
            % --- Campo: pixelTomm ---
            self.pixelTomm = uieditfield(errorLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 15);
            self.pixelTomm.Layout.Row = 1;
            self.pixelTomm.Layout.Column = 2;
        
            % --- Etiqueta: Tolerancia ---
            tolLabel = uilabel(errorLayout, ...
                'Text', 'Tolerancia', ...
                'HorizontalAlignment', 'center', ...
                'BackgroundColor', errorLayout.BackgroundColor);
            tolLabel.Layout.Row = 2;
            tolLabel.Layout.Column = 1;
        
            % --- Campo: tolerance ---
            self.tolerance = uieditfield(errorLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 0.3);
            self.tolerance.Layout.Row = 2;
            self.tolerance.Layout.Column = 2;
        end

    end
end

