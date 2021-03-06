function varargout = AnalysisLauncher(varargin)
% ANALYSISLAUNCHER MATLAB code for AnalysisLauncher.fig
%      ANALYSISLAUNCHER, by itself, creates a new ANALYSISLAUNCHER or raises the existing
%      singleton*.
%
%      H = ANALYSISLAUNCHER returns the handle to a new ANALYSISLAUNCHER or the handle to
%      the existing singleton*.
%
%      ANALYSISLAUNCHER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISLAUNCHER.M with the given input arguments.
%
%      ANALYSISLAUNCHER('Property','Value',...) creates a new ANALYSISLAUNCHER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisLauncher_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisLauncher_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisLauncher

% Last Modified by GUIDE v2.5 04-Oct-2015 19:41:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalysisLauncher_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalysisLauncher_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AnalysisLauncher is made visible.
function AnalysisLauncher_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalysisLauncher (see VARARGIN)

% Choose default command line output for AnalysisLauncher
handles.output = hObject;

% Set avi-file radiobutton off and root folder radiobutton on
set(handles.file_radio,'Value',0)
set(handles.avi_batch_radio,'Value',1)
handles.input_type = 'avi_batch';
set(handles.stk_batch_radio,'Value',0)

% Determine the size of the MatLab parallel processing pool

handles.parallelFlag = true;

v = ver;
if any(strcmp('Parallel Computing Toolbox', {v.Name}))
    currentPool = gcp('nocreate');
    if isempty(currentPool)
        handles.parallel_CPUs = 0;
    else
        handles.parallel_CPUs = currentPool.NumWorkers;
    end
    if handles.parallel_CPUs > 0
        set(handles.parallel_check,'Value',1)
        set(handles.CPU_edit,'String',num2str(handles.parallel_CPUs))
    else
        set(handles.parallel_check,'Value',0)
        set(handles.CPU_edit,'String','0')
    end
else
    handles.parallelFlag = false;
    set(handles.parallel_check,'Enable','off');
    set(handles.CPU_edit,'Enable','off');
end

% Initial path from which source and target files are searched
handles.source_path = pwd;
handles.target_path = pwd;

% Store the old relative length change analysis parameter
handles.old_rel_length_change_value = ...
    str2double(get(handles.rel_length_change_edit,'String'));
% Store the old BW threshold value
handles.old_BW_threshold_value = ...
    str2double(get(handles.BW_threshold_edit,'String'));


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnalysisLauncher wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisLauncher_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pick_source_button.
function pick_source_button_Callback(hObject, eventdata, handles)
% hObject    handle to pick_source_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Request folder in case of batch analysis, request file in case of file
%analysis
if strcmp(handles.input_type,'avi_batch')
    handles.source_path = uigetdir(handles.source_path, ...
        'Pick .avi source root folder');
    set(handles.source_edit,'String',handles.source_path);
elseif strcmp(handles.input_type,'stk_batch')
    handles.source_path = uigetdir(handles.source_path, ...
        'Pick .stk source root folder');
    set(handles.source_edit,'String',handles.source_path);
elseif strcmp(handles.input_type,'file')
    [file,handles.source_path] = uigetfile([handles.source_path filesep '*.avi'], ...
        'Pick source .avi video');
    set(handles.source_edit,'String',...
        [handles.source_path filesep file])
end
handles.source_full_path = get(handles.source_edit,'String');

guidata(hObject,handles)


% --- Executes on button press in pick_target_button.
function pick_target_button_Callback(hObject, eventdata, handles)
% hObject    handle to pick_target_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Request target folder to save analysis results in
handles.target_path = uigetdir(handles.target_path, ...
    'Pick target root folder');

set(handles.target_edit,'String',handles.target_path);

guidata(hObject,handles)


function source_edit_Callback(hObject, eventdata, handles)
% hObject    handle to source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source_edit as text
%        str2double(get(hObject,'String')) returns contents of source_edit as a double

set(handles.source_edit,'String',handles.source_full_path)

guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function source_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_edit_Callback(hObject, eventdata, handles)
% hObject    handle to target_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of target_edit as text
%        str2double(get(hObject,'String')) returns contents of target_edit as a double

set(handles.target_edit,'String',handles.target_path)

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function target_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in file_radio.
function file_radio_Callback(hObject, eventdata, handles)
% hObject    handle to file_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of file_radio

% Set avi-file radiobutton off and root folder radiobutton on
set(handles.file_radio,'Value',1)
set(handles.avi_batch_radio,'Value',0)
set(handles.stk_batch_radio,'Value',0)
handles.input_type = 'file';

guidata(hObject,handles)


% --- Executes on button press in avi_batch_radio.
function avi_batch_radio_Callback(hObject, eventdata, handles)
% hObject    handle to avi_batch_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avi_batch_radio

% Set avi-file radiobutton off and root folder radiobutton on
set(handles.file_radio,'Value',0)
set(handles.avi_batch_radio,'Value',1)
set(handles.stk_batch_radio,'Value',0)
handles.input_type = 'avi_batch';

guidata(hObject,handles)




% --- Executes on button press in stk_batch_radio.
function stk_batch_radio_Callback(hObject, eventdata, handles)
% hObject    handle to stk_batch_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stk_batch_radio

% Set avi-file radiobutton off and root folder radiobutton on
set(handles.file_radio,'Value',0)
set(handles.avi_batch_radio,'Value',0)
set(handles.stk_batch_radio,'Value',1)
handles.input_type = 'stk_batch';

guidata(hObject,handles)



% --- Executes on button press in parallel_check.
function parallel_check_Callback(hObject, eventdata, handles)
% hObject    handle to parallel_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of parallel_check

if handles.parallelFlag
    
    v = ver;
    if any(strcmp('Parallel Computing Toolbox', {v.Name}))
        currentPool = gcp('nocreate');
        if isempty(currentPool)
            handles.parallel_CPUs = 0;
        else
            handles.parallel_CPUs = currentPool.NumWorkers;
        end
        if handles.parallel_CPUs > 0
            delete(currentPool);
        else
            if str2double(get(handles.CPU_edit,'String')) > 0
                currentPool = ...
                    parpool(str2double(get(handles.CPU_edit,'String')));
            else
                currentPool = parpool;
            end
        end
        
        currentPool = gcp('nocreate');
                
        if isempty(currentPool)
            handles.parallel_CPUs = 0;
        else
            handles.parallel_CPUs = currentPool.NumWorkers;
        end
        if handles.parallel_CPUs > 0
            set(handles.parallel_check,'Value',1)
        else
            set(handles.parallel_check,'Value',0)
        end
        set(handles.CPU_edit,'String',num2str(handles.parallel_CPUs))

    else
        handles.parallelFlag = false;
        set(handles.parallel_check,'Enable','off');
        set(handles.CPU_edit,'Enable','off');
        fprintf('Could not find Parallel Computing Toolbox installed.\n')
    end
    
    
end


function CPU_edit_Callback(hObject, eventdata, handles)
% hObject    handle to CPU_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CPU_edit as text
%        str2double(get(hObject,'String')) returns contents of CPU_edit as a double

handles.CPUs = ceil(str2double(get(handles.CPU_edit,'String')));
set(handles.CPU_edit,'String',num2str(handles.CPUs))

% --- Executes during object creation, after setting all properties.
function CPU_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CPU_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in start_button.
function start_button_Callback(hObject, eventdata, handles)
% hObject    handle to start_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

source_exist_value = ...
    exist(get(handles.source_edit,'String')','file');
target_exist_value = ...
    exist(get(handles.target_edit,'String')','file');

if ~source_exist_value
    msgbox('Choose valid source path.','Invalid source path','error')
    return
elseif ~target_exist_value
    msgbox('Choose valid target path','Invalid target path','error')
    return
end

if strcmp(handles.input_type,'avi_batch') && source_exist_value == 2
    msgbox('Choose a valid source folder, then press start again.', ...
        'Source not a folder','error')
    return
elseif strcmp(handles.input_type,'stk_batch') && source_exist_value == 2
    msgbox('Choose a valid source folder, then press start again.', ...
        'Source not a folder','error')
    return
elseif strcmp(handles.input_type,'file') && source_exist_value == 7
    msgbox('Choose a valid source .avi video, then press start again.', ...
        'Source not an .avi file','error')
    return
end
    

% ------------
% Create input cell

target_root_directory = ...
        get(handles.target_edit,'String');

if strcmp(handles.input_type,'file')
    % -- In case single avi-file mode is chosen --
    
    videos = {get(handles.source_edit,'String'); ...
        get(handles.target_edit,'String')}.';
    
elseif strcmp(handles.input_type,'avi_batch')
    % -- In case .avi batch from a root folder was chosen --
    
    % --
    % Create input batch that will be used in EvaluateVideo function call
    
    %Get the source and target root directory
    source_root_directory = ...
        get(handles.source_edit,'String');
    %Call function that finds the paths to the videos
    [video_file_paths,target_paths] = ...
        findvideos(source_root_directory,target_root_directory);
    
    % Batch to supply to EvaluateVideo.m function
    videos = {video_file_paths{:};target_paths{:}}.';

elseif strcmp(handles.input_type,'stk_batch')
    % -- In case .stk batch from a root folder was chosen --
    
    % --
    % Create input batch that will be used in EvaluateVideo function call
    
    %Get the source and target root directory
    source_root_directory = ...
        get(handles.source_edit,'String');
    %Call function that finds the paths to the videos
    [video_file_paths,target_paths] = ...
        findTIFFstacks(source_root_directory,target_root_directory);
    
    % Batch to supply to EvaluateVideo.m function
    videos = {video_file_paths{:};target_paths{:}}.';
    
end


% ------------
% Create structure containing the analysis parameters
parameters = struct;

%File type:
if strcmp(handles.input_type,'file')
    parameters.file_type = 'avi';
elseif strcmp(handles.input_type,'avi_batch')
    parameters.file_type = 'avi';
elseif strcmp(handles.input_type,'stk_batch')
    parameters.file_type = 'stk';
end

%Micrometers per pixel in the video
parameters.scaling_factor = ...
    str2double(get(handles.scaling_factor_edit,'String'));

%Raw frames merged into one compressed frame
parameters.frames_to_merge = ...
    str2double(get(handles.frames_to_merge_edit,'String'));

%Black-white threshold value, between 0 and 1 (black-to-white
%grey-scales, respectively)
parameters.BW_threshold = ...
    str2double(get(handles.BW_threshold_edit,'String'));

%Minimal length below which detected objects are excluded from the
%analysis
parameters.min_length = ...
    str2double(get(handles.min_length_edit,'String'));

%Maximal relative length change up to which filaments are tracked as
%the same filament
parameters.rel_length_change = ...
    str2double(get(handles.rel_length_change_edit,'String'));

%Maximal absolute length change up to which filaments are tracked as
%the same filament
parameters.abs_length_change = ...
    str2double(get(handles.abs_length_change_edit,'String'));

%Minimum time (seconds)  a filament has to be present to be included
%for analysis
parameters.min_presence_time = ...
    str2double(get(handles.min_presence_time_edit,'String'));    

%Minimal length of a trace to be included for analysis
parameters.min_trace_length = ...
    str2double(get(handles.min_trace_length_edit,'String'));

% Removal of immotile frames ON (true), OFF (false), or manual 
% value (numeric value)
immotile_removal = get(handles.immotile_check,'Value');
if immotile_removal
    % if immotile frames removal was chosen
    immoremoval_auto = get(handles.immoremov_auto,'Value');
    if immoremoval_auto
        % if immotile frame removal should be executed automatically
        parameters.immotile_frame_removal = true;
    else
        % if immotile frame removal should be executed using a manually
        % specified value
        parameters.immotile_frame_removal = ...
            str2double(get(handles.immo_threshold_vel,'String'));
    end
else
    % if immotile frame removal was not chosen
    parameters.immotile_frame_removal = false;
end

% ------------
% Create structure containing analysis options
options = struct;
%Put out preprocessing control video
options.preprocessing_control_video = ...
    logical(get(handles.preprocessing_check,'Value'));
%Put out filament tracking control video
options.tracking_control_video = ...
    logical(get(handles.tracking_check,'Value'));
%Write breakage and trace results to plain text files
options.write_plain_text = ...
    logical(get(handles.plain_text_check,'Value'));

% -------------------
%Call to analysis function

fprintf('Call to analysis function...\n')
block_box = msgbox(['Do not use the interface while the analysis is running.' ...
    ' You might accidentally start a second run.' ...
    ' Check command line for progress.'],...
    'Analysis started',...
    'warn');

[target_folder_list, error_log,~,~,elapsed_time] = ...
    EvaluateVideo(videos,parameters,options);

% Save folder list for TraceDropper batch processing
save([target_root_directory filesep 'TraceDropper_listfile.mat'],...
    'target_folder_list');

fprintf('Analysis completed, computation time %f seconds\n',...
    elapsed_time)

if iscell(error_log)
    for ee = 1:numel(error_log)
        if ~isempty(error_log{ee})
            fprintf('\n%s\n',error_log{ee});
        end
    end
    msgbox('Errors occurred during analysis, check command line output.',...
        'Errors during analysis.','error')
end

guidata(hObject,handles)


% --- Executes on button press in plain_text_check.
function plain_text_check_Callback(hObject, eventdata, handles)
% hObject    handle to plain_text_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plain_text_check


% --- Executes on button press in preprocessing_check.
function preprocessing_check_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessing_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of preprocessing_check


% --- Executes on button press in tracking_check.
function tracking_check_Callback(hObject, eventdata, handles)
% hObject    handle to tracking_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tracking_check


% --- Executes on button press in immotile_check.
function immotile_check_Callback(hObject, eventdata, handles)
% hObject    handle to immotile_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of immotile_check

immotile_active = get(handles.immotile_check,'Value');

if immotile_active
    set(handles.immoremov_auto,'Enable','on')
    set(handles.immoremov_manual,'Enable','on')
    if get(handles.immoremov_manual,'Value')
        set(handles.immo_threshold_vel,'Enable','on')
    end
else
    set(handles.immoremov_auto,'Enable','off')
    set(handles.immoremov_manual,'Enable','off')
    set(handles.immo_threshold_vel,'Enable','off')
end

guidata(hObject,handles)


function min_trace_length_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_trace_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_trace_length_edit as text
%        str2double(get(hObject,'String')) returns contents of min_trace_length_edit as a double

%Make sure that minimum trace length analysis parameter is not negative
min_trace_length_value = ...
    str2double(get(handles.min_trace_length_edit,'String'));

% Make zero when negative, leave at same value if positive
min_trace_length_value = ...
    (min_trace_length_value>0).*min_trace_length_value;

%Reassign to edit field
set(handles.min_trace_length_edit,'String', ...
    num2str(min_trace_length_value))

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function min_trace_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_trace_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_presence_time_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_presence_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_presence_time_edit as text
%        str2double(get(hObject,'String')) returns contents of min_presence_time_edit as a double

%Make sure that minimum trace length analysis parameter is not negative
min_presence_time_value = ...
    str2double(get(handles.min_presence_time_edit,'String'));

% Make zero when negative, leave at same value if positive
min_presence_time_value = ...
    (min_presence_time_value>0).*min_presence_time_value;

%Reassign to edit field
set(handles.min_presence_time_edit,'String', ...
    num2str(min_presence_time_value))

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function min_presence_time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_presence_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function abs_length_change_edit_Callback(hObject, eventdata, handles)
% hObject    handle to abs_length_change_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of abs_length_change_edit as text
%        str2double(get(hObject,'String')) returns contents of abs_length_change_edit as a double

%Make sure that absolute length change analysis parameter is not negative
abs_length_change_value = ...
    str2double(get(handles.abs_length_change_edit,'String'));

% Make zero when negative, leave at same value if positive
abs_length_change_value = ...
    (abs_length_change_value>0).*abs_length_change_value;

%Reassign to edit field
set(handles.abs_length_change_edit,'String', ...
    num2str(abs_length_change_value))

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function rel_length_change_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rel_length_change_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rel_length_change_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rel_length_change_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rel_length_change_edit as text
%        str2double(get(hObject,'String')) returns contents of rel_length_change_edit as a double

% Make sure that relative length change analysis parameter is between
% 0 and 1
rel_length_change_value = ...
    str2double(get(handles.rel_length_change_edit,'String'));

% Go back to old value when out of range
if rel_length_change_value <= 0 || rel_length_change_value >=1
    rel_length_change_value = handles.old_rel_length_change_value;
end

handles.old_rel_length_change_value = rel_length_change_value;

%Reassign to edit field
set(handles.rel_length_change_edit,'String', ...
    num2str(rel_length_change_value))

guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function abs_length_change_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to abs_length_change_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scaling_factor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to scaling_factor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaling_factor_edit as text
%        str2double(get(hObject,'String')) returns contents of scaling_factor_edit as a double

%Make sure that magnification factor is not negative
scaling_factor_value = ...
    str2double(get(handles.scaling_factor_edit,'String'));

% Make zero when negative, leave at same value if positive
scaling_factor_value = ...
    (scaling_factor_value>0).*scaling_factor_value;

%Reassign to edit field
set(handles.scaling_factor_edit,'String', ...
    num2str(scaling_factor_value))

guidata(hObject,handles)




% --- Executes during object creation, after setting all properties.
function scaling_factor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaling_factor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frames_to_merge_edit_Callback(hObject, eventdata, handles)
% hObject    handle to frames_to_merge_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames_to_merge_edit as text
%        str2double(get(hObject,'String')) returns contents of frames_to_merge_edit as a double


%Make sure that only positive integer values are used for frames to merge
merge_value = ...
    str2double(get(handles.frames_to_merge_edit,'String'));

% Make zero when negative, leave at same value if positive
merge_value = ...
    (merge_value>0).*ceil(merge_value) + (merge_value<=0);

%Reassign to edit field
set(handles.frames_to_merge_edit,'String', ...
    num2str(merge_value))

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function frames_to_merge_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames_to_merge_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function BW_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to BW_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BW_threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of BW_threshold_edit as a double

% Make sure that the BW threshold value is between 0 and 1
BW_threshold_value = ...
    str2double(get(handles.BW_threshold_edit,'String'));

% Go back to old value when out of range
if BW_threshold_value <= 0 || BW_threshold_value >=1
    BW_threshold_value = handles.old_BW_threshold_value;
end

handles.old_BW_threshold_value = BW_threshold_value;

%Reassign to edit field
set(handles.BW_threshold_edit,'String', ...
    num2str(BW_threshold_value))

guidata(hObject,handles)





% --- Executes during object creation, after setting all properties.
function BW_threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BW_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_length_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_length_edit as text
%        str2double(get(hObject,'String')) returns contents of min_length_edit as a double

%Make sure that minimum length change analysis parameter is not negative
min_length_value = ...
    str2double(get(handles.min_length_edit,'String'));

% Make zero when negative, leave at same value if positive
min_length_value = ...
    (min_length_value>0).*min_length_value;

%Reassign to edit field
set(handles.min_length_edit,'String', ...
    num2str(min_length_value))

guidata(hObject,handles)






% --- Executes during object creation, after setting all properties.
function min_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_parameters_button.
function save_parameters_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_parameters_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------
% Create structure containing the analysis parameters
parameters = struct;

%Micrometers per pixel in the video
parameters.scaling_factor = ...
    str2double(get(handles.scaling_factor_edit,'String'));

%Raw frames merged into one compressed frame
parameters.frames_to_merge = ...
    str2double(get(handles.frames_to_merge_edit,'String'));

%Black-white threshold value, between 0 and 1 (black-to-white
%grey-scales, respectively)
parameters.BW_threshold = ...
    str2double(get(handles.BW_threshold_edit,'String'));

%Minimal length below which detected objects are excluded from the
%analysis
parameters.min_length = ...
    str2double(get(handles.min_length_edit,'String'));

%Maximal relative length change up to which filaments are tracked as
%the same filament
parameters.rel_length_change = ...
    str2double(get(handles.rel_length_change_edit,'String'));

%Maximal absolute length change up to which filaments are tracked as
%the same filament
parameters.abs_length_change = ...
    str2double(get(handles.abs_length_change_edit,'String'));

%Minimum time (seconds)  a filament has to be present to be included
%for analysis
parameters.min_presence_time = ...
    str2double(get(handles.min_presence_time_edit,'String'));    

%Minimal length of a trace to be included for analysis
parameters.min_trace_length = ...
    str2double(get(handles.min_trace_length_edit,'String'));

%Removal of immotile frames ON (true) or OFF (false)
parameters.immotile_frame_removal = ...
    logical(get(handles.immotile_check,'Value'));

[save_file,save_path] = uiputfile(pwd,'Save parameters in which file?');
save([save_path filesep save_file],'parameters')

guidata(hObject,handles)


% --- Executes on button press in load_parameter_button.
function load_parameter_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_parameter_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------
% Load parameters from file and assign to edit fields in the GUI

% ----
% Load parameters from file

%Which parameter file should be loaded?
[load_file,load_path] = uigetfile(pwd,'Select parameter file');

% Load from chosen file
load([load_path filesep load_file])

% ----
%Assign values from parameter file to edit fields in the GUI

%Micrometers per pixel in the video
set(handles.scaling_factor_edit,'String', ...
    num2str(parameters.scaling_factor))

%Raw frames merged into one compressed frame
set(handles.frames_to_merge_edit,'String', ...
    num2str(parameters.frames_to_merge))

%Black-white threshold value, between 0 and 1 (black-to-white
%grey-scales, respectively)
set(handles.BW_threshold_edit,'String', ...
    num2str(parameters.BW_threshold))

%Minimal length below which detected objects are excluded from the
%analysis
set(handles.min_length_edit,'String', ...
    num2str(parameters.min_length))

%Maximal relative length change up to which filaments are tracked as
%the same filament
set(handles.rel_length_change_edit,'String', ...
    num2str(parameters.rel_length_change))

%Maximal absolute length change up to which filaments are tracked as
%the same filament
set(handles.abs_length_change_edit,'String', ...
    num2str(parameters.abs_length_change))

%Minimum time (seconds)  a filament has to be present to be included
%for analysis
set(handles.min_presence_time_edit,'String', ...
    num2str(parameters.min_presence_time))

%Minimal length of a trace to be included for analysis
set(handles.min_trace_length_edit,'String', ...
    num2str(parameters.min_trace_length))

%Removal of immotile frames ON (true) or OFF (false)
set(handles.immotile_check,'Value', ...
    double(parameters.immotile_frame_removal))

guidata(hObject,handles)


% --- Executes on button press in immoremov_auto.
function immoremov_auto_Callback(hObject, eventdata, handles)
% hObject    handle to immoremov_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.immoremov_auto,'Value',1)
set(handles.immoremov_manual,'Value',0)
set(handles.immo_threshold_vel,'Enable','off')

% Hint: get(hObject,'Value') returns toggle state of immoremov_auto

guidata(hObject,handles)

% --- Executes on button press in immoremov_manual.
function immoremov_manual_Callback(hObject, eventdata, handles)
% hObject    handle to immoremov_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.immoremov_auto,'Value',0)
set(handles.immoremov_manual,'Value',1)
set(handles.immo_threshold_vel,'Enable','on')

% Hint: get(hObject,'Value') returns toggle state of immoremov_auto

guidata(hObject,handles)



function immo_threshold_vel_Callback(hObject, eventdata, handles)
% hObject    handle to immo_threshold_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of immo_threshold_vel as text
%        str2double(get(hObject,'String')) returns contents of immo_threshold_vel as a double

try
    immo_threshold_vel = str2double(get(hObject,'String'));
    if immo_threshold_vel<0 || ~isfinite(immo_threshold_vel)
        set(hObject,'String',num2str(0))
    end
catch ME
    set(hObject,'String',num2str(0))
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function immo_threshold_vel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to immo_threshold_vel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





