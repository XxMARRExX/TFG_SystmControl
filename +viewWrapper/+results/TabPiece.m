classdef TabPiece < handle
% TabPiece UI container for displaying and interacting with a single piece.
%
%   This class defines the layout and controls for a tab dedicated to one
%   piece within the application. It manages image preview, 
%   piece metadata, and action buttons (e.g., subpixel detection,
%   filtering, error calculation).
%
%   Properties:
%       - gridLayoutTab: main grid layout container for the tab 
%       - gridLayoutPieceInfo: grid layout for displaying piece information 
%       - gridLayoutButtons: grid layout for arranging action buttons 
%       - idPiece: Id of the Bbox of the piece
%       - previewPiece: UI component for showing the piece image 
%       - imagePiece: Image of the piece
%       - showImageButton: button to show the piece image 
%       - detectedEdgesButton: button to display subpixel edge detection 
%       - filterButton: button to display edges filtered
%       - errorButton: button to display error metrics 
    
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
            self.showImageButton.Callback = callbackFcn;
        end


        function setShowDetectedEdgesAction(self, callbackFcn)
            self.detectedEdgesButton.Callback = callbackFcn;
        end


        function setShowFilteredEdgesAction(self, callbackFcn)
            self.filterButton.Callback = callbackFcn;
        end


        function setShowFilteredStagesAction(self, callbackFcn)
            self.showFilterStages.Callback = callbackFcn;
        end


        function setShowPreviousFilteredStageAction(self, callbackFcn)
            self.prevFilterStage.Callback = callbackFcn;
        end


        function setShowNextFilteredStageAction(self, callbackFcn)
            self.nextFilterStage.Callback = callbackFcn;
        end


        function setShowErrorStagesAction(self, callbackFcn)
            self.showErrorStages.Callback = callbackFcn;
        end

        
        function setShowPreviousErrorStageAction(self, callbackFcn)
            self.prevErrorStage.Callback = callbackFcn;
        end


        function setShowNextErrorStageAction(self, callbackFcn)
            self.nextErrorStage.Callback = callbackFcn;
        end

    end

    methods (Access = private)
        
        function buildLayoutTab(self, image)
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
            hbox1 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);

            self.showImageButton = uicontrol('Parent', hbox1, ...
                'Style', 'pushbutton', 'String', 'Mostrar imagen');
            self.detectedEdgesButton = uicontrol('Parent', hbox1, ...
                'Style', 'pushbutton', 'String', 'Mostrar bordes detectados');
            
            set(hbox1, 'Widths', [-1 -1]); 
        end


        function buildSecondRow(self)
            hbox2 = uix.HBox('Parent', self.vbox, 'Spacing', ...
                8, 'BackgroundColor', [1 1 1]);

            self.filterButton = uicontrol('Parent', hbox2, ...
                'Style', 'pushbutton', 'String', 'Mostrar bordes filtrados');
            self.errorButton = uicontrol('Parent', hbox2, ...
                'Style', 'pushbutton', 'String', 'Mostrar error producido');
            
            set(hbox2, 'Widths', [-1 -1]);
        end


        function buildThirdRow(self)
            hbox3 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);

            self.prevFilterStage = uicontrol('Parent', hbox3, ...
                'Style', 'pushbutton', 'String', 'Etapa previa');
            self.showFilterStages = uicontrol('Parent', hbox3, ...
                'Style', 'pushbutton', 'String', 'Mostrar etapas de filtrado');
            self.nextFilterStage = uicontrol('Parent', hbox3, ...
                'Style', 'pushbutton', 'String', 'Etapa posterior');

            set(hbox3, 'Widths', [-1 -1 -1]);
        end


        function buildFourthRow(self)
            hbox4 = uix.HBox('Parent', self.vbox, ...
                'Spacing', 8, 'BackgroundColor', [1 1 1]);

            self.prevErrorStage = uicontrol('Parent', hbox4, ...
                'Style', 'pushbutton', 'String', 'Etapa previa');
            self.showErrorStages = uicontrol('Parent', hbox4, ...
                'Style', 'pushbutton', 'String', 'Mostrar etapas de error');
            self.nextErrorStage = uicontrol('Parent', hbox4, ...
                'Style', 'pushbutton', 'String', 'Etapa posterior');

            set(hbox4, 'Widths', [-1 -1 -1]);
        end

    end

end

