function Nerve=TracingNerveObjects(image_name)
%This script is used to read an nerve image.  The script then allows the
%user to click on the vertices on the verticies of nerve structures and
%saves the (x,y) coordinates as well as object names
clear all
clc

if (strcmp(image_name,'')
    image_name='../Cross Sectional Images/270L (1L) grayscale.tif';
end

C=imread(image_name);
 
colormap('bone');
H=imagesc(C);



%rotate image so that primary axis = x-axis
done='c';
fprintf('Draw a line across the image to represent the primary axis.\nThis axis will be rotated to become the x-axis.\nWhen you are happy with the line, type D (for done).\n','s');
while (~strcmp(upper(done),'D'));
    waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    
    waitforbuttonpress;
    point2 = get(gca,'CurrentPoint');    % button up detected

    point1 = point1(1,1:2);              % extract x and y
    point2 = point2(1,1:2);
    
    hold on
    plot([point1(1),point2(1)],[point1(2),point2(2)],'c');
    
    done=input('If you are happy with this, type D, otherwise hit any other key.\n','s');
end

%determine the rotation required
alpha=rad2deg(tan((point1(2)-point2(2))/(point2(1)-point1(1))));  %y is reversed b/c (0,0) is in the UPPER left corner of the image

original_axes=get(1,'CurrentAxes');
original_axes=[get(original_axes,'XLim'),get(original_axes,'YLim')];

C_rotated=imrotate(C,-alpha);
axis(original_axes);


close(1)
colormap('bone');
imagesc(C_rotated);
hold on
plot([point1(1),point2(1)],[point1(2),point2(2)],'y');

Nerve.ObjectList={};


%% Account for scale first

has_scale=input('Does the image have a scale bar? (y/n)\n','s');

L2D=1; %default
if (strcmp(has_scale,'y'))
    mm=input('Enter the length (in mm) of the scale bar\n');
    if (mm>0)
        figure(gcf)

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


else
    msgbox('Without a scale bar, verticies are save in *relative* units of distance that may not be accurate');
end




%% Trace the epineurium
object_name='';
object_name=input('Supply a name for the Epineurium, e.g., Epi, Epineurium, etc.\n','s');

vertices=[];
if ~(strcmp(object_name,''))
    Nerve.ObjectList{end+1,1}=object_name;

    done='c'; %continue
    while (~strcmp(upper(done),'DONE'))
        done=input('Each time you click the mouse, the location of the pointer will be recorded as a vertex.\nType DONE when you are finished recording vertices for this object.\nType R if you wish to replace the last point with the current point.\nHit ENTER to continue to the next point.\n','s');

        figure(gcf)
        title(['CREATE VERTICIES FOR ' upper(object_name)]);
        junk=get(gca,'CurrentPoint');

        hold on
        scatter(junk(1,1),junk(1,2),'y*');

        if (strcmp(upper(done),'R'))
            scatter(vertices(end,1),vertices(end,2),'c*');
            vertices(end,:)=[];
        end

        vertices(end+1,1:2)=[junk(1,1),junk(1,2)];

    end
end
%remove repeat point at end if present
if ((vertices(end,1)==vertices(end-1,1))&&(vertices(end,2)==vertices(end-1,2)))
    vertices(end,:)=[];
end

%close the polygon
vertices(end+1,:)=vertices(1,:);


plot([vertices(:,1);vertices(1,1)],[vertices(:,2);vertices(1,2)],'y-');


%determine the centroid of the epineurium
[x0,y0] = centroid(vertices(:,1),vertices(:,2))
scatter(x0,y0,'go');


%re-center the nerve (not the picture)
Nerve.Center=[x0, y0];
vertices(:,1)=vertices(:,1)-Nerve.Center(1);
vertices(:,2)=vertices(:,2)-Nerve.Center(2);
vertices=vertices.*L2D; %tranform pixels to mm

vertices(:,2)=vertices(:,2).*-1;  %this accounts for the fact that (0,0) is in the UPPER left corner
%save Epineurium data
eval(['Nerve.vertices.' object_name '=vertices']);


%% Obtain fascicle data
num_of_objects=input('How many fascicles do you wish to trace?  Input a number greater than 0.\n');
scale_question_asked=0;

if (num_of_objects>0)
    figure(gcf)
    hold on

    for temp_object=1:num_of_objects

        object_name='';
        object_name=input('Supply a name for the object you wish to trace.  You may want to append _xxxx to the end, e.g., _Endo.\n','s');

        vertices=[];
        if ~(strcmp(object_name,''))
            Nerve.ObjectList{end+1}=object_name;

            done='c'; %continue
            while (~strcmp(upper(done),'DONE'))
                done=input('Each time you click the mouse, the location of the pointer will be recorded as a vertex.\nType DONE when you are finished recording vertices for this object.\nType R if you wish to replace the last point with the current point.\nHit ENTER to continue to the next point.\n','s');

                figure(gcf)
                title(['CREATE VERTICIES FOR ' upper(object_name)]);
                junk=get(gca,'CurrentPoint');

                hold on
                scatter(junk(1,1),junk(1,2),'y*');

                if (strcmp(upper(done),'R'))
                    scatter(vertices(end,1),vertices(end,2),'c*');
                    vertices(end,:)=[];
                end
                
                vertices(end+1,1:2)=[junk(1,1),junk(1,2)];

            end
        end
        %remove repeat point at end
        vertices(end,:)=[];
        
        plot([vertices(:,1);vertices(1,1)],[vertices(:,2);vertices(1,2)],'y-');
        
        %re-center the nerve
        vertices(:,1)=vertices(:,1)-Nerve.Center(1);
        vertices(:,2)=vertices(:,2)-Nerve.Center(2);
        
        vertices=vertices.*L2D; %tranform pixels to mm
        vertices(:,2)=vertices(:,2).*-1;  %this accounts for the fact that (0,0) is in the UPPER left corner

        eval(['Nerve.vertices.' object_name '=vertices']);
    end
end


%% Remove excessive vertices if desired
% minimize=input('Do you want the program to remove excessive vertices?  Changs are reversible.  (y/n)\n','s');
% if (strcmp(upper(minimize),'Y')
%     angle=input('What is the threshold angle you wish to use to determine if a point should be minimized?\nEnter a value greater than 0 and less than 90 (degrees).
% 
% %% Write an .SM2 file for this model







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
