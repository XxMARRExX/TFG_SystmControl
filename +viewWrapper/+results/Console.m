classdef Console < handle
    % Console  Results console that manages dynamic tabs to display
    %          information about pieces in the image.
    %       
    %   - Params
    %       tabGroup  Target container that holds all result tabs.

    properties (Access = private)
        tabGroup matlab.ui.container.TabGroup
    end

    methods
        function self = Console(tabGroupHandle)
            self.tabGroup = tabGroupHandle;
        end


        function tabGroup = getTabGroup(self)
            tabGroup = self.tabGroup;
        end


        function renderCroppedBBoxes(self, bbox)
        % renderCroppedBBoxes() Creates one tab per BBox and attaches a
        %                       result view for each cropped image.
        %
        %   Inputs:
        %       - bboxes: array of BBox objects.
        %       - canvasWrapper: Canvas wrapper instance, passed for
        %                 consistency with other render methods.
            
            viewWrapper.results.TabPiece( ...
                self.tabGroup, ...
                bbox.getCroppedImage(), ...
                bbox.getId(), ...
                sprintf(bbox.getLabel()));
            
        end


        function clearTabs(self)
        % reset() Clears all result tabs and resets the console state.
        %
        %   This method should be called when a new image is loaded, 
        %   ensuring the results console starts fresh.
    
            if isempty(self.tabGroup) || ~isvalid(self.tabGroup)
                return;
            end
    
            % Eliminar todas las pestañas existentes
            delete(self.tabGroup.Children);
    
            % Crear pestaña inicial o placeholder
            uitab(self.tabGroup, ...
                'Title', 'Resultados', ...
                'BackgroundColor', [1 1 1]);
        end

    end
    
end
