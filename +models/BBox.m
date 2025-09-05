classdef BBox < handle
    %BBox Bounding box con soporte de dibujo (drawrectangle).
    
    properties (Access = private)
        id string;
        position (1,4) double;   % [x y w h]
        label string;
        rectHandle images.roi.Rectangle = images.roi.Rectangle.empty;
    end

    methods (Access = public)

        function self = BBox(position, label)
            self.id = BBox.generateRandomId();
            self.position = position;
            self.label = label;
        end


        function draw(obj, ax)
            % Crea (o reusa) el ROI en el axes dado.
            if isempty(obj.rectHandle) || ~isvalid(obj.rectHandle)
                obj.rectHandle = drawrectangle(ax, ...
                    'Position', obj.position, ...
                    'Label', char(obj.label), ...
                    'FaceAlpha', 0, 'Color', 'r', 'LineWidth', 1.5);
                % Mantener position sincronizada cuando el usuario edite
                addlistener(obj.rectHandle, 'MovingROI',  @(~,~) obj.syncFromHandle());
                addlistener(obj.rectHandle, 'ROIMoved',   @(~,~) obj.syncFromHandle());
            else
                obj.rectHandle.Parent = ax;                % reubicar si cambia el axes
                obj.rectHandle.Position = obj.position;    % asegurar posición
            end
        end

        function updatePosition(obj, newPos)
            % Actualiza datos y handle (si existe)
            obj.position = newPos;
            if ~isempty(obj.rectHandle) && isvalid(obj.rectHandle)
                obj.rectHandle.Position = newPos;
            end
        end

        function setVisible(obj, tf)
            if ~isempty(obj.rectHandle) && isvalid(obj.rectHandle)
                obj.rectHandle.Visible = matlab.lang.OnOffSwitchState(tf);
            end
        end

        function delete(obj)
            if ~isempty(obj.rectHandle) && isvalid(obj.rectHandle)
                delete(obj.rectHandle);
            end
        end

        % Getters útiles
        function s = getId(obj), s = obj.id; end
        function p = getPosition(obj), p = obj.position; end
        function setLabel(obj, s)
            obj.label = s;
            if ~isempty(obj.rectHandle) && isvalid(obj.rectHandle)
                obj.rectHandle.Label = char(s);
            end
        end
    end

    methods (Access = private)
        function syncFromHandle(obj)
            % Sincroniza la posición a partir del ROI cuando el usuario arrastra.
            if ~isempty(obj.rectHandle) && isvalid(obj.rectHandle)
                obj.position = obj.rectHandle.Position;
            end
        end
    end



    methods (Static)

        function id = generateRandomId()
            id = string(java.util.UUID.randomUUID);
        end

    end
end
