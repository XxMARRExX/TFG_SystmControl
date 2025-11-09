classdef TabPiece < handle
% TabPiece  UI container for displaying and interacting with a single piece.
%
%   Properties (private):
%
%   tabPiece            : UITab object representing this piece's tab.
%
%   gridLayoutTab       : Main grid layout container of the tab.
%
%   gridLayoutPieceInfo : Grid layout for displaying piece metadata and info.
%
%   gridLayoutButtons   : Grid layout for arranging interactive buttons.
%
%   scrollPanel         : uix.ScrollingPanel that enables vertical scrolling
%                         within the tab content.
%
%   vbox                : uix.VBox container grouping the main UI sections
%                         (piece info, image preview, and buttons).
%
%   idPiece             : Identifier (string) of the piece’s bounding box.
%
%   previewPiece        : UIAxes component displaying the piece image or
%                         intermediate processing results.
%
%   imagePiece          : Image matrix (uint8) representing the visual data
%                         of the piece to be displayed in the preview.
%
%   showImageButton     : Button to display the original cropped image
%                         of the piece on the preview canvas.
%
%   detectedEdgesButton : Button to show the result of subpixel edge
%                         detection for the current piece.
%
%   filterButton        : Button to display the filtered edge results.
%
%   errorButton         : Button to visualize the computed geometric error
%                         and tolerance comparison.
%
%   prevFilterStage     : Button to navigate to the previous stage of the
%                         filtering process (if available).
%
%   nextFilterStage     : Button to navigate to the next stage of the
%                         filtering process (if available).
%
%   showFilterStages    : Button to show all available filtering stages.
%
%   prevErrorStage      : Button to navigate to the previous stage of the
%                         error computation process.
%
%   nextErrorStage      : Button to navigate to the next stage of the
%                         error computation process.
%
%   showErrorStages     : Button to display all available stages of error
%                         visualization.
    
    properties
        tabPiece matlab.ui.container.Tab
        gridLayoutTab matlab.ui.container.GridLayout
        scrollPanel
        vbox
        
        idPiece string;
        previewPiece matlab.ui.control.UIAxes
        imagePiece uint8 = uint8([]);

        showImageButton 
        detectedEdgesButton 
        filterButton 
        errorButton 
        prevFilterStage 
        nextFilterStage 
        showFilterStages 
        prevErrorStage 
        nextErrorStage 
        showErrorStages
    end
    
    methods (Access = public)
        
        function self = TabPiece(resultsConsole, image, id, title)
            
            self.idPiece = id;
            self.imagePiece = image;
            self.tabPiece = uitab(resultsConsole, 'Title', title);
            self.tabPiece.UserData = self;
            
            self.buildLayoutTab(image);
            self.buildFirstRow();
            self.buildSecondRow();
            self.buildThirdRow();
            self.buildFourthRow();
            
            set(self.vbox, 'Heights', [40 40 40 40]);
            self.scrollPanel.Heights = 200;
        end


        function id = getId(self)
            id = self.idPiece;
        end


        function setShowImageButtonAction(self, callbackFcn)
            self.showImageButton.ButtonPushedFcn = callbackFcn;
        end


        function setShowDetectedEdgesAction(self, callbackFcn)
            self.detectedEdgesButton.ButtonPushedFcn = callbackFcn;
        end


        function setShowFilteredEdgesAction(self, callbackFcn)
            self.filterButton.ButtonPushedFcn = callbackFcn;
        end


        function setShowErrorOnSVGAction(self, callbackFcn)
            self.errorButton.ButtonPushedFcn = callbackFcn;
        end


        function setShowFilteredStagesAction(self, callbackFcn)
            self.showFilterStages.ButtonPushedFcn = callbackFcn;
        end


        function setShowPreviousFilteredStageAction(self, callbackFcn)
            self.prevFilterStage.ButtonPushedFcn = callbackFcn;
        end


        function setShowNextFilteredStageAction(self, callbackFcn)
            self.nextFilterStage.ButtonPushedFcn = callbackFcn;
        end


        function setShowErrorStagesAction(self, callbackFcn)
            self.showErrorStages.ButtonPushedFcn = callbackFcn;
        end

        
        function setShowPreviousErrorStageAction(self, callbackFcn)
            self.prevErrorStage.ButtonPushedFcn = callbackFcn;
        end


        function setShowNextErrorStageAction(self, callbackFcn)
            self.nextErrorStage.ButtonPushedFcn = callbackFcn;
        end

    end

    methods (Access = private)
        
        function buildLayoutTab(self, image)
        % buildLayoutTab()  Builds the layout structure of a piece analysis tab.
        %
        %   Inputs:
        %       - image: image matrix to be displayed as the piece preview.
            % TabLayout
            self.gridLayoutTab = uigridlayout(self.tabPiece, [1, 2]);
            self.gridLayoutTab.RowHeight = {'1x'};
            self.gridLayoutTab.ColumnWidth = {'1x', '1x'};
            self.gridLayoutTab.ColumnSpacing = 8;
            self.gridLayoutTab.Padding = [5 5 5 5];
            self.gridLayoutTab.BackgroundColor = [1 1 1];
        
            % PreviewImage
            self.previewPiece = uiaxes(self.gridLayoutTab);
            self.previewPiece.Layout.Row = 1;
            self.previewPiece.Layout.Column = 1;
            self.previewPiece.Toolbar.Visible = 'off';
            self.previewPiece.Interactions = [];
            imshow(image, 'Parent', self.previewPiece);
            axis(self.previewPiece, 'image');
            axis(self.previewPiece, 'off');
        
            % scroollPanel
            self.scrollPanel = uix.ScrollingPanel('Parent', self.gridLayoutTab, ...
                'BackgroundColor', [1 1 1]);
            self.scrollPanel.Layout.Row = 1;
            self.scrollPanel.Layout.Column = 2;
        
            % verticalBox
            self.vbox = uix.VBox('Parent', self.scrollPanel, ...
                'Spacing', 10, 'Padding', 10, ...
                'BackgroundColor', [1 1 1]);
        end


        function buildFirstRow(self)
        % buildFirstRow()  Creates the first horizontal row of control buttons.
            
            % --- Horizontal layout container ---
            hbox1 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);
            
            % --- Button: Show Image ---
            self.showImageButton = uibutton(hbox1, 'push', ...
                'Text', 'Mostrar imagen', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 13, ...
                'BackgroundColor', [0.20 0.35 0.65], ...
                'FontColor', [1 1 1], ...
                'Tooltip', 'Muestra la imagen original', ...
                'FontWeight', 'bold', ...
                'WordWrap', 'on');
            
            % --- Button: Show Detected Edges ---
            self.detectedEdgesButton = uibutton(hbox1, 'push', ...
                'Text', 'Mostrar bordes detectados', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 13, ...
                'BackgroundColor', [0.20 0.35 0.65], ...
                'FontColor', [1 1 1], ...
                'Tooltip', 'Muestra los bordes detectados', ...
                'FontWeight', 'bold', ...
                'WordWrap', 'on');
            
            % --- Equal width distribution ---
            set(hbox1, 'Widths', [-1 -1]); 
        end


        function buildSecondRow(self)
        % buildSecondRow()  Creates the second horizontal row of control buttons.

            % --- Horizontal layout container ---
            hbox2 = uix.HBox('Parent', self.vbox, 'Spacing', ...
                8, 'BackgroundColor', [1 1 1]);
            
            % --- Button: Show Filtered Edges ---
            self.filterButton = uibutton(hbox2, 'push', ...
                'Text', 'Mostrar bordes filtrados', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 13, ...
                'BackgroundColor', [0.20 0.35 0.65], ...
                'FontColor', [1 1 1], ...
                'Tooltip', 'Muestra los bordes filtrados', ...
                'FontWeight', 'bold', ...
                'WordWrap', 'on');
            
            % --- Button: Show Computed Error ---
            self.errorButton = uibutton(hbox2, 'push', ...
                'Text', 'Mostrar error producido', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 13, ...
                'BackgroundColor', [0.20 0.35 0.65], ...
                'FontColor', [1 1 1], ...
                'Tooltip', 'Muestra la comparación con el modelo SVG y el error calculado', ...
                'FontWeight', 'bold', ...
                'WordWrap', 'on');
            
            % --- Equal width distribution ---
            set(hbox2, 'Widths', [-1 -1]);
        end


        function buildThirdRow(self)
        % buildThirdRow()  Creates the third horizontal row of stage navigation controls.

            % --- Horizontal layout container ---
            hbox3 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);
            
            % --- Button: Previous Filtering Stage ---
            self.prevFilterStage = uibutton(hbox3, 'push', ...
                'Text', 'Etapa previa', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Muestra la etapa de filtrado anterior', ...
                'WordWrap', 'on');
            
            % --- Button: Show All Filtering Stages ---
            self.showFilterStages = uibutton(hbox3, 'push', ...
                'Text', 'Mostrar etapas de filtrado', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Visualiza todas las etapas del proceso de filtrado', ...
                'WordWrap', 'on');
            
            % --- Button: Next Filtering Stage ---
            self.nextFilterStage = uibutton(hbox3, 'push', ...
                'Text', 'Etapa posterior', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Avanza a la siguiente etapa de filtrado', ...
                'WordWrap', 'on');
            
            % --- Equal width distribution ---
            set(hbox3, 'Widths', [-1 -1 -1]);
        end


        function buildFourthRow(self)
        % buildFourthRow()  Creates the fourth horizontal row of error stage navigation controls.

            % --- Horizontal layout container ---
            hbox4 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);
            
            % --- Button: Previous Error Stage ---
            self.prevErrorStage = uibutton(hbox4, 'push', ...
                'Text', 'Etapa previa', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Muestra la etapa de error anterior', ...
                'WordWrap', 'on');
            
            % --- Button: Show All Error Stages ---
            self.showErrorStages = uibutton(hbox4, 'push', ...
                'Text', 'Mostrar etapas de error', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Visualiza todas las etapas intermedias del cálculo de error', ...
                'WordWrap', 'on');
            
            % --- Button: Next Error Stage ---
            self.nextErrorStage = uibutton(hbox4, 'push', ...
                'Text', 'Etapa posterior', ...
                'FontName', 'Segoe UI', ...
                'FontSize', 11, ...
                'BackgroundColor', [0.94 0.94 0.94], ...
                'FontWeight', 'normal', ...
                'FontColor', [0.25 0.25 0.25], ...
                'Tooltip', 'Avanza a la siguiente etapa del análisis de error', ...
                'WordWrap', 'on');
            
            % --- Equal width distribution ---
            set(hbox4, 'Widths', [-1 -1 -1]);
        end

    end

end

