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
%       - imagePiece: UI component for showing the piece image 
%       - namePiece: label with the piece name 
%       - showImageButton: button to show the piece image 
%       - subpixelButton: button to display subpixel edge detection 
%       - filterButton: button to display edges filtered
%       - errorButton: button to display error metrics 
    
    properties
        tabPiece matlab.ui.container.Tab
        gridLayoutTab matlab.ui.container.GridLayout
        gridLayoutButtons matlab.ui.container.GridLayout

        imagePiece matlab.ui.control.UIAxes
        namePiece matlab.ui.control.Label

        showImageButton matlab.ui.control.Button
        subpixelButton matlab.ui.control.Button
        filterButton matlab.ui.control.Button
        errorButton matlab.ui.control.Button
    end
    
    methods (Access = public)
        
        function self = TabPiece(resultsConsole, image)

            self.tabPiece = uitab(resultsConsole, 'Title', char("Pieza"));

            % TabLayout
            self.gridLayoutTab = uigridlayout(self.tabPiece, [1, 2]);
            self.gridLayoutTab.RowHeight = {'1x'};
            self.gridLayoutTab.ColumnWidth = {'1x','1x'};

            % Image
            self.imagePiece = uiaxes(self.gridLayoutTab);
            self.imagePiece.Layout.Row = 1;
            self.imagePiece.Layout.Column = 1;
            self.imagePiece.Toolbar.Visible = 'off';
            self.imagePiece.Interactions = [];
            imshow(image, 'Parent', self.imagePiece);
            axis(self.imagePiece, 'image'); axis(self.imagePiece, 'off');
            
            % ButtonsLayout
            self.gridLayoutButtons = uigridlayout(self.gridLayoutTab, [2, 2]);
            self.gridLayoutButtons.Layout.Row = 1;
            self.gridLayoutButtons.Layout.Column = 2;
            self.gridLayoutButtons.ColumnWidth = {'1x', '1x'};
            self.gridLayoutButtons.RowHeight = {'1x', '1x'};

            % Buttons
            self.showImageButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar imagen');
            self.showImageButton.Layout.Column = 1;
            self.showImageButton.Layout.Row = 1;

            self.subpixelButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar bordes detectados');
            self.subpixelButton.Layout.Column = 1;
            self.subpixelButton.Layout.Row = 2;

            self.filterButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar bordes filtrados');
            self.filterButton.Layout.Column = 2;
            self.filterButton.Layout.Row = 1;

            self.errorButton = uibutton(self.gridLayoutButtons, 'push', ...
                'Text', 'Mostrar error producido');
            self.errorButton.Layout.Column = 2;
            self.errorButton.Layout.Row = 2;

        end

    end
end

