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
        % clearTabs() Removes all result tabs and resets the console state.
        
            % --- Return early if tab group is invalid or not initialized ---
            if isempty(self.tabGroup) || ~isvalid(self.tabGroup)
                return;
            end
        
            % --- Remove all existing result tabs ---
            delete(self.tabGroup.Children);
        
            % --- Create an initial placeholder tab ---
            uitab(self.tabGroup, ...
                'Title', 'Results', ...
                'BackgroundColor', [1 1 1]);
        end


    end
    
end
