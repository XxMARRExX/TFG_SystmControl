classdef TabParams < handle
% TabParams  Configuration tab for processing parameters in the GUI.
%
%   This class builds and manages the "Parameters" tab of the application's
%   graphical interface. It provides grouped interactive controls that
%   allow the user to configure the main parameters used throughout the
%   image analysis and error computation pipeline.
%
%   The tab is composed of four collapsible parameter panels:
%       1. Subpixel Phase 1 parameters
%       2. Subpixel Phase 2 parameters
%       3. DBSCAN clustering parameters
%       4. Error calculation parameters
%
%   -----------------------------------------------------------------------
%   Properties
%   -----------------------------------------------------------------------
%
%   feedbackManager   : Instance of the feedback system used to show
%                       warnings and validation messages to the user.
%
%   tab               : UI tab container that holds all parameter panels.
%
%   subpixelPanelPhase1 : Panel containing subpixel phase 1 controls.
%   threshold_Ph1        : Numeric input for the edge detection threshold.
%   smoothIters_Ph1      : Numeric input for the number of smoothing iterations.
%   scale                : Numeric input for subpixel scaling factor.
%   margin               : Numeric input for the margin around the bounding box.
%
%   subpixelPanelPhase2 : Panel containing subpixel phase 2 controls.
%   threshold_Ph2        : Numeric input for the second-phase threshold.
%   smoothIters_Ph2      : Numeric input for smoothing iterations in phase 2.
%
%   dbscanPanel         : Panel with clustering parameters for DBSCAN.
%   minPoints           : Minimum number of points required to form a cluster.
%   epsilon             : Radius defining the neighborhood for DBSCAN.
%
%   errorPanel          : Panel containing error-related configuration.
%   pixelTomm           : Conversion ratio from pixels to millimeters.
%   tolerance           : Error tolerance threshold in millimeters.

    properties
        feedbackManager;
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
        function self = TabParams(tabGroup, feedbackManager)
        % TabParams() Class constructor for the configuration parameters tab.
        %
        %   Inputs:
        %       - tabGroup: parent UITabGroup where the tab will be created.
        %       - feedbackManager: instance responsible for displaying user feedback.
        
            self.feedbackManager = feedbackManager;
            
            % --- Create new tab (single column with scroll) ---
            self.tab = uitab(tabGroup, 'Title', 'Configuration Parameters');
            self.tab.BackgroundColor = [1 1 1];
        
            % --- Base 1x1 grid container ---
            grid = uigridlayout(self.tab, [1, 1], ...
                'RowHeight', {'1x'}, 'ColumnWidth', {'1x'}, ...
                'ColumnSpacing', 0, 'Padding', [0 0 0 0], ...
                'BackgroundColor', [1 1 1]);
        
            % --- Scrolling panel (uix) occupying cell (1,1) ---
            scroll = uix.ScrollingPanel('Parent', grid, 'BackgroundColor', [1 1 1]);
            scroll.Layout.Row = 1; 
            scroll.Layout.Column = 1;
        
            % --- Internal VBox container (uix) that will hold all parameter groups ---
            vbox = uix.VBox('Parent', scroll, ...
                'Spacing', 12, 'Padding', 10, 'BackgroundColor', [1 1 1]);
        
            % --- Build all parameter sections ---
            self.buildSubpixelPhase1(vbox);
            self.buildSubpixelPhase2(vbox);
            self.buildDBSCANParams(vbox);
            self.buildErrorParams(vbox);
            
            % --- Define fixed heights for each parameter group panel ---
            % Note: -1 would make the panel flexible (fill remaining space)
            set(vbox, 'Heights', [250 150 150 150]);  
            
            % --- Update scroll area dynamically when the layout changes ---
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
        % updateScroll() Adjusts the scrollable area height dynamically.
        %
        %   Inputs:
        %       - scroll: uix.ScrollingPanel object whose content height must be updated.
        %       - vbox  : uix.VBox container holding all parameter panels.
        
            pause(0.01); % Allows layout stabilization
            
            % --- Compute the total VBox height (sum of children, padding, and spacing)
            hVec = vbox.Heights;
            pad  = vbox.Padding;
            spac = vbox.Spacing;
            contentHeight = sum(hVec) + 2*pad + (numel(hVec)-1)*spac;
        
            % --- Update scroll only if there is a significant difference
            if abs(contentHeight - scroll.MinimumHeights) > 1e-3
                scroll.MinimumHeights = contentHeight;
            end
        end



        function buildSubpixelPhase1(self, vbox)
        % buildSubpixelPhase1() Creates the parameter panel for Subpixel Phase 1.
        %
        %   Inputs:
        %       - vbox: vertical container (uix.VBox) where the panel will be added.
        %
    
            % First pane
            self.subpixelPanelPhase1 = uipanel('Parent', vbox, ...
                'Title', 'Subpixel Fase 1', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]);                    
        
            % Inner layout
            subpixelLayout = uigridlayout(self.subpixelPanelPhase1, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % threshold_Ph1
            threshold_Ph1Label = uilabel(subpixelLayout, ...
                'Text', 'Umbral', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            threshold_Ph1Label.Layout.Row = 1;
            threshold_Ph1Label.Layout.Column = 1;
        
            self.threshold_Ph1 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 5, ...
                'ValueChangedFcn', @(src,~)validateThreshold_Ph1(self, src));
            self.threshold_Ph1.Layout.Row = 1;
            self.threshold_Ph1.Layout.Column = 2;
        
            % SmoothIters
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
                'Value', 5, ...
                'ValueChangedFcn', @(src,~)validateSmoothIters_Ph1(self, src));
            self.smoothIters_Ph1.Layout.Row = 2;
            self.smoothIters_Ph1.Layout.Column = 2;

            % Scale
            scaleLabel = uilabel(subpixelLayout, ...
                'Text', 'Escala', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            scaleLabel.Layout.Row = 3;
            scaleLabel.Layout.Column = 1;
            
            self.scale = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 0.15, ...
                'ValueChangedFcn', @(src,~)validateScale(self, src));
            self.scale.Layout.Row = 3;
            self.scale.Layout.Column = 2;

            % Margin
            marginLabel = uilabel(subpixelLayout, ...
                'Text', 'Margen', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            marginLabel.Layout.Row = 4;
            marginLabel.Layout.Column = 1;
            
            self.margin = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 15, ...
                'ValueChangedFcn', @(src,~)validateMargin(self, src));
            self.margin.Layout.Row = 4;
            self.margin.Layout.Column = 2;
        end


        function buildSubpixelPhase2(self, vbox)
        % buildSubpixelPhase2() Creates the Subpixel parameter panel.
        %
        %   Inputs:
        %       - vbox: vertical container (uix.VBox) where the panel will be added.
        %
        %   Creates the "Subpixel" parameter panel containing the numeric fields:
        %       - Threshold
        %       - Smoothing iterations
    
            % First pane
            self.subpixelPanelPhase2 = uipanel('Parent', vbox, ...
                'Title', 'Subpixel Fase 2', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]); 
        
            % Inner layout
            subpixelLayout = uigridlayout(self.subpixelPanelPhase2, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % threshold_Ph2
            threshold_Ph2Label = uilabel(subpixelLayout, ...
                'Text', 'Umbral', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            threshold_Ph2Label.Layout.Row = 1;
            threshold_Ph2Label.Layout.Column = 1;
        
            self.threshold_Ph2 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 5, ...
                'ValueChangedFcn', @(src,~)validateThreshold_Ph2(self, src));
            self.threshold_Ph2.Layout.Row = 1;
            self.threshold_Ph2.Layout.Column = 2;
        
            % SmoothIters
            smoothLabel = uilabel(subpixelLayout, ...
                'Text', 'Iteraciones de suavizado', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', subpixelLayout.BackgroundColor);
            smoothLabel.Layout.Row = 2;
            smoothLabel.Layout.Column = 1;
        
            self.smoothIters_Ph2 = uieditfield(subpixelLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 3, ...
                'ValueChangedFcn', @(src,~)validateSmoothIters_Ph2(self, src));
            self.smoothIters_Ph2.Layout.Row = 2;
            self.smoothIters_Ph2.Layout.Column = 2;
        end


        function buildDBSCANParams(self, vbox)
        % buildDBSCANParams() Creates the DBSCAN parameter panel.
        %
        %   Inputs:
        %       - vbox: vertical container (uix.VBox) where the panel will be added.
        %
        %   Creates the "DBSCAN" parameter panel containing the numeric fields:
        %       - Epsilon (neighborhood radius)
        %       - Minimum number of points

    
            % First pane
            self.dbscanPanel = uipanel('Parent', vbox, ...
                'Title', 'DBSCAN', ...
                'BackgroundColor', [0.7804 0.3882 0.2314], ...
                'FontWeight', 'bold', ...
                'ForegroundColor', [1 1 1]);
        
            % Inner layout
            dbscanLayout = uigridlayout(self.dbscanPanel, ...
                'BackgroundColor', [0.95 0.95 0.95]);
        
            % Epsilon
            epsilonLabel = uilabel(dbscanLayout, ...
                'Text', 'Epsilon', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', dbscanLayout.BackgroundColor);
            epsilonLabel.Layout.Row = 1;
            epsilonLabel.Layout.Column = 1;
        
            self.epsilon = uieditfield(dbscanLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 6, ...
                'ValueChangedFcn', @(src,~)validateEpsilon(self, src));
            self.epsilon.Layout.Row = 1;
            self.epsilon.Layout.Column = 2;
        
            % MinPoints
            minPointsLabel = uilabel(dbscanLayout, ...
                'Text', 'Mínimo de puntos', ...
                'HorizontalAlignment', 'center', ...
                'WordWrap', 'on', ...
                'BackgroundColor', dbscanLayout.BackgroundColor);
            minPointsLabel.Layout.Row = 2;
            minPointsLabel.Layout.Column = 1;
        
            self.minPoints = uieditfield(dbscanLayout, 'numeric', ...
                'HorizontalAlignment', 'center', ...
                'Value', 4, ...
                'ValueChangedFcn', @(src,~)validateMinPoints(self, src));
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
                'Value', 15, ...
                'ValueChangedFcn', @(src,~)validatePixelTomm(self, src));
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
                'Value', 0.3, ...
                'ValueChangedFcn', @(src,~)validateTolerance(self, src));
            self.tolerance.Layout.Row = 2;
            self.tolerance.Layout.Column = 2;
        end


        function validateThreshold_Ph1(self, src)
            val = src.Value;
            if val <= 0 || val > 255
                src.Value = 5;
                self.feedbackManager.showWarning("El valor del umbral en la fase 1, " + ...
                    "debe estar entre 0 y 255.");
            end
        end


        function validateSmoothIters_Ph1(self, src)
            val = src.Value;
            if val <= 0 || val > 10
                src.Value = 5;
                self.feedbackManager.showWarning("El valor de las iteraciones de suavizado " + ...
                    "en la fase 1, debe estar entre 0 y 10.");
            end
        end


        function validateScale(self, src)
            val = src.Value;
            if val <= 0 || val > 1
                src.Value = 0.15;
                self.feedbackManager.showWarning("El valor de las escala" + ...
                    "en la fase 1, debe estar entre 0 y 1.");
            end
        end


        function validateMargin(self, src)
            val = src.Value;
            if val <= 0 || val > 200
                src.Value = 15;
                self.feedbackManager.showWarning("El valor del margen del BoundingBox" + ...
                    "en la fase 1, debe estar entre 0 y 200.");
            end
        end

        
        function validateThreshold_Ph2(self, src)
            val = src.Value;
            if val <= 0 || val > 255
                src.Value = 5;
                self.feedbackManager.showWarning("El valor del umbral en la fase 2, " + ...
                    "debe estar entre 0 y 255.");
            end
        end


        function validateSmoothIters_Ph2(self, src)
            val = src.Value;
            if val <= 0 || val > 10
                src.Value = 5;
                self.feedbackManager.showWarning("El valor de las iteraciones de suavizado " + ...
                    "en la fase 2, debe estar entre 0 y 10.");
            end
        end


        function validateMinPoints(self, src)
            val = src.Value;
            if val <= 0 || val > 500
                src.Value = 4;
                self.feedbackManager.showWarning("El valor del numero mínimo de puntos en DBSCAN, " + ...
                    "debe estar entre 0 y 500.");
            end
        end


        function validateEpsilon(self, src)
            val = src.Value;
            if val <= 0 || val > 500
                src.Value = 6;
                self.feedbackManager.showWarning("El valor del epsilon (Radio de vencidad) en DBSCAN, " + ...
                    "debe estar entre 0 y 500.");
            end
        end


        function validatePixelTomm(self, src)
            val = src.Value;
            if val <= 0 || val > 100
                src.Value = 4;
                self.feedbackManager.showWarning("El valor de px a mm, " + ...
                    "debe estar entre 0 y 100.");
            end
        end


        function validateTolerance(self, src)
            val = src.Value;
            if val <= 0.1 || val > 1000
                src.Value = 0.3;
                self.feedbackManager.showWarning("El valor de la tolerancia del error, " + ...
                    "debe estar entre 0.1 y 1000.");
            end
        end
    end
end

