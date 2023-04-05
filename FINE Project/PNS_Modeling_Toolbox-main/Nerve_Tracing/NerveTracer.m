function varargout = NerveTracer(varargin)
% PVL modified 4/7/16. 
% now uses 20 points along edge of each fascicle instead of _all_ points
% NERVETRACER M-file for NerveTracer.fig
%      NERVETRACER, by itself, creates a new NERVETRACER or raises the existing
%      singleton*.
%
%      H = NERVETRACER returns the handle to a new NERVETRACER or the handle to
%      the existing singleton*.
%
%      NERVETRACER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NERVETRACER.M with the given input arguments.
%
%      NERVETRACER('Property','Value',...) creates a new NERVETRACER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NerveTracer_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NerveTracer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NerveTracer

% Last Modified by GUIDE v2.5 26-Mar-2009 15:45:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NerveTracer_OpeningFcn, ...
                   'gui_OutputFcn',  @NerveTracer_OutputFcn, ...
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


% --- Executes just before NerveTracer is made visible.
function NerveTracer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NerveTracer (see VARARGIN)

% Choose default command line output for NerveTracer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NerveTracer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%clc

% --- Outputs from this function are returned to the command line.
function varargout = NerveTracer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






%% AXES FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=update_axes1(hObject, eventdata, handles)
%figure data in this section is titled handles.I1<alpha>

use_negative=get(handles.CheckBox_Negative,'Value');

axes(handles.axes1);
if (use_negative)
    imshow(handles.raw_complement);
    handles.I1=handles.raw_complement;
else
    imshow(handles.raw);
    handles.I1=handles.raw;
end

handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handles=update_axes2(hObject, eventdata, handles)
%figure data in this section is titled handles.I2<alpha>

%[all b g r]
junk=get(handles.Panel_Layer,'Children');
layers=[get(junk(1),'Value'),get(junk(2),'Value'),get(junk(3),'Value'),get(junk(4),'Value')];

if (layers(1)==1)
    handles.I2a=rgb2gray(handles.I1);
else
    page=fliplr(layers(2:end));
    handles.I2a=handles.I1(:,:,(page==1));
end

use_equalize=get(handles.CheckBox_Equalize,'Value');
if (use_equalize)
    handles.I2b=adapthisteq(handles.I2a);
else
    handles.I2b=handles.I2a;
end

use_TopHat=get(handles.CheckBox_TopHat,'Value');
if (use_TopHat)
    option=get(handles.Popup_TopHat,'String');
    option=option{get(handles.Popup_TopHat,'Value')};
    if (~strcmp(option,'Choose TopHat Option'))
        se = strel(option,str2num(get(handles.Value_TopHat,'String')));
        handles.I2c=imtophat(handles.I2b,se);
    else
        handles.I2c=handles.I2b;
    end
else
    handles.I2c=handles.I2b;
end

use_Background=get(handles.CheckBox_Background,'Value');
if (use_Background)
    option=get(handles.Popup_Background,'String');
    option=option{get(handles.Popup_Background,'Value')};
    if (~strcmp(option,'Choose Background Option'))
        se = strel(option,str2num(get(handles.Value_Background,'String')));
        handles.I2d=imtophat(handles.I2c,se);
    else
        handles.I2d=handles.I2c;
    end
else
    handles.I2d=handles.I2c;
end

axes(handles.axes2);
imshow(handles.I2d);

handles=update_axes3(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=update_axes3(hObject, eventdata, handles)
%figure data in this section is titled handles.I3<alpha>

handles.I3a = im2bw(handles.I2d, get(handles.Slider_bwThreshold,'Value')/255);
handles.I3b = imfill(handles.I3a,'holes');
handles.I3c = imopen(handles.I3b, ones(str2num(get(handles.Value_bwOpen,'String'))));
handles.I3d = bwareaopen(handles.I3c, str2num(get(handles.Value_AreaOpen,'String')));

axes(handles.axes3);
imshow(handles.I3d);


%Gather properties about the fascicles (and possible other blobs)
%    Anything with a "small" area is not a fascicle
%    Anything with a "large" eccentricity is not a fascicle
%    Anything with a "small" number of pixels is not a fascicle
%        -this should have been accounted for in the bwareaopen call
%    Anything with a "big" difference between the major and minor axis
%        length is not a fascicle
handles.L=bwlabel(handles.I3d);
handles.stats=regionprops(handles.L,'Area','Eccentricity','Centroid','PixelList','MajorAxisLength','MinorAxisLength','EulerNumber');

hold on
for i=1:length(handles.stats)
    text(handles.stats(i).Centroid(1),handles.stats(i).Centroid(2),num2str(i));
end
hold off
handles=update_axes4(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles=update_axes4(hObject, eventdata, handles)
%figure data in this section is titled handles.I4<alpha>



axes(handles.axes4);

imshow(handles.I2d);
hold on
ShowMaskAsOverlay2(0.3,handles.I3d,'g');

handles.I4a = handles.I2d.*uint8(handles.I3d);
[handles.I4bB, handles.I4bL] = bwboundaries(handles.I4a,'noholes');
for k = 1:length(handles.I4bB)
    boundary = handles.I4bB{k};
    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

%update all data
guidata(hObject, handles);




%% OTHER FUNCTIONS


% --- Executes on button press in Button_TraceEpi.
function handles = Button_TraceEpi_Callback(hObject, eventdata, handles)
% hObject    handle to Button_TraceEpi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
vertices=[];

handles.Nerve.ObjectList{1}='Epineurium';


figure
imshow(handles.raw);

done='c'; %continue
while (~strcmp(upper(done),'DONE'))
    done=input('Each time you click the mouse, the location of the pointer will be recorded as a vertex.\nType DONE when you are finished recording vertices for this object.\nType R if you wish to replace the last point with the current point.\nHit ENTER to continue to the next point.\n','s');


    title('CREATE VERTICIES FOR EPINEURIUM');
    junk=get(gca,'CurrentPoint');

    hold on
    scatter(junk(1,1),junk(1,2),'r*');

    if (strcmp(upper(done),'R'))
        scatter(vertices(end,1),vertices(end,2),'c*');
        vertices(end,:)=[];
    end

    vertices(end+1,1:2)=[junk(1,1),junk(1,2)];

end

%remove repeat point at end if present
if ((vertices(end,1)==vertices(end-1,1))&&(vertices(end,2)==vertices(end-1,2)))
    vertices(end,:)=[];
end

%close the polygon
vertices(end+1,:)=vertices(1,:);
handles.Nerve.vertices.units='pixels';
handles.Nerve.vertices.Epineurium=vertices;

plot([vertices(:,1);vertices(1,1)],[vertices(:,2);vertices(1,2)],'r-');

%create an Epineurium Mask
handles.EpiMask=zeros(size(handles.I2a));
handles.EpiMask=poly2mask(vertices(:,1),vertices(:,2),size(handles.EpiMask,1),size(handles.EpiMask,2));

close(gcf);

handles.raw_unmasked=handles.raw;

handles.raw(:,:,1)=handles.raw(:,:,1).*uint8(handles.EpiMask);
handles.raw(:,:,2)=handles.raw(:,:,2).*uint8(handles.EpiMask);
handles.raw(:,:,3)=handles.raw(:,:,3).*uint8(handles.EpiMask);

handles.raw_complement(:,:,1)=handles.raw_complement(:,:,1).*uint8(handles.EpiMask);
handles.raw_complement(:,:,2)=handles.raw_complement(:,:,2).*uint8(handles.EpiMask);
handles.raw_complement(:,:,3)=handles.raw_complement(:,:,3).*uint8(handles.EpiMask);


handles=update_axes1(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);



function varargout = ShowMaskAsOverlay2(opacity, mask, overlaycolor, varargin)
% Show segmentation (mask) with user-specified transparency/color as overlay on image
%
% Using optional input DELEMASK argument, one can
% easily show multiple segmentation masks on a single image. 
%
% SYNTAX:
%
% SHOWMASKASOVERLAY(OPACITY, MASK, OVERLAYCOLOR)
%     Operates on the image in the current figure, overlays a
%     MASK of opacity OPACITY and of color OVERLAYCOLOR.
%
% SHOWMASKASOVERLAY(OPACITY, MASK, OVERLAYCOLOR, IMG)
%     Takes a handle to an image, or an image itself.
%
% SHOWMASKASOVERLAY(OPACITY, MASK, OVERLAYCOLOR, IMG, DELEMASKS)
%     DELEMASKS is a logical binary, indicating whether existing masks
%     should be deleted before new masks are displayed. Default is TRUE.
%
% SHOWMASKOVERLAY(OPACITY)
%     If an overlayed mask already exists in the current figure,
%     this shorthand command will modify its opacity.
%
% IMGOUT = SHOWMASKASOVERLAY(...)
%     Returns an RGB image of class double, capturing the combined IMG
%     and OVERLAY(s) as image IMGOUT.
%
% [IMGOUT, HNDLS] = SHOWMASKASOVERLAY(...)
%     Also returns a structure of handles to the original image and
%     generated overlays in the current axes.
%
% INPUTS:
%
%     OPACITY       The complement of transparency; a variable on [0,1]
%                   describing how opaque the overlay should be. A
%                   mask of opacity of 0 is 100% transparent. A mask
%                   of opacity 1 is completely solid.
%     MASK          A binary image to be shown on the image of
%                   interest. (Must be the same size as the image operated
%                   on.)
%     OVERLAYCOLOR  A triplet of [R G B] value indicating the color
%                   of the overlay. (Standard "color strings"
%                   like 'r','g','b','m' are supported.) Default
%                   is red.
%     IMG           (Optional) A handle to an image, or an image. By
%                   default, SHOWIMAGEASOVERLAY operates on the image
%                   displayed in the current axes. (If this argument is
%                   omitted, or if the current axes does not contain an
%                   image, an error will be thrown.)
%
%                   Alternatively, IMG may be an image, in which case a new
%                   figure is generated, the image is displayed, and the
%                   overlay is generated on top of it.
%
%     DELEMASKS     Delete previously displayed masks?
%                   This operates at a figure-level. (Default = 1.) 
%
% OUTPUTS:
%
%     HNDLS         A structure containing handles of all images (including
%                   overlays) in the current axes. The structure will have
%                   fields:
%                      Original:   The underlying (non-overlaid) image in
%                                  the parent axes.
%                      Overlays:   All overlays created by
%                                  SHOWMASKASOVERLAY.
%
% EXAMPLES:
% 1)
%                   I = imread('rice.png');
%                   I2 = imtophat(I, ones(15, 15));
%                   I2 = im2bw(I2, graythresh(I2));
%                   I2 = bwareaopen(I2, 5);
%                   figure;
%                   imshow(I);
%                   showMaskAsOverlay(0.4,I2)
%                   title('showMaskAsOverlay')
%
% 2)          
%                   I = imread('rice.png');
%                   AllGrains = imtophat(I, ones(15, 15));
%                   AllGrains = im2bw(AllGrains, graythresh(AllGrains));
%                   AllGrains = bwareaopen(AllGrains, 5);
%                   PeripheralGrains = AllGrains -imclearborder(AllGrains);
%                   InteriorGrains = AllGrains - PeripheralGrains;
%                   figure;
%                   subplot(2,2,1.5)
%                   imshow(I); title('Original')
%                   subplot(2,2,3)
%                   imshow(I)
%                   showMaskAsOverlay(0.4,AllGrains)
%                   title('All grains')
%                   subplot(2,2,4)
%                   imshow(I)
%                   % Note: I set DELEMASKS explicity to 0 here so  
%                   % 'AllGrains' mask is not cleared from figure 
%                   showMaskAsOverlay(0.4,InteriorGrains,[1 1 0],[],0)
%                   showMaskAsOverlay(0.4,PeripheralGrains,'g',[],0)
%                   title('Interior and Peripheral Grains')

% Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% V 1.0 07/05/2007

error(nargchk(1,5,nargin));
if nargin >= 4
    if ~isempty(varargin{1})
        if ishandle(varargin{1})
            imgax = varargin{1};
        else
            figure;
            imshow(varargin{1});
            imgax = imgca;
        end
    else
        imgax = imgca;
    end
    fig = get(imgax,'parent');
    axes(imgax);
else
    fig = gcf;
end

if nargin == 5
    deleMasks = logical(varargin{2});
else
    deleMasks = true;
end

iptcheckinput(opacity, {'double'},{'scalar'}, mfilename, 'opacity', 1);
iptcheckinput(deleMasks, {'logical'}, {'nonempty'}, mfilename, 'deleMasks', 5);

if nargin == 1
    overlay = findall(gcf,'tag','opaqueOverlay');
    if isempty(overlay)
        error('SHOWMASKASOVERLAY: No opaque mask found in current figure.');
    end
    mask = get(overlay,'cdata');
    newmask = max(0,min(1,double(any(mask,3))*opacity));
    set(overlay,'alphadata',newmask);
    figure(fig);
    return
else
    iptcheckinput(mask, {'double','logical'},{'nonempty'}, mfilename, 'mask', 2);
end

% If the user doesn't specify the color, use red.
DEFAULT_COLOR = [1 0 0];
if nargin < 3
    overlaycolor = DEFAULT_COLOR;
elseif ischar(overlaycolor)
    switch overlaycolor
        case {'y','yellow'}
            overlaycolor = [1 1 0];
        case {'m','magenta'}
            overlaycolor = [1 0 1];
        case {'c','cyan'}
            overlaycolor = [0 1 1];
        case {'r','red'}
            overlaycolor = [1 0 0];
        case {'g','green'}
            overlaycolor = [0 1 0];
        case {'b','blue'}
            overlaycolor = [0 0 1];
        case {'w','white'}
            overlaycolor = [1 1 1];
        case {'k','black'}
            overlaycolor = [0 0 0];
        otherwise
            disp('Unrecognized color specifier; using default.');
            overlaycolor = DEFAULT_COLOR;
    end
end

figure(fig);
tmp = imhandles(fig);
if isempty(tmp)
    error('There doesn''t appear to be an image in the current figure.');
end
try
    a = imattributes(tmp(1));
catch %#ok
    error('There doesn''t appear to be an image in the current figure.');
end
imsz = [str2num(a{2,2}),str2num(a{1,2})]; %#ok

if ~isequal(imsz,size(mask(:,:,1)))
    error('Size mismatch');
end
if deleMasks
    delete(findall(fig,'tag','opaqueOverlay'))
end

overlaycolor = im2double(overlaycolor);
% Ensure that mask is logical
mask = logical(mask);

if size(mask,3) == 1
    newmaskR = zeros(imsz);
    newmaskG = newmaskR;
    newmaskB = newmaskR;
    %Note: I timed this with logical indexing (as currently implemented),
    %with FIND, and with logical indexing after converting the mask to type
    %logical. All three were roughly equivalent in terms of performance.
    newmaskR(mask) = overlaycolor(1);
    newmaskG(mask) = overlaycolor(2);
    newmaskB(mask) = overlaycolor(3);
elseif size(mask,3) == 3
    newmaskR = mask(:,:,1);
    newmaskG = mask(:,:,2);
    newmaskB = mask(:,:,3);
else
    beep;
    disp('Unsupported masktype in showImageAsOverlay.');
    return
end

newmask = cat(3,newmaskR,newmaskG,newmaskB);

hold on;
h = imshow(newmask);
try
    set(h,'alphadata',double(mask)*opacity,'tag','opaqueOverlay');
catch %#ok
    set(h,'alphadata',opacity,'tag','opaqueOverlay');
end
if nargout > 0
    varargout{1} = imhandles(imgca);
end
if nargout > 1
    varargout{2} = getframe;
    varargout{2} = varargout{2}.cdata;
end


function handles=ConvertPixelsToMM(hObject,eventdata,handles);
%if the Epineurium has not yet been traced, this must be done
if (~isfield(handles,'Nerve'))
    fprintf('Epineurium has not been defined yet.\n');
    handles=Button_TraceEpi_Callback(hObject,eventdata,handles);
end

% if (~strcmp(handles.Nerve.ObjectList{1},'Epineurium'))
%     fprintf('Epineurium has not been defined yet.\n');
    handles=Button_TraceEpi_Callback(hObject, eventdata, handles); % PVL2016 error?
% end

if (~handles.FasciclesNamed)
    %must assign generic names to all fascicles

    for i=1:length(handles.stats)
        handles.Nerve.ObjectList{i+1}=['F' num2str(i)];


        junk=handles.L;
        junk(junk~=i)=0;
        junk(junk>0)=1;
        boundary=bwboundaries(junk);
        boundary=boundary{1};

        handles.Nerve.vertices.(['F' num2str(i)])=boundary;
    end
end

%convert vertices from pixels to mm and re-center about the centroid of
%the epineurium
[X0, Y0]=centroid(handles.Nerve.vertices.Epineurium(:,1),handles.Nerve.vertices.Epineurium(:,2));

if (strcmp(handles.Nerve.vertices.units,'pixels'))
    handles.Nerve.ScaledVertices.units='mm';

    for i=1:length(handles.Nerve.ObjectList)
        
        temp=[];
        temp=handles.Nerve.vertices.(handles.Nerve.ObjectList{i});
        
        if (strcmp(handles.Nerve.ObjectList{i},'Epineurium'))
            %Must handle the Epineurium differently because it was traced
            %on an image with proper x-axis direction but negative y-axis
            %direction

            %re-center the objects so that the centroid of the Epineurium
            %is at (0,0)
            temp(:,1)=temp(:,1)-X0;
            temp(:,2)=temp(:,2)-Y0;
            
            %account for the negative y-axis 
            temp(:,2)=-temp(:,2);
        else
            %handle all objects other than the traced Epineurium
            %differently...
            %pulling data from the image results in vertices that rotated
            %90 degrees, so need to swap x and y
            temp=fliplr(temp);
            
            %re-center the objects so that the centroid of the Epineurium
            %is at (0,0)
            temp(:,1)=temp(:,1)-X0;
            temp(:,2)=temp(:,2)-Y0;
 
            %account for the negative y-axis
            temp(:,2)=-temp(:,2);
            
        end

 
        if (isfield(handles,'ScaleBar'))
            temp=temp.*handles.ScaleBar.PixelsToLength;
        end
           

        handles.Nerve.ScaledVertices.(handles.Nerve.ObjectList{i})=temp;
    end
end

%update all data
guidata(hObject, handles);



function [x0,y0] = centroid(x,y)
% CENTROID Center of mass of a polygon.
%	[X0,Y0] = CENTROID(X,Y) Calculates centroid 
%	(center of mass) of planar polygon with vertices 
%	coordinates X, Y.
%	Z0 = CENTROID(X+i*Y) returns Z0=X0+i*Y0 the same
%	as CENTROID(X,Y).

%  Copyright (c) 1995 by Kirill K. Pankratov,
%       kirill@plume.mit.edu.
%       06/01/95, 06/07/95

% Algorithm:
%  X0 = Int{x*ds}/Int{ds}, where ds - area element
%  so that Int{ds} is total area of a polygon.
%    Using Green's theorem the area integral can be 
%  reduced to a contour integral:
%  Int{x*ds} = -Int{x^2*dy}, Int{ds} = Int{x*dy} along
%  the perimeter of a polygon.
%    For a polygon as a sequence of line segments
%  this can be reduced exactly to a sum:
%  Int{x^2*dy} = Sum{ (x_{i}^2+x_{i+1}^2+x_{i}*x_{i+1})*
%  (y_{i+1}-y_{i})}/3;
%  Int{x*dy} = Sum{(x_{i}+x_{i+1})(y_{i+1}-y_{i})}/2.
%    Similarly
%  Y0 = Int{y*ds}/Int{ds}, where
%  Int{y*ds} = Int{y^2*dx} = 
%  = Sum{ (y_{i}^2+y_{i+1}^2+y_{i}*y_{i+1})*
%  (x_{i+1}-x_{i})}/3.

 % Handle input ......................
if nargin==0, help centroid, return, end
if nargin==1
  sz = size(x);
  if sz(1)==2      % Matrix 2 by n
    y = x(2,:); x = x(1,:);
  elseif sz(2)==2  % Matrix n by 2
    y = x(:,2); x = x(:,1);
  else
    y = imag(x);
    x = real(x);
  end
end 

 % Make a polygon closed ..............
x = [x(:); x(1)];
y = [y(:); y(1)];

 % Check length .......................
l = length(x);
if length(y)~=l
  error(' Vectors x and y must have the same length')
end

 % X-mean: Int{x^2*dy} ................
del = y(2:l)-y(1:l-1);
v = x(1:l-1).^2+x(2:l).^2+x(1:l-1).*x(2:l);
x0 = v'*del;

 % Y-mean: Int{y^2*dx} ................
del = x(2:l)-x(1:l-1);
v = y(1:l-1).^2+y(2:l).^2+y(1:l-1).*y(2:l);
y0 = v'*del;

 % Calculate area: Int{y*dx} ..........
a = (y(1:l-1)+y(2:l))'*del;
tol= 2*eps;
if abs(a)<tol
  disp(' Warning: area of polygon is close to 0')
  a = a+sign(a)*tol+(~a)*tol;
end
 % Multiplier
a = 1/3/a;

 % Divide by area .....................
x0 = -x0*a;
y0 =  y0*a;

if nargout < 2, x0 = x0+i*y0; end
%% SELECTION CHANGES (RADIO BUTTONS)
% --- Executes when selected object is changed in Panel_Layer.
function Panel_Layer_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in Panel_Layer 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=update_axes2(hObject, eventdata, handles);
guidata(hObject, handles);










%% CALLBACKS

% --- Executes on button press in Button_SelectFile.
function Button_SelectFile_Callback(hObject, eventdata, handles)
% hObject    handle to Button_SelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname,pname] = uigetfile('*.*','Select Image');
if (fname ~= 0)
    filename = sprintf('%s%s',pname,fname);
end
[fid message] = fopen(filename,'r');
handles.raw=imread(filename);

if (size(handles.raw,3)==1)
    handles.raw(:,:,2)=handles.raw(:,:,1);
    handles.raw(:,:,3)=handles.raw(:,:,1);
end

handles.raw_complement=imcomplement(handles.raw);

%update filename text
set(handles.Text_FileName,'string',filename);

%clear all figures
axes(handles.axes1);cla
axes(handles.axes2);cla
axes(handles.axes3);cla
axes(handles.axes4);cla

handles.linkaxes=[handles.axes1, handles.axes2, handles.axes3, handles.axes4];

linkaxes(handles.linkaxes,'xy');

handles.FasciclesNamed=0;

%refresh figure 1
handles=update_axes1(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in CheckBox_Negative.
function CheckBox_Negative_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBox_Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBox_Negative

%refresh figure 1
handles=update_axes1(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in CheckBox_Equalize.
function CheckBox_Equalize_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBox_Equalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBox_Equalize

%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


function Value_AreaOpen_Callback(hObject, eventdata, handles)
% hObject    handle to Value_AreaOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_AreaOpen as text
%        str2double(get(hObject,'String')) returns contents of Value_AreaOpen as a double
handles=update_axes3(hObject, eventdata, handles);
guidata(hObject, handles);


function Value_bwOpen_Callback(hObject, eventdata, handles)
% hObject    handle to Value_bwOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_bwOpen as text
%        str2double(get(hObject,'String')) returns contents of Value_bwOpen as a double
handles=update_axes3(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Executes on slider movement.
function Slider_bwThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to Slider_bwThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Value_bwThreshold,'String', num2str(get(handles.Slider_bwThreshold,'Value')));
handles=update_axes3(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on button press in Button_RemoveBlobs.
function Button_RemoveBlobs_Callback(hObject, eventdata, handles)
% hObject    handle to Button_RemoveBlobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%user-prompted corrections
remove=[];
remove=input('Which blobs are NOT fascicles?\n  Separate with spaces.  E.g.: 2 3 4 16\n','s');
remove=str2num(remove);

handles.L(handles.L==remove)=0;
handles.L(handles.L>0)=1;
handles.stats(remove)=[];

handles.I3d=handles.I3d.*handles.L;

axes(handles.axes3);
hold off
imshow(handles.I3d);

%Gather properties about the fascicles (and possible other blobs)
%    Anything with a "small" area is not a fascicle
%    Anything with a "large" eccentricity is not a fascicle
%    Anything with a "small" number of pixels is not a fascicle
%        -this should have been accounted for in the bwareaopen call
%    Anything with a "big" difference between the major and minor axis
%        length is not a fascicle
handles.L=bwlabel(handles.I3d);
handles.stats=regionprops(handles.L,'Area','Eccentricity','Centroid','PixelList','MajorAxisLength','MinorAxisLength','EulerNumber');

hold on
for i=1:length(handles.stats)
    text(handles.stats(i).Centroid(1),handles.stats(i).Centroid(2),num2str(i));
end

handles=update_axes4(hObject, eventdata, handles);

guidata(hObject, handles);

% --- Executes on button press in Button_TraceFascicle.
function Button_TraceFascicle_Callback(hObject, eventdata, handles)
% hObject    handle to Button_TraceFascicle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_of_objects=input('How many fascicles do you wish to trace?  Input a number greater than 0.\n');
scale_question_asked=0;


figure;
imshow(handles.I2d);
hold on
ShowMaskAsOverlay2(0.3,handles.I3d,'g');

handles.I4a = handles.I2d.*uint8(handles.I3d);
[handles.I4bB, handles.I4bL] = bwboundaries(handles.I4a,'noholes');
for k = 1:length(handles.I4bB)
    boundary = handles.I4bB{k};
    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end


for temp_object=1:num_of_objects

    object_number=length(handles.stats)+1;
    
    vertices=[];
    
    done='c'; %continue
    while (~strcmp(upper(done),'DONE'))
        done=input('Each time you click the mouse, the location of the pointer will be recorded as a vertex.\nType DONE when you are finished recording vertices for this object.\nType R if you wish to replace the last point with the current point.\nHit ENTER to continue to the next point.\n','s');

        junk=get(gca,'CurrentPoint');
        hold on
        scatter(junk(1,1),junk(1,2),'r*');

        if (strcmp(upper(done),'R'))
            scatter(vertices(end,1),vertices(end,2),'c*');
            vertices(end,:)=[];
        end

        vertices(end+1,1:2)=[junk(1,1),junk(1,2)];

    end
    
    %remove repeat point at end if present
    if ((vertices(end,1)==vertices(end-1,1))&&(vertices(end,2)==vertices(end-1,2)))
        vertices(end,:)=[];
    end

    %close the polygon
    vertices(end+1,:)=vertices(1,:);
    handles.Nerve.vertices.units='pixels';
    handles.Nerve.vertices.Epineurium=vertices;

    plot([vertices(:,1);vertices(1,1)],[vertices(:,2);vertices(1,2)],'r-');

    %Punch a "hole" in the I3d mask
    handles.I3d=handles.I3d+poly2mask(vertices(:,1),vertices(:,2),size(handles.L,1),size(handles.L,2));

    %update handles.L and handles.stats
    handles.L=bwlabel(handles.I3d);
    handles.stats=regionprops(handles.L,'Area','Eccentricity','Centroid','PixelList','MajorAxisLength','MinorAxisLength','EulerNumber');
    
    clc
end

axes(handles.axes3);
hold off
imshow(handles.I3d);
hold on
for i=1:length(handles.stats)
    text(handles.stats(i).Centroid(1),handles.stats(i).Centroid(2),num2str(i));
end
hold off

handles=update_axes4(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in CheckBox_TopHat.
function CheckBox_TopHat_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBox_TopHat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBox_TopHat
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);

% --- Executes on selection change in Popup_TopHat.
function Popup_TopHat_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_TopHat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Popup_TopHat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Popup_TopHat
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


function Value_TopHat_Callback(hObject, eventdata, handles)
% hObject    handle to Value_TopHat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_TopHat as text
%        str2double(get(hObject,'String')) returns contents of Value_TopHat as a double
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in CheckBox_Background.
function CheckBox_Background_Callback(hObject, eventdata, handles)
% hObject    handle to CheckBox_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckBox_Background
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);

% --- Executes on selection change in Popup_Background.
function Popup_Background_Callback(hObject, eventdata, handles)
% hObject    handle to Popup_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Popup_Background contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Popup_Background
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


function Value_Background_Callback(hObject, eventdata, handles)
% hObject    handle to Value_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Value_Background as text
%        str2double(get(hObject,'String')) returns contents of Value_Background as a double
%refresh figure 2
handles=update_axes2(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in Button_TraceScale.
function Button_TraceScale_Callback(hObject, eventdata, handles)
% hObject    handle to Button_TraceScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
imshow(handles.raw);

L2D=1; %default
mm=input('Enter the length (in mm) of the scale bar\n');
if (mm>0)
    junk=input('Click on one edge of the scale bar and hit ENTER');
    junk=get(gca,'CurrentPoint');
    scalebar(1,:)=[junk(1,1),junk(1,2)];

    junk=input('Click on the other edge of the scale bar and hit ENTER');
    junk=get(gca,'CurrentPoint');
    scalebar(2,:)=[junk(1,1),junk(1,2)];

    distance=sqrt((scalebar(2,1)-scalebar(1,1))^2+(scalebar(2,2)-scalebar(1,2))^2);
    L2D=mm/distance; %true mm : image distance (unitless)
else
    msgbox('No length was entered.');
end

handles.ScaleBar.PixelsToLength=L2D;
handles.ScaleBar.length=mm;
handles.ScaleBar.units='mm';

close(gcf);

%update all data
guidata(hObject, handles);



% --- Executes on button press in Button_Crop.
function Button_Crop_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure;
h=imshow(handles.raw);

handles.raw=imcrop(handles.raw);
handles.raw_complement=imcomplement(handles.raw);

close(gcf);
handles=update_axes1(hObject, eventdata, handles);

%update all data
guidata(hObject, handles);


% --- Executes on button press in Button_SaveData.
function Button_SaveData_Callback(hObject, eventdata, handles)
% hObject    handle to Button_SaveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
junk=get(handles.Text_FileName,'String');
index=strfind(junk,'\');
junk(1:index(end))='';
junk(strfind(junk,'.'))='_';
junk=[junk,' Processed Details'];
eval(['save ''' junk '''']);


% --- Executes on button press in Button_Publish.
function Button_Publish_Callback(hObject, eventdata, handles)
% hObject    handle to Button_Publish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PrintSM2(hObject, eventdata, handles);
  
%update all data
guidata(hObject, handles);



% --- Executes on button press in Button_NameFascicles.
function Button_NameFascicles_Callback(hObject, eventdata, handles)
% hObject    handle to Button_NameFascicles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes4);

imshow(handles.I2d);
hold on

for i=1:length(handles.stats)
    ShowMaskAsOverlay2(0.3,handles.L==i,'y');
    
    name=input('\nProvide Fascicle Name.  Name MUST NOT start with a number!!             ','s');
    junk=handles.L;
    junk(junk~=i)=0;
    junk(junk>0)=1;
    boundary=bwboundaries(junk);
    boundary=boundary{1};

    handles.Nerve.ObjectList{i+1}=name;
    % PVL ADDED
    % full boundary takes forever to simulate
    % let's take 20 points along the boundary
    
    handles.Nerve.vertices.(name)=boundary([1:floor(size(boundary,1)/19):end,end],:);
end
handles.FasciclesNamed=1;
    
    
%update all data
guidata(hObject, handles);


%% CREATE FUNCTION CALLS

% --- Executes during object creation, after setting all properties.
function Value_AreaOpen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_AreaOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', num2str(900));

%update all data
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Value_bwOpen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_bwOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String', num2str(9));

%update all data
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Slider_bwThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_bwThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
initval = 147;
set(hObject,'Value',initval);
set(hObject,'String', num2str(initval));

%update all data
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function Value_TopHat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_TopHat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

initval = 10;
set(hObject,'Value',initval);
set(hObject,'String', num2str(initval));

%update all data
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Value_Background_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Value_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

initval = 10;
set(hObject,'Value',initval);
set(hObject,'String', num2str(initval));

%update all data
guidata(hObject, handles);




% --- Executes on button press in Button_LaunchNerveReshaper.
function Button_LaunchNerveReshaper_Callback(hObject, eventdata, handles)
% hObject    handle to Button_LaunchNerveReshaper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles=ConvertPixelsToMM(hObject,eventdata,handles);

%NerveReshaper requires the following inputs:
% ObjectList{nx1}
% ObjectVertices{nx1}=[x y]
ObjectList=handles.Nerve.ObjectList;
ObjectVertices=handles.Nerve.ScaledVertices;


junk=get(handles.Text_FileName,'String');
index=strfind(junk,'\');
junk(1:index(end))='';
junk(strfind(junk,'.'))='_';
handles.CrossSection=junk;
junk=[junk,' Processed Details, Scaled to mm '];
eval(['save ''' junk '''' ' ObjectList ObjectVertices handles']);


NerveReshaper(hObject,eventdata,handles,ObjectList,ObjectVertices);

%update all data
guidata(hObject, handles);