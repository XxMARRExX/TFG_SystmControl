classdef FeedbackManager < handle
    % FeedbackManager Centralized user feedback (progress, warnings, errors).
    %
    %   Handles modal dialogs for progress indication, warnings and errors.
    
    properties
        uiFig matlab.ui.Figure
        progressDialog matlab.ui.dialog.ProgressDialog
    end
    
    methods
        function self = FeedbackManager(uiFig)
            self.uiFig = uiFig;
        end
        

        function startProgress(self, title, message)
            self.progressDialog = uiprogressdlg(self.uiFig, ...
                'Title', title, ...
                'Message', message, ...
                'Indeterminate','off', ...
                'Value', 0);
        end
        

        function updateProgress(self, value, message)
            if ~isempty(self.progressDialog) && isvalid(self.progressDialog)
                self.progressDialog.Value = value;
                if nargin > 2
                    self.progressDialog.Message = message;
                end
                drawnow limitrate
            end
        end
        

        function closeProgress(self)
            if ~isempty(self.progressDialog) && isvalid(self.progressDialog)
                close(self.progressDialog);
            end
        end
        

        function showWarning(self, msg)
            uialert(self.uiFig, msg, 'Advertencia', 'Icon','warning');
        end
        
        
        function showError(self, msg)
            uialert(self.uiFig, msg, 'Error', 'Icon','error');
        end
    end
end
