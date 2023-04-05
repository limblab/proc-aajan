function varargout = NerveReshaper(varargin)
% NERVERESHAPER M-file for NerveReshaper.fig
%      NERVERESHAPER, by itself, creates a new NERVERESHAPER or raises the existing
%      singleton*.
%
%      H = NERVERESHAPER returns the handle to a new NERVERESHAPER or the handle to
%      the existing singleton*.
%
%      NERVERESHAPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NERVERESHAPER.M with the given input arguments.
%
%      NERVERESHAPER('Property','Value',...) creates a new NERVERESHAPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NerveReshaper_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NerveReshaper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% NerveReshaper(hObject,eventdata,handles,ObjectList,ObjectVertices)

% Edit the above text to modify the response to help NerveReshaper

% Last Modified by GUIDE v2.5 23-Apr-2009 10:12:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NerveReshaper_OpeningFcn, ...
                   'gui_OutputFcn',  @NerveReshaper_OutputFcn, ...
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


% --- Executes just before NerveReshaper is made visible.
function NerveReshaper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NerveReshaper (see VARARGIN)

% Choose default command line output for NerveReshaper
%handles.Output = hObject;

if (length(varargin)>0)
    %assume NerveShaper was called by NerveTracer
    handles.NerveTracer.hObject = varargin{1};
    handles.NerveTracer.eventdata = varargin{2};
    handles.NerveTracer.handles = varargin{3};
    handles.ObjectList = varargin{4};
    handles.ObjectVertices = varargin{5};
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NerveReshaper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NerveReshaper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Output;


%% Callbacks
function Value_Length_Callback(hObject, eventdata, handles)
% hObject    handle to Value_Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_Length as text
%        str2double(get(hObject,'String')) returns contents of Value_Length as a double
handles.dimensions(1)=[str2num(get(handles.Value_Length,'string'))];

% Update handles structure
guidata(hObject, handles);


function Value_Height_Callback(hObject, eventdata, handles)
% hObject    handle to Value_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_Height as text
%        str2double(get(hObject,'String')) returns contents of Value_Height as a double
handles.dimensions(2)=[str2num(get(handles.Value_Length,'string'))];

% Update handles structure
guidata(hObject, handles);


function Value_Diameter_Callback(hObject, eventdata, handles)
% hObject    handle to Value_Diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_Diameter as text
%        str2double(get(hObject,'String')) returns contents of Value_Diameter as a double
handles.dimensions=[str2num(get(handles.Value_Length,'string'))];

% Update handles structure
guidata(hObject, handles);


%% Create Functions

% --- Executes during object creation, after setting all properties.
function Value_Length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_Length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Value_Height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Value_Diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_Diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Push Buttons
% --- Executes when selected object is changed in Panel_ChooseElectrodeShape.
function Panel_ChooseElectrodeShape_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Panel_ChooseElectrodeShape 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

junk=get(handles.Panel_ChooseElectrodeShape,'Children');
shape=[get(junk(1),'Value'),get(junk(2),'Value')];
shape=find(shape==1);

if (shape==2)  %FINE was chosen
    %enable FINE dimensions
    set(handles.Value_Length,'Enable','on');
    set(handles.Value_Height,'Enable','on');
    %disable SPRIAL dimensions
    set(handles.Value_Diameter,'Enable','off');
    
    handles.dimensions=[str2num(get(handles.Value_Length,'string')),str2num(get(handles.Value_Height,'string'))];
else
    %disable FINE dimensions
    set(handles.Value_Length,'Enable','off');
    set(handles.Value_Height,'Enable','off');
    %enable SPRIAL dimensions
    set(handles.Value_Diameter,'Enable','on');
    
    handles.dimensions=[str2num(get(handles.Value_Diameter,'string'))];
end

%update all data
guidata(hObject, handles);









% --- Executes when selected object is changed in Panel_ImportedObjects.
function Panel_ImportedObjects_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Panel_ImportedObjects 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



junk=get(handles.Panel_ImportedObjects,'Children');
scenario=zeros(9,1);
for i=1:9
    scenario(i)=get(junk(i),'Value');
end

%Legend:
%  Location     Description
%     1         Contains Epi & Endo.  Need to add Peri and need to name.
%     2         Contains Epi & Endo.  Need to add Peri.  Names are correct.
%     3         <section header; ignore>
%     4         Contains Epi & Peri.  Need to add Endo and need to name.
%     5         Contains Epi & Peri.  Need to add Endo.  Names are correct.     
%     6         <section header; ignore>
%     7         Contains Epi, Peri, Endo, but need to name correctly
%     8         <section header; ignore>
%     9         Contains Epi, Peri, Endo and objects are named correctly  
scenario=find(scenario==1);

if (scenario==1) %Epi and Endo exist, but need to add Peri.

    %Data contains all objects, but names are incorrect.  Create
    %message string and then collect names
    string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
    string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
    string=[string        '\t Endo is in the endoneurium objects name\n'];
    string=[string 'Perineiurm names will be created from your endoneurium names.\n--->'];
    handles=CollectNames(hObject,eventdata,handles,string);

    %using names and Endo coordinates, create Peris
    handles=CreatePeris(hObject,eventdata,handles);

elseif(scenario==2) %Epi and Endo exist, but need to add Peri.

    %using names and Endo coordinates, create Peris
    handles=CreatePeris(hObject,eventdata,handles);

elseif(scenario==4) %Epi and Peri exist, but need to add Endo.
    %Data contains all objects, but names are incorrect.  Create
    %message string and then collect names
    string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
    string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
    string=[string        '\t Peri is in the perineurium objects name\n'];
    string=[string 'Endoneurium names will be created from your perineurium names.\n--->'];
    handles=CollectNames(hObject,eventdata,handles,string);

    %using names and Peri coordinates, create Endos
    handles=CreateEndos(hObject,eventdata,handles);

elseif(scenario==5) %Epi and Peri exist, but need to add Endo.

    %using names and Peri coordinates, create Endos
    handles=CreateEndos(hObject,eventdata,handles);

elseif(scenario==7)
    %Data contains all objects, but names are incorrect.  Create
    %message string and then collect names
    string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
    string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
    string=[string        '\t Peri is in the perineurium objects name\n'];
    string=[string        '\t Endo is in the endoneurium objects name\n--->'];
    handles=CollectNames(hObject,eventdata,handles,string);
    

elseif(scenario==9)
    %Data is ready to process immediately
end

%Data is now in correct format and ready for processing
%  Correct Format:
%     ObjectList={'Epineurium','Peri#', ...., 'Endo#', ....}
%     ObjectVertices.Epinurium = [x y]
%     ObjectVertices.Peri# = [x y] 
%     ....
%     ObjectVertices.Endo# = [x y]
%     ....

axes(handles.axes1)
cla
for i=1:length(handles.ObjectList)
    plot(handles.ObjectVertices.(handles.ObjectList{i})(:,1), handles.ObjectVertices.(handles.ObjectList{i})(:,2),'k');
    hold on
end
axis equal



%update all data
guidata(hObject, handles);


%% Other Functions

function handles=CollectNames(hObject,eventdata,handles,string)

%plot all objects in axes 1
axes(handles.axes1)
hold off
for i=1:length(handles.ObjectList)
    plot(handles.ObjectVertices.(handles.ObjectList{i})(:,1), handles.ObjectVertices.(handles.ObjectList{i})(:,2),'k');
    hold on
end

%highlight each object at a time and poll for object name
for i=1:length(handles.ObjectList)
    plot(handles.ObjectVertices.(handles.ObjectList{i})(:,1), handles.ObjectVertices.(handles.ObjectList{i})(:,2),'r');
    hold on
    if (i>1)
        plot(handles.ObjectVertices.(handles.ObjectList{i})(:,1), handles.ObjectVertices.(handles.ObjectList{i})(:,2),'k'); %un-highlight the last object
    end
    clc
    name=input(string,'s');
    NewObjectList{i}=name;
    NewObjectVertices.(name)=[handles.ObjectVertices.(handles.ObjectList{i})(:,1), handles.ObjectVertices.(handles.ObjectList{i})(:,2)];
end
handles.ObjectVertices=NewObjectVertices;
handles.ObjectList=NewObjectList;

%update all data
guidata(hObject, handles);


function handles=CreateEndos(hObject,eventdata,handles)
NewObjectList={};
for i=1:length(handles.ObjectList)
    periindex=strfind(lower(handles.ObjectList{i}),'peri');

    if (~isempty(periindex)) %assume we're dealing with a perineurium and that another object didn't happen to have 'peri' in it's name
        tempname='';
        tempname=handles.ObjectList{i};

        %clean up the name: convert peri->endo (if 'neurium' was included,
        %it stays in place).  Maintain case.
        periindex=strfind(handles.ObjectList{i},'peri');
        Periindex=strfind(handles.ObjectList{i},'Peri');
        PERIindex=strfind(handles.ObjectList{i},'PERI');

        if (~isempty(periindex)) %lower case
            newname='';
            newname=tempname;
            newname(periindex:periindex+3)='endo';

        elseif (~isempty(Periindex)) %Capitalized First
            newname='';
            newname=tempname;
            newname(Periindex:Periindex+3)='Endo';

        elseif (~isempty(PERIindex)) %ALL CAPS
            newname='';
            newname=tempname;
            newname(PERIindex:PERIindex+3)='ENDO';
        end

        NewObjectList{end+1}=newname;


        %Now create the endo's points
        periverts=[];
        periverts=handles.ObjectVertices.(handles.ObjectList{i});
        
        %Endo is .94x of Peri
        %Find centroid of Peri, move to (0,0), multiply by .94, move back
        %to original location
        [X0 Y0]=centroid(periverts(:,1),periverts(:,2));
        
        endoverts=[];
        endoverts=[periverts(:,1)-X0,periverts(:,2)-Y0];
        endoverts=endoverts.*.94;
        endoverts=[endoverts(:,1)+X0,endoverts(:,2)+Y0];
        
        NewObjectVertices.(newname)=endoverts;
    end
end

%update objects and vertices
for i=1:length(NewObjectList)
    handles.ObjectList{end+1}=NewObjectList{i};
    handles.ObjectVertices.(NewObjectList{i})=NewObjectVertices.(NewObjectList{i});
end

%update all data
guidata(hObject, handles);


function handles=CreatePeris(hObject,eventdata,handles)
NewObjectList={};
for i=1:length(handles.ObjectList)
    endoindex=strfind(lower(handles.ObjectList{i}),'endo');

    if (~isempty(endoindex)) %assume we're dealing with an endoneurium and that another object didn't happen to have 'endo' in it's name
        tempname='';
        tempname=handles.ObjectList{i};

        %clean up the name: convert endo->peri (if 'neurium' was included,
        %it stays in place).  Maintain case.
        endoindex=strfind(handles.ObjectList{i},'endo');
        Endoindex=strfind(handles.ObjectList{i},'Endo');
        ENDOindex=strfind(handles.ObjectList{i},'ENDO');

        if (~isempty(endoindex)) %lower case
            newname='';
            newname=tempname;
            newname(endoindex:endoindex+3)='peri';

        elseif (~isempty(Endoindex)) %Capitalized First
            newname='';
            newname=tempname;
            newname(Endoindex:Endoindex+3)='Peri';

        elseif (~isempty(ENDOindex)) %ALL CAPS
            newname='';
            newname=tempname;
            newname(ENDOindex:ENDOindex+3)='PERI';
        end

        NewObjectList{end+1}=newname;


        %Now create the peris's points
        endoverts=[];
        endoverts=handles.ObjectVertices.(handles.ObjectList{i});
        
        %Peri is 1.06x of Endo
        %Find centroid of Endo, move to (0,0), multiply by 1.06, move back
        %to original location
        [X0 Y0]=centroid(endoverts(:,1),endoverts(:,2));
        
        periverts=[];
        periverts=[endoverts(:,1)-X0,endoverts(:,2)-Y0];
        periverts=periverts.*1.06;
        periverts=[periverts(:,1)+X0,periverts(:,2)+Y0];
        
        NewObjectVertices.(newname)=periverts;
    end
end

%update objects and vertices
for i=1:length(NewObjectList)
    handles.ObjectList{end+1}=NewObjectList{i};
    handles.ObjectVertices.(NewObjectList{i})=NewObjectVertices.(NewObjectList{i});
end

%update all data
guidata(hObject, handles);





% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (isfield(handles,'CrossSection'))
    FileName=handles.CrossSection
else
    FileName=input('Provide Cross Section name','s');
    handles.CrossSection=FileName;
end

junk=get(handles.Panel_ChooseElectrodeShape,'Children');
shape=[get(junk(1),'Value'),get(junk(2),'Value')];
shape=find(shape==1);

if (shape==1)
    type='Spiral';
    diam=get(handles.Value_Diameter,'string');
    str=[type ' ' diam ' mm'];
else
    type='FINE';
    height=get(handles.Value_Height,'string');
    width=get(handles.Value_Length,'string');
    str=[type ' ' height 'x' width ' mm'];
end
    

FileName=[FileName ' ' str];
WriteSM2(handles.ObjectList,handles.Output.ObjectVertices,FileName) 
%WriteSM2(handles.ObjectList,handles.ObjectVertices,FileName) % PVL changed to handles.ObjectVertices

%update all data
guidata(hObject, handles);



% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (isfield(handles,'CrossSection'))
    FileName=handles.CrossSection
else
    FileName=input('Provide Cross Section name','s');
    handles.CrossSection=FileName;
end


junk=get(handles.Panel_ChooseElectrodeShape,'Children');
shape=[get(junk(1),'Value'),get(junk(2),'Value')];
shape=find(shape==1);

if (shape==1)
    type='Spiral';
    diam=get(handles.Value_Diameter,'string');
    str=[type ' ' diam ' mm'];
else
    type='FINE';
    height=get(handles.Value_Height,'string');
    width=get(handles.Value_Length,'string');
   % str=[type ' ' diam ' mm']; %PVL commenting out. get err
end
    

%FileName=[FileName ' ' str]; %PVL also commenting out.

eval(['save ''' FileName '''' ' handles']);

%update all data
guidata(hObject, handles);


% --- Executes on button press in Button_Reshape.
function Button_Reshape_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Reshape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic

junk=get(handles.Panel_ChooseElectrodeShape,'Children');
shape=[get(junk(1),'Value'),get(junk(2),'Value')];
shape=find(shape==1);

if (shape==1)
    %Launch Spiral reshaper
    
    %get diameter
    Spiral.FinalDiameter=str2num(get(handles.Value_Diameter,'string'));
    
    junk=get(handles.CheckBox_Encapsulation,'Value');

    if (junk)
        %Encapsulation needs to be accounted for
        SPIRAL.Encapsulated='true';
        SPIRAL.EncapsulationThickness=0.25; %mm
        SPIRAL.FinalDiameter=SPIRAL.FinalDiameter-2*FINE.EncapsulationThickness;
    end
    
    
    %need to adjust output and input in this call
    [handles.Output.ObjectVertices,handles.Output.SPIRAL]=ReshapeWithSpiral(handles.ObjectList,handles.ObjectVertices,Spiral.FinalDiameter);
else
    %Launch FINE reshaper

    %get height/width
    FINE.FinalHeight=str2num(get(handles.Value_Height,'string'));
    FINE.FinalWidth=str2num(get(handles.Value_Length,'string'));
    
    junk=get(handles.CheckBox_Encapsulation,'Value');

    if (junk)
        %Encapsulation needs to be accounted for
        FINE.Encapsulated='true';
        FINE.EncapsulationThickness=0.25; %mm
        FINE.FinalHeight=FINE.FinalHeight-2*FINE.EncapsulationThickness;
        FINE.FinalWidth=FINE.FinalWidth-2*FINE.EncapsulationThickness;
    end


    [handles.Output.ObjectVertices,handles.Output.FINE]=ReshapeWithFINE(handles.ObjectList,handles.ObjectVertices,FINE.FinalWidth,FINE.FinalHeight);
    
end

toc

%update all data
guidata(hObject, handles);


% --- Executes on button press in CheckBox_Encapsulation.
function CheckBox_Encapsulation_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBox_Encapsulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBox_Encapsulation


