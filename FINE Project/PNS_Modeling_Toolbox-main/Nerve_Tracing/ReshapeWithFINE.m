function [ObjectVertices, FINE]=ReshapeWithFINE(ObjectList,ObjectVertices,FinalWidth,FinalHeight,varargin)
% ReshapeWithFINE(ObjectList, ObjectVertrices, Diameter, Iteration)
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
% ReshapeWithFINE also accepts additonal arguments using varargin.  The
%     user should not specify these arguments.  They are used during
%     recursive iterative calls of this function by itself.

if (length(varargin)>0)
    Iteration=varargin{1}+1;
    FINE.CurrentWidth=varargin{2};
    FINE.CurrentHeight=varargin{3};
    types=varargin{4};
    type1=varargin{5};
    type2=varargin{6};
    type3=varargin{7};
else
    Iteration=0;
    FINE.FinalWidth=FinalWidth;
    FINE.FinalHeight=FinalHeight;
    FINE.CurrentWidth=FINE.FinalWidth;
    FINE.CurrentHeight=FINE.FinalHeight;    
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
end

%% Check Diameter
% The iteration will need to run while the spiral diameter exceeds the
% inputted final diameter
steps=100;
dWidth=(FINE.CurrentWidth-FINE.FinalWidth)/steps;
dHeight=(FINE.CurrentHeight-FINE.FinalHeight)/steps;

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


   
     % Reshape Epineurium (if needed)
    [epi_verts]=ReshapeEpiWithElectrode(ObjectVertices.(ObjectList{type1}),FINE.CurrentVertices);
    ObjectVertices.(ObjectList{type1})=epi_verts;

    %use to move endoneurium later
    for i=1:length(type2)
        peri_verts=ObjectVertices.(ObjectList{type2(i)});
        [x,y]=centroid(peri_verts(:,1),peri_verts(:,2));
        OriginalCentroid.(ObjectList{type2(i)})=[x,y];
    end
    
    fprintf('width=%.5f, height=%.5f, calling MoveFascicles\n',FINE.CurrentWidth,FINE.CurrentHeight);
    
    % Move all fascicles that:
    %   1) now intersect the Epineurium
    %   2) now (or subsequently) intersect other fascicles
%     
%     if (FINE.CurrentHeight<2.2)
%         matt=1
%     end
     
    ObjectVertices=MoveFascicles4(ObjectList,ObjectVertices,types);

    
    %The endoneuriums need to move with the movements incurred by the
    %perineuriums
    ObjectVertices=ReAlignEndos(ObjectList,ObjectVertices,type2,OriginalCentroid);
end




