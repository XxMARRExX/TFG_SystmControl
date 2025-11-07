classdef FeedbackManager < handle
% FeedbackManager Centralized user feedback (progress, warnings, errors).
%
%   Handles modal dialogs for progress indication, warnings and errors.
%
%   Properties:
%       - uiFig: Reference to the main UIFigure of the application.
%       - progressDialog: Handle to the current progress dialog
%           (matlab.ui.dialog.ProgressDialog).
    
    properties
        uiFig matlab.ui.Figure
        progressDialog matlab.ui.dialog.ProgressDialog
    end
    
    methods
        function self = FeedbackManager(uiFig)
            self.uiFig = uiFig;
        end
        

        function startProgress(self, title, message)
        % startProgress() Open a progress dialog with initial settings.
        %
        %   Inputs:
        %       - title:   Title of the progress dialog (string).
        %       - message: Initial message displayed in the dialog (string).
            self.progressDialog = uiprogressdlg(self.uiFig, ...
                'Title', title, ...
                'Message', message, ...
                'Indeterminate','off', ...
                'Value', 0);
        end
        

        function updateProgress(self, value, message)
        % updateProgress() Update progress value and optional message.
        %
        %   Inputs:
        %       - value:   Numeric value between 0 and 1 representing progress.
        %       - message: (optional) Message to update in the dialog (string).
            if ~isempty(self.progressDialog) && isvalid(self.progressDialog)
                self.progressDialog.Value = value;
                if nargin > 2
                    self.progressDialog.Message = message;
                end
                drawnow limitrate
            end
        end
        

        function closeProgress(self)
        % closeProgress() Close the current progress dialog if valid.
            if ~isempty(self.progressDialog) && isvalid(self.progressDialog)
                close(self.progressDialog);
            end
        end
        

        function showWarning(self, msg)
        % showWarning() Display a warning modal dialog.
        %
        %   Inputs:
        %       - msg: Warning message text (string).
            uialert(self.uiFig, msg, 'Advertencia', 'Icon','warning');
        end
        

        function showError(self, msg)
        % showError() Display an error modal dialog.
        %
        %   Inputs:
        %       - msg: Error message text (string).
            uialert(self.uiFig, msg, 'Error', 'Icon','error');
        end
    end
end
