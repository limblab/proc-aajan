function [ObjectVertices, Spiral]=ReshapeWithSpiral(ObjectList,ObjectVertices,FinalDiameter,varargin)
% ReshapeWithSpiral(ObjectList, ObjectVertrices, Diameter, Iteration)
%      ObjectList{} is a list of each object being passed in
%           E.G. ObjectList =
%                       {'Epi','Peri1',...,'PeriN','Endo1',...,'EndoN'}
%      ObjectVertices is a structure of vertices associated with each object
%           E.G. ObjectVertices.Epi1 = [x, y]
%                ObjectVertices.Peri1 = [x, y] ...
%  
%            Use dynamic field names to access.
%                 E.G. ObjectVertices.(ObjectList{1}) = ObjectVertices.Epi1
%
% ReshapeWithSpiral also accepts additonal arguments using varargin.  The
%     user should not specify these arguments.  They are used during
%     recursive iterative calls of this function by itself.

if (length(varargin)>0)
    Iteration=varargin{1}+1;
    Spiral.CurrentDiameter=varargin{2};
    types=varargin{3};
    type1=varargin{4};
    type2=varargin{5};
    type3=varargin{6};
else
    Iteration=0;
    Spiral.FinalDiameter=FinalDiameter;
    Spiral.CurrentDiameter=Spiral.FinalDiameter;
end



%% Determine object types
if (Iteration==0)
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
    
    %% Determine Growth
    % If the closed spiral electrode already encompasses all objects, then no
    % reshaping needs to occur.  If not, then the electrode needs to be "grown"
    % in order to start at an "open" configuration.  Only need to test the
    % outermost object - the epineurium.  This section only needs to be run on
    % the first iteration.  After that, the diameter passed to subsequent
    % iterations will be reductions.
    
    % Establish the coordinates of the Spiral electrode centered about (0,0)
    theta=linspace(0, 2*pi)';
    Spiral.CurrentVertices=[Spiral.CurrentDiameter/2.*cos(theta),Spiral.CurrentDiameter/2.*sin(theta)];

    in = inpolygon(ObjectVertices.(ObjectList{type1})(:,1), ...
        ObjectVertices.(ObjectList{type1})(:,2), ...
        Spiral.CurrentVertices(:,1), Spiral.CurrentVertices(:,2));

    if (~min(in)) %a 0 appeared, so cuff is smaller than nerve

        %"grow" cuff by finding the maximum distance between each point on
        %the epineurium and (0,0), about which the electrode (and nerve)
        %are assumed to be centered.
        distances=[];
        distances=dist([0 0],ObjectVertices.(ObjectList{type1})');
        
        Spiral.CurrentDiameter=max(distances)*2;

        %now the spiral has a diameter exactly the size required to
        %encompass the entire epineurium
    end
end

%% Check Diameter
% The iteration will need to run while the spiral diameter exceeds the
% inputted final diameter
dDiameter=(Spiral.CurrentDiameter-Spiral.FinalDiameter)/100;

while (Spiral.CurrentDiameter > Spiral.FinalDiameter)

    % Reduce the current diameter
    Spiral.CurrentDiameter=Spiral.CurrentDiameter-dDiameter;

    % Establish the coordinates of the Spiral electrode centered about (0,0)
    theta=linspace(0, 2*pi)';
    Spiral.CurrentVertices=[Spiral.CurrentDiameter/2.*cos(theta),Spiral.CurrentDiameter/2.*sin(theta)];

    % Reshape Epineurium (if needed)
    [epi_verts]=ReshapeEpiWithElectrode(ObjectVertices.(ObjectList{type1}),Spiral.CurrentVertices);
    ObjectVertices.(ObjectList{type1})=epi_verts;

    %use to move endoneurium later
    for i=1:length(type2)
        peri_verts=ObjectVertices.(ObjectList{type2(i)});
        [x,y]=centroid(peri_verts(:,1),peri_verts(:,2));
        OriginalCentroid.(ObjectList{type2(i)})=[x,y];
    end
    
    fprintf('diam=%.5f, calling MoveFascicles\n',Spiral.CurrentDiameter);
    
    % Move all fascicles that:
    %   1) now intersect the Epineurium
    %   2) now (or subsequently) intersect other fascicles
    ObjectVertices=MoveFasciclesNEW(ObjectList,ObjectVertices,types);

    
    %The endoneuriums need to move with the movements incurred by the
    %perineuriums
    ObjectVertices=ReAlignEndos(ObjectList,ObjectVertices,type2,OriginalCentroid);
end




