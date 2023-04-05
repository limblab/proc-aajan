function WriteSM2(ObjectList,ObjectVertices,FileName)
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

if (~strcmp(lower(FileName(end-3:end)),'.sm2'))
    FileName=[FileName '.sm2'];
end

button='Yes';
if exist(FileName,'file')
    button=questdlg([FileName ' already exists.  Overwrite?'],'Alert');
end

if (strcmp(button,'Yes'))
    TotalObjects=length(ObjectList);

    if (TotalObjects>0)

        %create file
        fid=fopen(FileName,'w');

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
else
    msgbox('No SM2 file was created');
end

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

fprintf(fid,'   %.20f %.20f\n',xmin,ymin);
fprintf(fid,'   %.20f %.20f\n',xmax,ymax);

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
    fprintf(fid,'     %.20f %.20f\n',ObjectVertices(ii,1),ObjectVertices(ii,2));
    if (ii==size(ObjectVertices,1))
        %print the vertices of the first point
        fprintf(fid,'     %.20f %.20f\n',ObjectVertices(1,1),ObjectVertices(1,2));
    else
        %print the vertices of the next point
        fprintf(fid,'     %.20f %.20f\n',ObjectVertices(ii+1,1),ObjectVertices(ii+1,2));
    end
end

fprintf(fid,'   E_EDGES\n');
