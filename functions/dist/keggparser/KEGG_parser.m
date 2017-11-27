function varargout = KEGG_parser(varargin)
global kegg_path 
global full_path_col

% KEGG_PARSER MATLAB code for KEGG_parser.fig
%      KEGG_PARSER, by itself, creates a new KEGG_PARSER or raises the existing
%      singleton*.
%
%      H = KEGG_PARSER returns the handle to a new KEGG_PARSER or the handle to
%      the existing singleton*.
%
%      KEGG_PARSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KEGG_PARSER.M with the given input arguments.
%
%      KEGG_PARSER('Property','Value',...) creates a new KEGG_PARSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KEGG_parser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KEGG_parser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KEGG_parser

% Last Modified by GUIDE v2.5 09-Oct-2013 22:33:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KEGG_parser_OpeningFcn, ...
                   'gui_OutputFcn',  @KEGG_parser_OutputFcn, ...
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



% --- Executes just before KEGG_parser is made visible.
function KEGG_parser_OpeningFcn(hObject, eventdata, handles, varargin) %ebentdata
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KEGG_parser (see VARARGIN)

% Choose default command line output for KEGG_parser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KEGG_parser wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = KEGG_parser_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%// THIS PART OF CODE MIGHT BE USEFUL IN FUTURE
% % % --- Executes on selection change in node1.
% function node1_Callback(hObject, eventdata, handles)
% % % hObject    handle to node1 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hints: contents = cellstr(get(hObject,'String')) returns node1 contents as cell array
% % %        contents{get(hObject,'Value')} returns selected item from node1


% % --- Executes during object creation, after setting all properties.
% function node1_CreateFcn(hObject,~,~) %#ok<DEFNU> %eventdata, handles
% % hObject    handle to node1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% % % --- Executes on selection change in node2.
% function node2_Callback(hObject, eventdata, handles)
% % % hObject    handle to node2 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
% % 
% % % Hints: contents = cellstr(get(hObject,'String')) returns node2 contents as cell array
% % %        contents{get(hObject,'Value')} returns selected item from node2


% % --- Executes during object creation, after setting all properties.
% function node2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% % hObject    handle to node2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
%//END


% --- loads and parses KEGG pathway map from downloaded KGML file
function search_local_xml_Callback(hObject, eventdata, handles) 
% hObject    handle to search_local_xml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.xml'},'File Selector');
full_path = [PathName,FileName];
if any(full_path)==0
    return;
end
pcp = get(handles.pcp_flag,'Value');
gn = get(handles.gn_flag,'Value');
bid = get(handles.bid_flag,'Value');
fix_flag = [pcp,gn,bid];
[bg, ~, ~] = parse_KEGG_xml(full_path, fix_flag);
set(handles.address_bar,'String',full_path);
bh = view(bg);
path_name = get(bg,'ID');
path_name = char(regexp(path_name,'hsa\d+','match'));
if ~isempty(path_name)
try
    h = load_image(path_name);
catch
    disp('Check inet connection')
end
end
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
pos = get(par,'Position');
pos(3) = pos(3)*0.75;
pos(4) = pos(3)*0.75;
set(par,'Position',pos)
id = get(bg.Nodes,'ID');
set(handles.node1,'String',id,'Max', length(id));
set(handles.node2,'String',id,'Max', length(id));
usr.bg = bg;
usr.bh = bh;
%usr.h = h;
set(handles.figure1,'Userdata',usr);
figure(handles.figure1)

% --- downloads and parses KEGG pathway map specified in address bar 
%(requires pathway id, e.g. hsa04062)
function load_www_Callback(hObject, eventdata, handles)
% hObject    handle to load_www (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
map_name = get(handles.address_bar,'string');
map_name = strtrim(map_name);
url = 'http://www.kegg.jp/kegg-bin/download?entry=xxx&format=kgml';
full_path =  regexprep(url, 'xxx', map_name);
pcp = get(handles.pcp_flag,'Value');
gn = get(handles.gn_flag,'Value');
bid = get(handles.bid_flag,'Value');
fix_flag = [pcp,gn,bid];
[bg, ~, ~] = parse_KEGG_xml(full_path,fix_flag);
set(handles.address_bar,'String',full_path);
setappdata(hObject,'bg',bg);
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
pos = get(par,'Position');
pos(3) = pos(3)*0.75;
pos(4) = pos(3)*0.75;
set(par,'Position',pos)
id = get(bg.Nodes,'ID');
set(handles.node1,'String',id,'Max', length(id), 'Value', 1);
set(handles.node2,'String',id,'Max', length(id),'Value', 1);
h = load_image(map_name);
usr.bg = bg;
usr.bh = bh;
usr.h = h;
set(handles.figure1,'Userdata',usr);
figure(handles.figure1)

%// THIS PART OF CODE MIGHT BE USEFUL IN FUTURE
% function address_bar_Callback(hObject, eventdata, handles)
% % hObject    handle to address_bar (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of address_bar as text
% %        str2double(get(hObject,'String')) returns contents of address_bar as a double


% % --- Executes during object creation, after setting all properties.
% function address_bar_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% % hObject    handle to address_bar (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
%//END


% --- adds new node to pathway graph object 
%(node properties can be edited with right-click->Node Properties)
function node_add_Callback(hObject, eventdata, handles)
% hObject    handle to node_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
usr = get(handles.figure1,'Userdata');
bh = usr.bh;
bg = usr.bg;
par = get(bh.hgAxes,'Parent');
node_pos = get(par, 'CurrentPoint');
node_size = [46.08, 17.28];
UserData.List = [];
UserData.Link = []; 
bg = node_add(bg, node_pos, node_size, UserData);
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels');
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
id = get(bg.Nodes,'ID');
set(handles.node1,'String',id,'Max', length(id));
set(handles.node2,'String',id,'Max', length(id));
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);

% --- deletes node specifird by "Node 1" selection box only 
%(also removes all edges to/from the node)
function node_del_Callback(hObject, eventdata, handles)
% hObject    handle to node_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NodeID = get(handles.node1,'Value');
usr = get(handles.figure1,'Userdata');
bg = usr.bg;
bg = node_del(bg,NodeID);
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);
set(handles.node1,'String',get(bg.Nodes,'ID'),...
    'Max',length(get(bg.Nodes,'ID')),'Value',1);
set(handles.node2,'String',get(bg.Nodes,'ID'),...
    'Max',length(get(bg.Nodes,'ID')),'Value',1);
figure(handles.figure1);

% --- adds edge between nodes specified by "Node 1" and "Node 2" selection boxes
function edge_add_Callback(hObject, eventdata, handles)
% hObject    handle to edge_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Source = get(handles.node1,'Value');
Sink = get(handles.node2,'Value');
usr = get(handles.figure1,'Userdata');
edge_type_val = get(handles.edge_col,'Value');
edge_type_def = get(handles.edge_col,'String');
edge_type = char(edge_type_def(edge_type_val));
try
bg = usr.bg.deepCopy;
catch
    bg = usr.bg;
end
bg = edge_add(bg,Source, Sink,edge_type);
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
dolayout(bg,'PathsOnly', true)
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);
figure(handles.figure1);

% --- deletes edge between nodes specified by "Node 1" and "Node 2" selection boxes
function edge_del_Callback(hObject, eventdata, handles)
% hObject    handle to edge_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind_1 = get(handles.node1,'Value');
ind_2 = get(handles.node2,'Value');
usr = get(handles.figure1,'Userdata');
try
    bg = usr.bg.deepCopy;
    bg = edge_del(bg, ind_1, ind_2);
catch
    bg = usr.bg;
    bg = edge_del(bg, ind_1, ind_2);
end
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels');
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);
figure(handles.figure1);


% ---  saves pathway graph object as single MAT file
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
usr = get(handles.figure1,'Userdata');
bg = usr.bg;
[filename, pathname] = uiputfile({'*.mat'},'Save as');
save([pathname,filename],'bg');


% --- loads parsed KEGG pathway map from MAT file
function search_local_bg_Callback(hObject, eventdata, handles) 
% hObject    handle to search_local_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile({'*.mat'},'File Selector');
full_path = [PathName,FileName];
if any(full_path)==0
    return;
end
set(handles.address_bar,'String',full_path);
s = load(full_path);
bg = s.(char(fieldnames(s)));
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
pos = get(par,'Position');
pos(3) = pos(3)*0.75;
pos(4) = pos(3)*0.75;
set(par,'Position',pos)
id = get(bg.Nodes,'ID');
set(handles.node1,'String',id,'Max', length(id));
set(handles.node2,'String',id,'Max', length(id));
usr.bg = bg;
usr.bh = bh;
usr.h = [];
set(handles.figure1,'Userdata',usr);
figure(handles.figure1)

%// THIS CODE MAY BE USED IN FURUTE
% % --- Executes on selection change in edge_col.
% function edge_col_Callback(hObject, eventdata, handles)
% % hObject    handle to edge_col (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns edge_col contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from edge_col
%//END


% --- Sets edge types during initialization of GUI
function edge_col_CreateFcn(hObject, eventdata, handles) 
% hObject    handle to edge_col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
string = [{'activation'}; {'inhibition'}; {'binding'}];
set(hObject,'String',string,'Max',length(string));


% --- saves current graph layout, corrects edge positions bewteen nodes.
function refresh_layout_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_layout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
usr = get(handles.figure1,'Userdata');
for i = 1:length(usr.bh.Nodes);
%     if i == 64
      %  disp('aaa');
    %end
    usr.bg.Nodes(i).Position = usr.bh.Nodes(i).Position;
    usr.bg.Nodes(i).Size = usr.bh.Nodes(i).Size;
    if ~strcmp(usr.bg.Nodes(i).Label,usr.bh.Nodes(i).Label)
        usr.bg.Nodes(i).Label = usr.bh.Nodes(i).Label;
    end
    if ~strcmp(usr.bg.Nodes(i).Shape,usr.bh.Nodes(i).Shape)
        usr.bg.Nodes(i).Shape = usr.bh.Nodes(i).Shape;
    end
    if ~strcmp(usr.bg.Nodes(i).ID,usr.bh.Nodes(i).ID)
        usr.bg.Nodes(i).ID = usr.bh.Nodes(i).ID;
    end
    
end
bg = usr.bg.deepCopy;
bh = usr.bh.deepCopy;
dolayout(bg, 'Pathsonly', true);
close(get(usr.bh.hgAxes,'Parent'));
% dolayout(bh, 'Pathsonly', true);
bh = view(bg);
usr.bg = bg.deepCopy;
usr.bh = bh;

id = get(usr.bg.Nodes,'ID');
set(handles.node1,'String',id,'Max', length(id));
set(handles.node2,'String',id,'Max', length(id));
set(handles.figure1,'Userdata',usr);


% --- loads parsed KEGG pathway map from locally stored collection in MAT file
% Collection is array of structures, each element represents separate
% pathway 
function load_local_coll_Callback(hObject, eventdata, handles)
% hObject    handle to load_local_coll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global kegg_path 
global full_path_col
if isempty(kegg_path)
[FileName,PathName] = uigetfile({'*.mat'},'File Selector');
full_path_col = [PathName,FileName];
set(handles.address_bar,'String',full_path_col);
s = load(full_path_col);
kegg_path = s.(char(fieldnames(s))); 
end
defs = cellstr(strvcat(kegg_path(:).definition)); 
defs = [{'New'};defs];
[Selection,ok] = listdlg('ListString',defs);    
if isempty(Selection)
    return;
elseif Selection ==1
    return; % maybe in future something else
else
    disp('ok');
end
bg = kegg_path(Selection-1).bg.deepCopy;
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
pos = get(par,'Position');
pos(3) = pos(3)*0.75;
pos(4) = pos(3)*0.75;
set(par,'Position',pos)
id = get(bg.Nodes,'ID');
% set(handles.node1,'String',id,'Max', length(id));
% set(handles.node2,'String',id,'Max', length(id));
set(handles.node1,'String',id,'Max', length(id),'Value',1);
set(handles.node2,'String',id,'Max', length(id),'Value',1);
usr.bg = bg;
usr.bh = bh;
usr.h = [];
set(handles.figure1,'Userdata',usr);
figure(handles.figure1)


% --- replaces pathway graph object with new one in collection file
function save_2col_Callback(hObject, eventdata, handles)
% hObject    handle to save_2col (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global kegg_path 
global full_path_col
if isempty(kegg_path)
if isempty(full_path_col)
[FileName,PathName] = uigetfile({'*.mat'},'File Selector');
full_path_col = [PathName,FileName];
set(handles.address_bar,'String',full_path_col);
s = load(full_path_col);
kegg_path = s.(char(fieldnames(s)));
end
end
defs = cellstr(strvcat(kegg_path(:).definition));
defs = [{'New'};defs];
[Selection,ok] = listdlg('ListString',defs);
usr = get(handles.figure1,'Userdata');
bg = usr.bg;
if isempty(Selection)
    return;
elseif Selection == 1
    kegg_path(end+1).entry_id = get(bg,'ID');
    kegg_path(end+1).definition = get(bg,'Label');
    kegg_path(end+1).bg = bg.deepCopy;
else
    kegg_path(Selection-1).bg = bg.deepCopy;
end
disp('ok');
if isempty(full_path_col)
    save kegg_path kegg_path;
else
save(full_path_col,'kegg_path');
end
% --- Executes on button press in export_xml.
function export_xml_Callback(hObject, eventdata, handles)
% hObject    handle to export_xml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Here will be export to xml');

% --- Executes on button press in export_txt.
function export_txt_Callback(hObject, eventdata, handles)
% hObject    handle to export_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Here will be text export option for Cytoscape');


% --- reverses edge direction between nodes specified by "Node 1" and "Node 2" selection boxes
function edge_rev_Callback(hObject, eventdata, handles) 
% hObject    handle to edge_rev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Source = get(handles.node1,'Value');
Sink = get(handles.node2,'Value');
usr = get(handles.figure1,'Userdata');
try
bg = usr.bg.deepCopy;
catch
 bg = usr.bg;
end
bg = edge_del(bg, Source, Sink);
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
edge_type_val = get(handles.edge_col,'Value');
edge_type_def = get(handles.edge_col,'String');
edge_type = char(edge_type_def(edge_type_val));
bg = edge_add(bg.deepCopy,Sink, Source,edge_type);
dolayout(bg,'PathsOnly', true)
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);
figure(handles.figure1);


% ---Close Graph Window and GUI
function Close_t_Callback(hObject, eventdata, handles)
% hObject    handle to Close_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
usr = get(handles.figure1,'Userdata');
if ~isempty(usr)
    try 
        close(get(usr.bh.hgAxes,'Parent'));
    end
end
clearvars -global kepp_path 
close(handles.figure1);


% ---Display Help
function Readme_t_Callback(hObject, eventdata, handles)
% hObject    handle to Readme_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fid = fopen('README.txt');
C = textscan(fid, '%s','Delimiter','\n');
screen = get(0,'ScreenSize');
msgh = figure('Visible', 'on','Units','pixels','position',...
    [100 50 screen(3)/2 screen(4)-100],'MenuBar', 'none',...
    'NumberTitle','off','Name','Help');
h = uicontrol(msgh,'Style','Listbox','String',C{:},'Units','pixels',...
    'position', [10 10 screen(3)/2-25 screen(4)-125],'HorizontalAlignment','left');
set(msgh,'Visible', 'on');


% ---Batch pathway download and parsing for selected organism 
function kegg_update_Callback(hObject, eventdata, handles)
% hObject    handle to kegg_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pcp = get(handles.pcp_flag,'Value');
gn = get(handles.gn_flag,'Value');
bid = get(handles.bid_flag,'Value');
fix_flag = [pcp,gn,bid];
kegg_batch(fix_flag);


% --- Executes on button press in pcp_flag.
function pcp_flag_Callback(hObject, eventdata, handles)
% hObject    handle to pcp_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pcp_flag


% --- Executes on button press in gn_flag.
function gn_flag_Callback(hObject, eventdata, handles)
% hObject    handle to gn_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gn_flag


% --- Executes on button press in bid_flag.
function bid_flag_Callback(hObject, eventdata, handles)
% hObject    handle to bid_flag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bid_flag


% --- Executes on button press in del_uncon.
function del_uncon_Callback(hObject, eventdata, handles)
% hObject    handle to del_uncon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
usr = get(handles.figure1,'Userdata');
bg = usr.bg;
cm = full(getmatrix(bg));
horiz = find(sum(cm,2)==0); % terminal nodes
vert = find(sum(cm,1)==0); % start nodes
uncon = intersect(horiz, vert);
for i = length(uncon):-1:1
bg = node_del(bg,uncon(i));
end
par_pos = get(get(usr.bh.hgAxes,'Parent'),'Position');
close(get(usr.bh.hgAxes,'Parent'));
bh = view(bg);
par = get(bh.hgAxes,'Parent');
set(par,'Units','pixels')
% pos = get(par,'Position');
% pos(3) = pos(3)*0.75;
% pos(4) = pos(3)*0.75;
set(par,'Position',par_pos);
usr.bg = bg;
usr.bh = bh;
set(handles.figure1,'Userdata',usr);
set(handles.node1,'String',get(bg.Nodes,'ID'),...
    'Max',length(get(bg.Nodes,'ID')),'Value',1);
set(handles.node2,'String',get(bg.Nodes,'ID'),...
    'Max',length(get(bg.Nodes,'ID')),'Value',1);
figure(handles.figure1);