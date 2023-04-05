function ReshapeNerve()
%
%THIS FUNCTION REQUIRES THE USE OF A .MAT FILE THAT CONTAINS THE FOLLOWING
%DATA:
%   ObjectList{}: A LIST OF EACH OBJECT IN THE MODEL
%   ObjectVertices.(ObjectList values}: THE VERTICES OF THOSE OBJECTS
%
%E.G.
%   ObjectList{1}='Epineurium'
%   ObjectList{2}='Peri1'
%   ObjectList{3}='Endo1'
%   ...
%   ObjectVertices.Epieurium = [..] <-- n x 2 matrix of vertices
%   ObjectVertices.Peri1 = [..]
%   Objectvertices.Endo1 = [..]
%
%NOTE, THIS PROGRAM ALLOWS OBJECTS TO BE RENAMED.  OBJECTS MUST CONTAIN THE
%NAME EPI, ENDO, AND PERI.
%
%NOTE, THIS PROGRAM WORKS WITH A DATA FILE THAT FALLS INTO ONE OF THESE
%CATEGORIES:
%   1) CONTAINS EPI AND ENDO, BUT NOT PERI
%   2) CONTAINS EPI AND PERI, BUT NOT ENDO
%   3) CONTAINS EPI, PERI, AND ENDO

type=input('Spiral Electrode or FINE (S/F)?  ','s')
type=upper(type);
if (all(ismember(type,'SF')))
    %acceptable input

    if (strcmp(type,'S'))
        fprintf('\n\nTHIS PROGRAM IS NOT CURRENTLY DESIGNED TO WORK WITH SPIRAL RESHAPING.\n');
        quit
    end


    %OBTAIN ELECTRODE DIMENSIONS
    if (strcmp(type,'S'))
        diameter=input('Spiral Diameter in mm?  ');
        FinalDimensions=diameter;
    else
        response=input('Do you want to reshape to multiple heights? (Y/N)   ','s');
        if (strcmp(upper(response),'Y'))
            height=input('\n\tInput Heights in mm in the form: [# # # #]   ');
        else
            height=input('FINE Height in mm?  ');
        end
        
        if (length(height)==1)
            response=input('Do you want to reshape to multiple widths? (Y/N)   ','s');
            if (strcmp(upper(response),'Y'))
                width=input('\n\tInput Widths in mm in the form: [# # # #]   ');
            else
                width=input('FINE Width in mm?  ');
            end
        else
            width=input('FINE Width in mm?  ');
        end
        
        if (length(height)>1)
            FinalDimensions(:,1)=sort(height,'descend');
            FinalDimensions(:,2)=width;
        elseif (length(width)>1)
            FinalDimensions(:,1)=sort(width,'descend');
            FinalDimensions(:,2)=FinalDimensions(:,1);
            FinalDimensions(:,1)=height;
        else
            FinalDimensions=[height, width];
        end
    end
    clear height width


    %OBTAIN DATA
    [fname,pname] = uigetfile('*.mat','Select Data File');
    if (fname ~= 0)
        filename = sprintf('%s%s',pname,fname);
    end
    junk=load(filename);
    ObjectList=junk.ObjectList;
    ObjectVertices=junk.ObjectVertices;
    clear junk


    %DETERMINE INFO ABOUT DATA
    fprintf('\n\nObjectList contains:\n');
    ObjectList'
    fprintf('\n');
    scenario=9; %dummy value
    while ~(all(ismember(num2str(scenario),'0123456')))

        fprintf('\n\n');
        fprintf('Select the scenario number that best describes your data:\n');

        fprintf('\t1) Data contains Epi & Endo.  Need to add Peri.  Data names need to be corrected.\n');
        fprintf('\t2) Data contains Epi & Endo.  Need to add Peri.  Data names are correct.\n');
        fprintf('\n');
        fprintf('\t3) Data contains Epi & Peri.  Need to add Endo.  Data names need to be corrected.\n');
        fprintf('\t4) Data contains Epi & Peri.  Need to add Endo.  Data names are correct.\n');
        fprintf('\n');
        fprintf('\t5) Data contains Epi, Peri, & Endo.  Data names need to be corrected.\n');
        fprintf('\t6) Data contains Epi, Peri, & Endo.  Data names are correct.\n');
        fprintf('\n');
        fprintf('\t Enter 0 to escape\n');
        fprintf('\n\n');
        fprintf('\t');

        scenario=input('------------------->  ');
    end

    %CORRECT DATA IF NEEDED
    if (scenario==1) %Epi and Endo exist, but need to add Peri.

        %Data contains all objects, but names are incorrect.  Create
        %message string and then collect names
        string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
        string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
        string=[string        '\t Endo is in the endoneurium objects name\n'];
        string=[string 'Perineiurm names will be created from your endoneurium names.\n--->'];
        [ObjectVertices,ObjectList]=CollectNames(ObjectVertices,ObjectList,string);


        %using names and Endo coordinates, create Peris
        [ObjectVertices,ObjectList]=CreatePeris(ObjectVertices,ObjectList);

    elseif(scenario==2) %Epi and Endo exist, but need to add Peri.

        %using names and Endo coordinates, create Peris
        [ObjectVertices,ObjectList]=CreatePeris(ObjectVertices,ObjectList);

    elseif(scenario==3) %Epi and Peri exist, but need to add Endo.
        %Data contains all objects, but names are incorrect.  Create
        %message string and then collect names
        string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
        string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
        string=[string        '\t Peri is in the perineurium objects name\n'];
        string=[string 'Endoneurium names will be created from your perineurium names.\n--->'];
        [ObjectVertices,ObjectList]=CollectNames(ObjectVertices,ObjectList,string);

        %using names and Peri coordinates, create Endos
        [ObjectVertices,ObjectList]=CreateEndos(ObjectVertices,ObjectList);


    elseif(scenario==4) %Epi and Peri exist, but need to add Endo.

        %using names and Peri coordinates, create Endos
        handles=CreateEndos(hObject,eventdata,handles);

    elseif(scenario==5)
        %Data contains all objects, but names are incorrect.  Create
        %message string and then collect names
        string='Assign a name to the red object.  Names can be unique but should contain appropriate strings.\n';
        string=[string 'Ensure:\t Epi is in the epinurium object name\n'];
        string=[string        '\t Peri is in the perineurium objects name\n'];
        string=[string        '\t Endo is in the endoneurium objects name\n--->'];
        [ObjectVertices,ObjectList]=CollectNames(ObjectVertices,ObjectList,string);


    elseif(scenario==6)
        %Data is ready to process immediately
    end


    %CONTINUE?
    if (scenario==0)
        quit
    end

    %INCLUDE ENCAPSULATION?
    EncapsulationThickness=input('Enter electrode encapsulation thickness in mm.  \n     Enter 0 for no encapsulation.  \n     Default value should be 0.25.  ');
    FinalDimensions=FinalDimensions-2*EncapsulationThickness;


    %ADD BUFFER REGION?
    BufferThickness=-1; %dummy
    BufferThickness=input('Enter the buffer thickness between fascicles in mm.  This is helpful for FEM simulations. \n     Enter 0 for no buffer. \n     Default value should be 0.05.  ');

    while (BufferThickness<0)
        fprintf('\n\nBUFFER CAN NOT BE LESS THAN 0!\n');
        BufferThickness=input('Enter the buffer thickness between fascicles in mm.  This is helpful for FEM simulations.  \n     Enter 0 for no buffer. \n     Default value should be 0.05.  ');
    end


    %TREAT FASCICLES AS CIRCLES?
    FasciclesAsCircles=input('Do you want to treat fascicles as circles? (Y/N)  Enter Q to quit. ','s');
    FasciclesAsCircles=upper(FasciclesAsCircles);
    while ~(all(ismember(FasciclesAsCircles,'YNQ')))
        FasciclesAsCircles=input('Incorrect input!  Do you want to treat fascicles as circles? (Y/N)  Enter Q to quit.','s');
        FasciclesAsCircles=upper(FasciclesAsCircles);
    end


    %CONTINUE?
    if (strcmp(FasciclesAsCircles,'Q'))
        quit;
    elseif (strcmp(FasciclesAsCircles,'N'))
        fprintf('\n\nTHIS PROGRAM IS ONLY DESIGNED TO RUN WITH FASCICLES SHAPED AS CIRCLES (I.E., DEFINED BY A SINGLE RADIUS).  PROGRAM IS EXITING.\n');
        quit;
    else
        %RESHAPE ALL FASCICLES TO CIRCLES
        for i=1:length(ObjectList)
            if ~(strcmp(ObjectList{i},'Epineurium'))
                temp_fasc=ObjectVertices.(ObjectList{i});

                %calculate area
                temp_area=polyarea(temp_fasc(:,1),temp_fasc(:,2));

                %calculate centroid
                [temp_x, temp_y]=centroid(temp_fasc);

                %calculate resulting radius
                temp_radius=sqrt(temp_area/pi);

                %create new 50-sided "circle"
                theta=[0:(2*pi/20):2*pi]';
                new_fasc=[];
                new_fasc(:,1)=temp_radius.*cos(theta)+temp_x;
                new_fasc(:,2)=temp_radius.*sin(theta)+temp_y;

                %create a radius vector for later use
                ObjectRadii.(ObjectList{i})=temp_radius;

                %update the object vertices
                ObjectVertices.(ObjectList{i})=new_fasc;
            end
        end
    end
    clear new_fasc temp_fasc temp_area temp_x temp_y temp_radius ans pname filename response scenario theta


    if (strcmp(type,'F'))
        fprintf('\n\nYou opened: %s\n',fname);
        fname_base=input('Provide a base name for files to save.  \n This name will be appended by the dimensions of the electrode.  ','s');

        clear type
        for i=1:size(FinalDimensions,1)
            fname=[fname_base ', ' num2str(FinalDimensions(i,1)+EncapsulationThickness*2) 'x' num2str(FinalDimensions(i,2)+EncapsulationThickness*2) ' mm, ' num2str(EncapsulationThickness) ' mm encapsulation, ' num2str(BufferThickness) ' mm buffer.mat'];

            ObjectVertices=ReshapeWithFINE(ObjectVertices,ObjectList,ObjectRadii,BufferThickness,FinalDimensions(i,1:2));


            eval(['save ''' fname ''''])

            WriteSM2(ObjectList,ObjectVertices,fname)

            %SAVE THE FIGURE TO THE SAME LOCATION AS THE MAT FILE
            saveas(gcf, [fname(1:end-4) '.fig'], 'fig');
        end
    end
end




function [ObjectVertices,ObjectList]=CollectNames(ObjectVertices,ObjectList,string)

%PLOT OBJECTS
figure(1)
hold off
for i=1:length(ObjectList)
    plot(ObjectVertices.(ObjectList{i})(:,1), ObjectVertices.(ObjectList{i})(:,2),'k');
    hold on
end

%highlight each object at a time and poll for object name
for i=1:length(ObjectList)
    plot(ObjectVertices.(ObjectList{i})(:,1), ObjectVertices.(ObjectList{i})(:,2),'r');
    hold on
    if (i>1)
        plot(ObjectVertices.(ObjectList{i})(:,1), ObjectVertices.(ObjectList{i})(:,2),'k'); %un-highlight the last object
    end
    clc
    name=input(string,'s');
    NewObjectList{i}=name;
    NewObjectVertices.(name)=[ObjectVertices.(ObjectList{i})(:,1), ObjectVertices.(ObjectList{i})(:,2)];
end
ObjectVertices=NewObjectVertices;
ObjectList=NewObjectList;


function [ObjectVertices,ObjectList]=CreatePeris(ObjectVertices,ObjectList)
NewObjectList={};
for i=1:length(ObjectList)
    endoindex=strfind(lower(ObjectList{i}),'endo');

    if (~isempty(endoindex)) %assume we're dealing with an endoneurium and that another object didn't happen to have 'endo' in it's name
        tempname='';
        tempname=ObjectList{i};

        %clean up the name: convert endo->peri (if 'neurium' was included,
        %it stays in place).  Maintain case.
        endoindex=strfind(ObjectList{i},'endo');
        Endoindex=strfind(ObjectList{i},'Endo');
        ENDOindex=strfind(ObjectList{i},'ENDO');

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
        endoverts=ObjectVertices.(ObjectList{i});

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
    ObjectList{end+1}=NewObjectList{i};
    ObjectVertices.(NewObjectList{i})=NewObjectVertices.(NewObjectList{i});
end


function [ObjectVertices,ObjectList]=CreateEndos(ObjectVertices,ObjectList)
NewObjectList={};
for i=1:length(ObjectList)
    periindex=strfind(lower(ObjectList{i}),'peri');

    if (~isempty(periindex)) %assume we're dealing with a perineurium and that another object didn't happen to have 'peri' in it's name
        tempname='';
        tempname=ObjectList{i};

        %clean up the name: convert peri->endo (if 'neurium' was included,
        %it stays in place).  Maintain case.
        periindex=strfind(ObjectList{i},'peri');
        Periindex=strfind(ObjectList{i},'Peri');
        PERIindex=strfind(ObjectList{i},'PERI');

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
        periverts=ObjectVertices.(ObjectList{i});

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
    ObjectList{end+1}=NewObjectList{i};
    ObjectVertices.(NewObjectList{i})=NewObjectVertices.(NewObjectList{i});
end



function ObjectVertices=ReshapeWithFINE(ObjectVertices,ObjectList,ObjectRadii,BufferThickness,FinalDimensions)

%DETERMINE OBJECT TYPES
types=zeros(length(ObjectList),1);  % 1: Epineurium, 2:Perineurium, 3:Endoneurium
for i=1:length(ObjectList)
    if (~isempty(strfind(lower(ObjectList{i}),'epi')))
        types(i)=1;
    elseif (~isempty(strfind(lower(ObjectList{i}),'peri')))
        types(i)=2;
    elseif (~isempty(strfind(lower(ObjectList{i}),'endo')))
        types(i)=3;
    end
end
type1=find(types==1);
type2=find(types==2);
type3=find(types==3);


%DETERMINE GROWTH
FINE.FinalHeight=FinalDimensions(1);
FINE.FinalWidth=FinalDimensions(2);
FINE.CurrentHeight=FinalDimensions(1);
FINE.CurrentWidth=FinalDimensions(2);

% If the closed FINE already encompasses all objects, then no
% reshaping needs to occur.  If not, then the electrode needs to be "grown"
% in order to start at an "open" configuration.  Only need to test the
% outermost object - the epineurium.  This section only needs to be run on
% the first iteration.  After that, the diameter passed to subsequent
% iterations will be reductions.

% Establish the coordinates of the FINE centered about (0,0)
FINE.CurrentVertices=[-FINE.CurrentWidth/2, -FINE.CurrentHeight/2;
    -FINE.CurrentWidth/2,  FINE.CurrentHeight/2;
    FINE.CurrentWidth/2,  FINE.CurrentHeight/2;
    FINE.CurrentWidth/2, -FINE.CurrentHeight/2];

in = inpolygon(ObjectVertices.(ObjectList{type1})(:,1), ...
    ObjectVertices.(ObjectList{type1})(:,2), ...
    FINE.CurrentVertices(:,1), FINE.CurrentVertices(:,2));

while (~min(in)) %a 0 appeared, so cuff is smaller than nerve

    %"grow" cuff by finding the maximum distance between each point on
    %the epineurium and (0,0), about which the electrode (and nerve)
    %are assumed to be centered.
    FINE.CurrentWidth=FINE.CurrentWidth*1.1;
    FINE.CurrentHeight=FINE.CurrentHeight*1.1;

    FINE.CurrentVertices=[-FINE.CurrentWidth/2 -FINE.CurrentHeight/2;
        -FINE.CurrentWidth/2  FINE.CurrentHeight/2;
        FINE.CurrentWidth/2  FINE.CurrentHeight/2;
        FINE.CurrentWidth/2 -FINE.CurrentHeight/2];

    % Close electrode
    FINE.CurrentVertices(end+1,:)=FINE.CurrentVertices(1,:);


    in = inpolygon(ObjectVertices.(ObjectList{type1})(:,1), ...
        ObjectVertices.(ObjectList{type1})(:,2), ...
        FINE.CurrentVertices(:,1), FINE.CurrentVertices(:,2));
end


%DETERMINE CETROIDS FOR LATER MOVEMENT
for i=1:length(type2)
    peri_verts=ObjectVertices.(ObjectList{type2(i)});
    [x,y]=centroid(peri_verts(:,1),peri_verts(:,2));
    OriginalCentroids.(ObjectList{type2(i)})=[x,y];
end
clear peri_verts
ObjectCentroids=OriginalCentroids;


%% CHECK DIAMETER
steps=100;
dWidth=(FINE.CurrentWidth-FINE.FinalWidth)/steps;
dHeight=(FINE.CurrentHeight-FINE.FinalHeight)/steps;


figure(1)
hold off
for i=1:length(type2)
    plot(ObjectVertices.(ObjectList{type2(i)})(:,1),ObjectVertices.(ObjectList{type2(i)})(:,2),'Color',[.8 .8 .8])
    hold on
end

tic
for step_no=1:steps

    % Reduce the current size
    FINE.CurrentWidth=FINE.CurrentWidth-dWidth;
    FINE.CurrentHeight=FINE.CurrentHeight-dHeight;

    % Establish the coordinates of the FINE electrode centered about (0,0)
    FINE.CurrentVertices=[-FINE.CurrentWidth/2 -FINE.CurrentHeight/2;
        -FINE.CurrentWidth/2  FINE.CurrentHeight/2;
        FINE.CurrentWidth/2  FINE.CurrentHeight/2;
        FINE.CurrentWidth/2 -FINE.CurrentHeight/2];

    % Close electrode
    FINE.CurrentVertices(end+1,:)=FINE.CurrentVertices(1,:);

    % RESHAPE EPINEURIUM IF NEEDED
    [epi_verts]=ReshapeEpiWithElectrode(ObjectVertices.(ObjectList{type1}),FINE.CurrentVertices);
    ObjectVertices.(ObjectList{type1})=epi_verts;
    [ObjectVertices,ObjectCentroids]=MoveFascicles4(ObjectList,ObjectVertices,ObjectRadii,ObjectCentroids,BufferThickness,types,FINE);

end


%MOVE THE ENDONEURIUMS TO BE CONCENTRIC WITH THE PERINEURIUMS THAT
%MOVED
ObjectVertices=ReAlignEndos(ObjectList,ObjectVertices,type2,OriginalCentroids);

%PLOT FINAL IMAGE
figure(1)
for i=1:length(type1)
    plot(ObjectVertices.(ObjectList{type1(i)})(:,1),ObjectVertices.(ObjectList{type1(i)})(:,2),'g')
    hold on
end

for i=1:length(type2)
    plot(ObjectVertices.(ObjectList{type2(i)})(:,1),ObjectVertices.(ObjectList{type2(i)})(:,2),'r')
    hold on
end

for i=1:length(type3)
    plot(ObjectVertices.(ObjectList{type3(i)})(:,1),ObjectVertices.(ObjectList{type3(i)})(:,2),'m')
    hold on
end

axis tight




function [epi_verts]=ReshapeEpiWithElectrode(vertices1,vertices2)
%This function accepts 2 inputs:
%  vertices1 are the vertices (no repeats) of the epineurium
%  vertices2 are the vertices (no repeats) of the electrode

warning off all


%round vertices to remove machine error
epi_verts=(round(vertices1.*1E4)./1E4);
electrode_verts=(round(vertices2.*1E4)./1E4);

%polybool assumes that individual contours whose vertices are clockwise
%ordered are external contours, and that contours whose vertices are 
%counterclockwise ordered are internal contours. You can use poly2cw to 
%convert a polygonal contour to clockwise ordering

[epi_verts(:,1),epi_verts(:,2)]=poly2ccw(epi_verts(:,1),epi_verts(:,2));
[electrode_verts(:,1),electrode_verts(:,2)]=poly2cw(electrode_verts(:,1),electrode_verts(:,2));




starting_area=polyarea(epi_verts(:,1),epi_verts(:,2));

%determine which points in the epineurium are outside the electrode
[in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
    electrode_verts(:,1), electrode_verts(:,2));

moved=[];
while (min(in)==0)
    clear junk1 junk2
    epi_verts=(round(epi_verts.*1E4)./1E4);

    [junk1,junk2]=polybool('intersection',epi_verts(:,1),epi_verts(:,2),electrode_verts(:,1),electrode_verts(:,2));

    epi_verts=[junk1, junk2];
    epi_verts=(round(epi_verts.*1E4)./1E4);

    %I should never need to move the electrode-moved points again
    moved=[moved;find(in==0)];
    moved=unique(moved);
    
    %something must have moved....
    %All epineurium points outside the electrode have now moved in.  This
    %has resulted in a decreased area.  Now I want to grow out the points
    %that were originally inside in an effort to minimize dArea.
    %make the simple assumption that all vertices will move to correct
    %dArea.  More likely, there's more motion in areas closer to the points
    %that are being reshaped.  I'll  find a range using a course
    %resoluation.  Of course, only do this if there are free points to
    %move.

    [in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
        electrode_verts(:,1), electrode_verts(:,2));

    move=find(in==1 & on==0);  %pts that can move must be inside and not touching the electrode
    
    if (length(move)>0)
        %free points exist for moving

        ending_area=polyarea(epi_verts(:,1),epi_verts(:,2));
        dArea=starting_area-ending_area;

        epsilon=.0001;

        epi_test=epi_verts;

        while (abs(dArea/starting_area) > epsilon)
            if (dArea>0)
                epi_verts(move,:)=epi_verts(move,:).*1.01;
            else
                epi_verts(move,:)=epi_verts(move,:)./1.005;
            end
            ending_area=polyarea(epi_verts(:,1),epi_verts(:,2));
            dArea=starting_area-ending_area;
        end
        [in, on] = inpolygon(epi_verts(:,1), epi_verts(:,2), ...
            electrode_verts(:,1), electrode_verts(:,2));

        %if the culprit (outlier) is one that I already moved, then I'm not
        %going to allow myself to go through this again
        in(moved)=1;

    else
        in=1;
    end
    

end







function [ObjectVertices, OriginalCentroid]=MoveFascicles4(ObjectList,ObjectVertices,ObjectRadii,OriginalCentroid,BufferThickness,types,FINE)
warning off all

%PARSE TYPES
%type 1: Epineurium
%type 2: Perineurium
%type 3: Endoneurium
type1=find(types==1);
type2=find(types==2);
type3=find(types==3);

all_intersections=0;
max_iterations=100;
this_iteration=0;
all_fascicles=[];
while (this_iteration<max_iterations)
    
    if (this_iteration==0)
        all_intersections=[];
    end
    
    %DETERMINE IF THE ELECTRODE HAS SHIFTED ANY FASCICLES INWARD
    electrode_shifted=zeros(length(type2),2); %col 1: x-shift occurred, col 2: y-shift occurred; +1 = positive direction, -1 = negative direction
    for i=1:length(type2)

        %FASCICLE IS OUTSIDE CUFF IF CENTROID+RADIUS+BUFFER > HEIGHT OR WIDTH
        temp_loc=[];
        temp_loc_x=[];
        temp_loc_y=[];

        temp_loc=OriginalCentroid.(ObjectList{type2(i)});
        temp_loc_x=temp_loc(1);
        temp_loc_y=temp_loc(2);

        temp_radius=[];
        temp_radius=ObjectRadii.(ObjectList{type2(i)});

        move_x=0;
        move_y=0;

        if (temp_loc_x>=0)
            fasc_x=temp_loc_x+temp_radius+BufferThickness;
            move_x=FINE.CurrentWidth/2-fasc_x;
        else
            fasc_x=temp_loc_x-temp_radius-BufferThickness;
            move_x=-FINE.CurrentWidth/2-fasc_x;
        end

        if (temp_loc_y>=0)
            fasc_y=temp_loc_y+temp_radius+BufferThickness;
            move_y=FINE.CurrentHeight/2-fasc_y;
        else
            fasc_y=temp_loc_y-temp_radius-BufferThickness;
            move_y=-FINE.CurrentHeight/2-fasc_y;
        end


        if (abs(fasc_x)>FINE.CurrentWidth/2)
            %FASCICLE IS BEYOND CUFF WIDTH

            if (abs(fasc_y)>FINE.CurrentHeight/2)
                %FASCICLE IS ALSO BEYOND CUFF HEIGHT

                %MOVE IN X AND Y DIRECTIONS
                ObjectVertices.(ObjectList{type2(i)})(:,1)=ObjectVertices.(ObjectList{type2(i)})(:,1)+move_x;
                OriginalCentroid.(ObjectList{type2(i)})(1)=OriginalCentroid.(ObjectList{type2(i)})(1)+move_x;

                ObjectVertices.(ObjectList{type2(i)})(:,2)=ObjectVertices.(ObjectList{type2(i)})(:,2)+move_y;
                OriginalCentroid.(ObjectList{type2(i)})(2)=OriginalCentroid.(ObjectList{type2(i)})(2)+move_y;
                
                %record for later control of movement...
                electrode_shifted(i,1)=sign(move_x);
                electrode_shifted(i,2)=sign(move_y);
            else
                %MOVE ALONG X-AXIS
                ObjectVertices.(ObjectList{type2(i)})(:,1)=ObjectVertices.(ObjectList{type2(i)})(:,1)+move_x;
                OriginalCentroid.(ObjectList{type2(i)})(1)=OriginalCentroid.(ObjectList{type2(i)})(1)+move_x;
                
                %record for later control of movement...
                electrode_shifted(i,1)=sign(move_x);
            end
        elseif (abs(fasc_y)>FINE.CurrentHeight/2)
            %FASCICLE IS BEYOND CUFF HEIGHT

            %MOVE ALONG Y-AXIS
            ObjectVertices.(ObjectList{type2(i)})(:,2)=ObjectVertices.(ObjectList{type2(i)})(:,2)+move_y;
            OriginalCentroid.(ObjectList{type2(i)})(2)=OriginalCentroid.(ObjectList{type2(i)})(2)+move_y;
            
            %record for later control of movement...
            electrode_shifted(i,2)=sign(move_y);
        end
    end
    
    %DETERMINE DISTANCE-TO-CENTER MATRIX, ANGLE MATRIX, REQUIRED DISTANCE
    distances=zeros(length(type2));
    angles=zeros(length(type2));
    required_distances=zeros(length(type2));
    for i=1:length(type2)-1
        for j=i+1:length(type2)
            distances(i,j)=sqrt((OriginalCentroid.(ObjectList{type2(i)})(1)-OriginalCentroid.(ObjectList{type2(j)})(1))^2+(OriginalCentroid.(ObjectList{type2(i)})(2)-OriginalCentroid.(ObjectList{type2(j)})(2))^2);

            %for angle matrix, row (i) is assumed to be at (0,0)
            i_offset=OriginalCentroid.(ObjectList{type2(i)});
            j_centroid=OriginalCentroid.(ObjectList{type2(j)});
            j_centroid=[j_centroid(1)-i_offset(1), j_centroid(2)-i_offset(2)];

            angles(i,j)=CalculateAlpha(j_centroid);


            %required distance = radius(i) + radius(j) + buffer
            required_distances(i,j)=ObjectRadii.(ObjectList{type2(i)})+ObjectRadii.(ObjectList{type2(j)})+BufferThickness;
        end
    end


    junk=distances-required_distances; %<0 means it needs to move

    %CREATE MASK
    mask=zeros(size(junk));
    mask(find(junk<0))=1;

    %NUMBER OF 1s PER ROW ARE THE NUMBER OF INTERSECTIONS OF THAT FASCICLE
    temp_intersections=sum(mask,2);

    %ACCOUNT FOR THE FINAL FASCICLE
    temp_intersections(end)=sum(mask(:,end));

    %DETERMINE WHICH FASCICLES HAVE INTERSECTIONS
    temp_fascicles=1:length(temp_intersections);
    temp_fascicles(find(temp_intersections==0))=[];
    temp_intersections(find(temp_intersections==0))=[];

    
    all_fascicles=[all_fascicles,temp_fascicles];
    all_intersections=[all_intersections,temp_intersections];


    if (length(all_intersections)>0)
        %SORT IN ORDER OF INTERSECTIONS
        [all_intersections, index]=sort(all_intersections);
        all_fascicles=all_fascicles(index);
    else
        %THERE ARE NO INTERSECTIONS, SO GET OUT OF LOOP
        break;
    end
    


    NumberOfFascicleIntersections=length(all_fascicles);
    for i=1:NumberOfFascicleIntersections
        temp_fascicle=all_fascicles(1);


        [temp_fascicle_intersections, index2]=find(mask(temp_fascicle,:)==1);
        temp_angles=angles(temp_fascicle,index2);

        %ADJUST THE LOCATION OF THE TEMP FASCICLE
        hyps=[];
        xs=[];
        ys=[];

        hyps=junk(temp_fascicle,index2);
        xs=cos(deg2rad(temp_angles)).*(hyps./2);
        ys=sin(deg2rad(temp_angles)).*(hyps./2);

        x=sum(xs);
        y=sum(ys);
        
        %IF THE ELECTRODE MOVED THIS FASCICLE, MAY NEED TO RESTRICT MOTION
        if (electrode_shifted(temp_fascicle,1)~=0)
            %ELECTRODE SHIFTED THIS FASCICLE IN THE X-DIRECTION...
            x=0;
        end
        if (electrode_shifted(temp_fascicle,2)~=0)
            %ELECTRODE SHIFTED THIS FASCICLE IN THE Y-DIRECTION...
            y=0;
        end

        OriginalCentroid.(ObjectList{type2(temp_fascicle)})=[OriginalCentroid.(ObjectList{type2(temp_fascicle)})(1)+x, OriginalCentroid.(ObjectList{type2(temp_fascicle)})(2)+y];
        ObjectVertices.(ObjectList{type2(temp_fascicle)})(:,1)=ObjectVertices.(ObjectList{type2(temp_fascicle)})(:,1)+x;
        ObjectVertices.(ObjectList{type2(temp_fascicle)})(:,2)=ObjectVertices.(ObjectList{type2(temp_fascicle)})(:,2)+y;

        for j=1:length(index2)
            %ALSO ADJUST THE LOCATION OF THE INTERSECTED FASCICLES
            temp_fascicle2=index2(j);

            if (temp_fascicle2<temp_fascicle)
                temp_angle2=angles(temp_fascicle,temp_fascicle2);
            else
                temp_angle2=angles(temp_fascicle,temp_fascicle2)+180;
            end

            hyp2=[];
            x2=[];
            y2=[];

            hyp2=junk(temp_fascicle,temp_fascicle2);
            x2=cos(deg2rad(temp_angle2))*hyp2/2;
            y2=sin(deg2rad(temp_angle2))*hyp2/2;
            
            %IF THE ELECTRODE MOVED THIS FASCICLE, MAY NEED TO RESTRICT MOTION
            if (electrode_shifted(temp_fascicle2,1)~=0)
                %ELECTRODE SHIFTED THIS FASCICLE IN THE X-DIRECTION...
                x2=0;
            end
            if (electrode_shifted(temp_fascicle2,2)~=0)
                %ELECTRODE SHIFTED THIS FASCICLE IN THE Y-DIRECTION...
                y2=0;
            end

            OriginalCentroid.(ObjectList{type2(temp_fascicle2)})=[OriginalCentroid.(ObjectList{type2(temp_fascicle2)})(1)+x2, OriginalCentroid.(ObjectList{type2(temp_fascicle2)})(2)+y2];
            ObjectVertices.(ObjectList{type2(temp_fascicle2)})(:,1)=ObjectVertices.(ObjectList{type2(temp_fascicle2)})(:,1)+x2;
            ObjectVertices.(ObjectList{type2(temp_fascicle2)})(:,2)=ObjectVertices.(ObjectList{type2(temp_fascicle2)})(:,2)+y2;
        end
        all_fascicles(1)=[];
        all_intersections(1)=[];
    end

    this_iteration=this_iteration+1;
end

figure(1)
for i=1:length(type2)
    plot(OriginalCentroid.(ObjectList{type2(i)})(1),OriginalCentroid.(ObjectList{type2(i)})(2),'Color',[.8 .8 .8]);
    hold on
end



function alpha=CalculateAlpha(fasc_centroid)
%DETERMINE IF ON AXIS
if (fasc_centroid(1)==0)
    %on y-axis
    if (fasc_centroid(2)>0)
        alpha=90;
    else
        alpha=270;
    end
elseif (fasc_centroid(2)==0)
    %on x-axis
    if (fasc_centroid(1)>=0)
        alpha=0;
    else
        alpha=180;
    end

else
    %DETERMINE QUADRANT
    if (fasc_centroid(1)>0)
        %quad 1 or 4
        if (fasc_centroid(2)>0)
            %quad 1
            alpha=rad2deg(atan(fasc_centroid(2)/fasc_centroid(1)));
        else
            %quad 4
            alpha=rad2deg(atan(fasc_centroid(2)/fasc_centroid(1)))+360;
        end
    else
        %quad 2 or 3

        if (fasc_centroid(2)>0)
            %quad 2
            alpha=abs(rad2deg(atan(fasc_centroid(2)/fasc_centroid(1))))+90;
        else
            %quad 3
            alpha=rad2deg(atan(fasc_centroid(2)/fasc_centroid(1)))+180;
        end
    end
end



function ObjectVertices=ReAlignEndos(ObjectList,ObjectVertices,type2,OriginalCentroid)
for i=1:length(type2)

    peri_verts=ObjectVertices.(ObjectList{type2(i)});

    [x,y]=centroid(peri_verts(:,1),peri_verts(:,2));

    dx=x-OriginalCentroid.(ObjectList{type2(i)})(1);
    dy=y-OriginalCentroid.(ObjectList{type2(i)})(2);

    %clean up the name: convert peri->endo (if 'neurium' was included,
    %it stays in place).  Maintain case.
    periindex=strfind(ObjectList{type2(i)},'peri');
    Periindex=strfind(ObjectList{type2(i)},'Peri');
    PERIindex=strfind(ObjectList{type2(i)},'PERI');

    tempname='';
    tempname=ObjectList{type2(i)};

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

    ObjectVertices.(newname)(:,1)=ObjectVertices.(newname)(:,1)+dx;
    ObjectVertices.(newname)(:,2)=ObjectVertices.(newname)(:,2)+dy;
end




function WriteSM2(ObjectList,ObjectVertices,fname)
% WriteSM2 takes three inputs:
%    ObjectList is a cell arrray of each object
%    ObjectVertices is a cell array of the (x,y) vertices of each object in
%      ObjectList, in the same order, in a clock-wise or counter-clockwise
%      fashion.
%    FileName is the name of the SM2 file to generate, including the
%      directory.
%
% WriteSM2 returns no outputs but generates an SM2 file that can be used to
% generate a finite element model.
%
%  E.G., ObjectList={'Obj1','Obj2','Obj3'};
%        ObjectVertices.Obj1=[x,y] for 'Obj1'
%        ObjectVertices.Obj2=[x,y] for 'Obj2'
%        ObjectVertices.Obj3=[x,y] for 'Obj3'

% Written by: Matthew Schiefer, Ph.D.
%             Case Western Reserve University
%             March 25, 2009
%             matthew.schiefer@case.edu

%ensure no object has the same ending and beginning point

% [fname,pname]=uiputfile('*.sm2','Create .sm2 file for Ansoft');
% if (isequal(fname,0) || isequal(pname,0))
%     fprintf('\n\nCANCEL pressed.  No data saved.\n');
%     quit
% else


    for i=1:length(ObjectList)
        temp_verts=ObjectVertices.(ObjectList{i});
        temp_verts=(round(temp_verts.*10000))./10000;
        if ((temp_verts(1,1)==temp_verts(end,1)) && (temp_verts(1,2)==temp_verts(end,2)))
            ObjectVertices.(ObjectList{i})=temp_verts(1:end-1,:);
        end
    end
    fname(end-3:end)=[];
    fname=[fname '.sm2'];
    fullname=fname;
%     fullname=[pname fname]
%     button='Yes';
%     if exist(fullname,'file')
%         button=questdlg([fname ' already exists.  Overwrite?'],'Alert');
%     end
% 
%     if (strcmp(button,'Yes'))
        TotalObjects=length(ObjectList);

        if (TotalObjects>0)

            %create file
            fid=fopen(fullname,'w');

            %Write File Header
            writeHeader(fid);

            %Begin Data Section
            fprintf(fid,'B_DATA\n');

            %Write Settings Section
            writeSettings(fid,ObjectVertices,ObjectList);

            %Begin Item Section
            fprintf(fid,' B_ITEMS %d\n',TotalObjects);

            %Write Objects Section
            writeObjects(fid,ObjectList,ObjectVertices);

            %End Items Section
            fprintf(fid,' E_ITEMS\n');

            %End Data Section
            fprintf(fid,'E_DATA\n');

            fclose(fid);
        end
%     else
%         msgbox('No SM2 file was created');
%     end
%end





%% Print Header
function writeHeader(fid)

fprintf(fid,'B_HEADER\n');
fprintf(fid,' FileSign SLD2 FormVers 1.100 CreaSign ANS0 CreaVers 3.000\n');
fprintf(fid,'E_HEADER\n');





%% Print Settings
function writeSettings(fid,ObjectVertices,ObjectList)

fprintf(fid,' B_SETNGS\n');
fprintf(fid,'  Units mm\n');
fprintf(fid,'  Plane XY\n');
fprintf(fid,'  Extent\n');

%Print Bounding Box
TotalObjects=writeBoundingBox(fid,ObjectVertices,ObjectList);

%print the total number of objects in the model
fprintf(fid,'  MaxId %d\n',TotalObjects);

fprintf(fid,'  DefColor 8\n');
fprintf(fid,'  DefTexSz .0015\n');
fprintf(fid,'  GridSnap Y VertSnap Y\n');
fprintf(fid,'  CoordSys 0 0 0\n');
fprintf(fid,'  Grid cartesian 0.002 0.002\n');
fprintf(fid,'  GridVis Y\n');
fprintf(fid,'  DrawKey Y\n');

fprintf(fid,' E_SETNGS\n');





%% Print Objects
function writeObjects(fid,ObjectList,ObjectVertices)

CumulativeObjectNumber=0;

for i=1:length(ObjectList)

    LastObjectNumber=CumulativeObjectNumber;

    CumulativeObjectNumber=CumulativeObjectNumber+size(ObjectVertices.(ObjectList{i}),1)*2+1;
    %*2 accounts for the same number of edges as there are vertices.
    %+1 accounts for the fact that this is an object
    %E.G., a square is an object, but it has 8 "sub-objects": the 4
    %      vertices and the 4 faces, which must be accounted for first.  So
    %      the square is object number 9, the vertices having object
    %      numbers 1-4 and the sides having object numbers 5-8.
    %THIS ONLY WORKS IF OBJECTS ARE CLOSED!  LINE SEGMENTS WILL CAUSE FAILURE!

    fprintf(fid,'  B_OBJECT %d %s\n',CumulativeObjectNumber,ObjectList{i});
    fprintf(fid,'   Color 2156168385\n');
    fprintf(fid,'   Visible Y Selected N Model Y Hatches N Closed Y\n');
    fprintf(fid,'   CoordSys 0 0 0\n');

    %Print Bounding Box
    junk=writeBoundingBox(fid,ObjectVertices.(ObjectList{i}));

    %Print Vertices
    writeVertices(fid,ObjectVertices.(ObjectList{i}),LastObjectNumber);

    %Print Edges
    writeEdges(fid,ObjectVertices.(ObjectList{i}),LastObjectNumber);

    fprintf(fid,'  E_OBJECT\n');

end





%% Print Bounding Box
function TotalObjects=writeBoundingBox(fid,ObjectVertices,varargin)

if (nargin>2)
    ObjectList=varargin{1};
end

%determine the xmin, ymin, xmax, ymax bounding box of the modeling
%space/object
TotalObjects=0;
if (isstruct(ObjectVertices))  %find bounding box of multiple objects

    xmins=zeros(length(ObjectList),1);
    xmaxs=zeros(length(ObjectList),1);
    ymins=zeros(length(ObjectList),1);
    ymaxs=zeros(length(ObjectList),1);

    for i=1:length(ObjectList)
        xmins(i)=min(ObjectVertices.(ObjectList{i})(:,1));
        xmaxs(i)=max(ObjectVertices.(ObjectList{i})(:,1));
        ymins(i)=min(ObjectVertices.(ObjectList{i})(:,2));
        ymaxs(i)=max(ObjectVertices.(ObjectList{i})(:,2));

        %also account for the total number of objects in the system for later
        TotalObjects=TotalObjects+size(ObjectVertices.(ObjectList{i}),1)*2;
        %*2 accounts for the same number of edges as there are vertices.
        %THIS ONLY WORKS IF OBJECTS ARE CLOSED!  LINE SEGMENTS WILL CAUSE FAILURE!
    end
    xmin=min(xmins);
    xmax=max(xmaxs);
    ymin=min(ymins);
    ymax=max(ymaxs);

    TotalObjects=TotalObjects+length(ObjectVertices); %account for "whole" objects

else  %find bounding box of a single object
    xmin=min(ObjectVertices(:,1));
    xmax=max(ObjectVertices(:,1));
    ymin=min(ObjectVertices(:,2));
    ymax=max(ObjectVertices(:,2));

    fprintf(fid,'   BoundBox\n');
end

fprintf(fid,'   %.20f %.20f\n',xmin/1000,ymin/1000);
fprintf(fid,'   %.20f %.20f\n',xmax/1000,ymax/1000);






%% Print Vertices
function writeVertices(fid,ObjectVertices,LastObjectNumber)

fprintf(fid,'   B_VERTS %d\n',size(ObjectVertices,1));

%Each segment has 2 vertices (left and right).
%Edge # starts with a value equal to the number of vertices+1

%Print format:
%  Vertex # (left) connects to Vertex # (right) with Edge #
%  [x y] of the vertex
RightVerts=[1:size(ObjectVertices,1)]+LastObjectNumber;
LeftVerts=[size(ObjectVertices,1)*2,size(ObjectVertices,1)+1:size(ObjectVertices,1)*2-1]+LastObjectNumber;
Edges=[size(ObjectVertices,1)+1:size(ObjectVertices,1)*2]+LastObjectNumber;
for ii=1:size(ObjectVertices,1)
    fprintf(fid,'    Vert %d %d %d\n',RightVerts(ii),LeftVerts(ii),Edges(ii));

    %although the MATLAB vertices are in mm, Ansoft will read the sm2 file
    %as if they are in meters, even though units was set to 'mm' above.
    %Therefore, divide vertices by 1000.
    fprintf(fid,'     %.20f %.20f\n',ObjectVertices(ii,1)./1000,ObjectVertices(ii,2)./1000);
end

fprintf(fid,'   E_VERTS\n');







%% Print Edges
function writeEdges(fid,ObjectVertices,LastObjectNumber)

fprintf(fid,'   B_EDGES %d\n',size(ObjectVertices,1)); %assumes closed objects!

%Print format:
%  Edge # connects Vertex #1 (right) to Vertex #2 (right)
%  [x y] of Vertex #1
%  [x y] of Vertex #2
RightVerts(1,:)=[1:size(ObjectVertices,1)]+LastObjectNumber;
RightVerts(2,1:end-1)=RightVerts(1,2:end);
RightVerts(2,end)=RightVerts(1,1);
Edges=[size(ObjectVertices,1)+1:size(ObjectVertices,1)*2]+LastObjectNumber;
for ii=1:size(ObjectVertices,1)
    fprintf(fid,'    Edge %d %d %d\n',Edges(ii),RightVerts(1:2,ii));

    fprintf(fid,'     Line\n');
    fprintf(fid,'     %.20f %.20f\n',ObjectVertices(ii,1)/1000,ObjectVertices(ii,2)/1000);
    if (ii==size(ObjectVertices,1))
        %print the vertices of the first point
        fprintf(fid,'     %.20f %.20f\n',ObjectVertices(1,1)/1000,ObjectVertices(1,2)/1000);
    else
        %print the vertices of the next point
        fprintf(fid,'     %.20f %.20f\n',ObjectVertices(ii+1,1)/1000,ObjectVertices(ii+1,2)/1000);
    end
end

fprintf(fid,'   E_EDGES\n');




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