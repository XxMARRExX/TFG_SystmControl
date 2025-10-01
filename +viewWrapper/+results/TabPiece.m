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
        gridLayoutButtons matlab.ui.container.GridLayout
        
        idPiece string;
        previewPiece matlab.ui.control.UIAxes
        imagePiece uint8 = uint8([]);

        showImageButton matlab.ui.control.Button
        detectedEdgesButton matlab.ui.control.Button
        filterButton matlab.ui.control.Button
        errorButton matlab.ui.control.Button
    end
    
    methods (Access = public)
        
        function self = TabPiece(resultsConsole, image, id, title)
            
            self.idPiece = id;
            self.tabPiece = uitab(resultsConsole, 'Title', title);
            self.tabPiece.UserData = self;

            % TabLayout
            self.gridLayoutTab = uigridlayout(self.tabPiece, [1, 2]);
            self.gridLayoutTab.RowHeight = {'1x'};
            self.gridLayoutTab.ColumnWidth = {'1x','1x'};

            % Image
            self.imagePiece = image;
            self.previewPiece = uiaxes(self.gridLayoutTab);
            self.previewPiece.Layout.Row = 1;
            self.previewPiece.Layout.Column = 1;
            self.previewPiece.Toolbar.Visible = 'off';
            self.previewPiece.Interactions = [];
            imshow(image, 'Parent', self.previewPiece);
            axis(self.previewPiece, 'image'); axis(self.previewPiece, 'off');
            
            % ButtonsLayout
            self.gridLayoutButtons = uigridlayout(self.gridLayoutTab, [2, 2]);
            self.gridLayoutButtons.Layout.Row = 1;
            self.gridLayoutButtons.Layout.Column = 2;
            self.gridLayoutButtons.ColumnWidth = {'1x', '1x'};
            self.gridLayoutButtons.RowHeight = {'1x', '1x'};

            % Buttons
            self.showImageButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar imagen');
            self.showImageButton.Layout.Row = 1;
            self.showImageButton.Layout.Column = 1;

            self.detectedEdgesButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar bordes detectados');
            self.detectedEdgesButton.Layout.Row = 1;
            self.detectedEdgesButton.Layout.Column = 2;

            self.filterButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar bordes filtrados');
            self.filterButton.Layout.Row = 2;
            self.filterButton.Layout.Column = 1;

            self.errorButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar error producido');
            self.errorButton.Layout.Row = 2;
            self.errorButton.Layout.Column = 2;

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

    end

end

