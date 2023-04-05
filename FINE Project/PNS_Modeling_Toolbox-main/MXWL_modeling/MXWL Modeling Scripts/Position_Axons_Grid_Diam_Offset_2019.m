function Position_Axons_Grid_Diam_Offset_2019(axons_per_fascicle)
% This positions axons in fascicles. 
% The X and Y positions are random
% But diameters and offsets are not. All are positioned at the same time
% And the offsets are binned
% [This lets you look at differences as axon diameter or offset change]
%
%
% Diams will be 4:15
% Offsets will be [0, 0.1 * IL, 0.2 * IL, 0.3 * IL, 0.4 * IL, 0.5 * IL ], where IL is distance
% between NoR.
%
% So for each Axon we get an X, Y, and a bunch of Z points corresponding to
% 21 NoR at whatever diameter or offset.
%
%
% OUTPUTS:
% AxonPositionsRelativeToCenter.Endo[n].X = [1 x axons]; X positions]
% AxonPositionsRelativeToCenter.Endo[n].Y = [1 x axons]; Y positions]
% AxonPositionsRelativeToCenter.Z = [1 x (Diameters*Offsets*((nodes-1)*11+1))]; grid of Z positions
% AxonPositionsRelativeToCenter.Diameter_Range % list of diameters used
% AxonPositionsRelativeToCenter.Offset_Range % list of offsets used
% AxonPositionsRelativeToCenter.Diamteter_Offset_Indices; % start and stop of
% 'z' index for any particular diameter, offset, in diam_range or offset_range
% So ex:
% Inds= Diameter_Offset_Indices{find(Diameter_Range==10),find(Offset_Range==5)}
% AxonPositionsRelativeToCenter.Z(Inds(1):Inds(2)) gives you the right Z
% locations.


num_of_nodes=21;
node_length=1;

% Output structure.

%open mat file with Endo# details
%place axons with diameter from distribution in fascicles and save their
%locations relative to the centerpoint of the fascicle.  Save this new
%information in a new mat file with the format:
%  AxonPositionsRelativeToCenter.Endo#.Diam=[] (100x1)
%  AxonPositionsRelativeToCenterEndo#.AxonPositions.X=[] (100x1)
%  AxonPositionsRelativeToCenterEndo#.AxonPositions.Y=[] (100x1)
%  AxonPositionsRelativeToCenterEndo#.AxonPositions.Z=[] (100x221)

%open mat file...
filename=['FascicleDescriptions.mat'];
load(filename);
%------------------------------------------------------------------
%assign diameters
%Data from:
%
%  H.S.D. Garven et al.
%  Scottish Medical Journal 7:250-265, 1962
%  pertaining to human posterior tibial nerve
%  Note, fibers 4um or smaller were ignored % PVL mod - not anymore.

Diameter_Range = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; %(um)
Offset_Range = [0, 1, 2, 3, 4, 5]; % * 0.2 * IL/2. '5' corresponds to maximum offset from zero.

% occurrances = [2148, 476, 472, 811, 1359, 1932, 1236, 501, 174, 17, 4, 4];

for temp_fascicle=1:length(FascicleNames)
    
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X=[];
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Y=[];
%     AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Z=[];
    
    temp_verts=Fascicles.(['Endo' num2str(temp_fascicle)]).Vertices;
    center_point=Fascicles.(['Endo' num2str(temp_fascicle)]).CenterPoint;
    
    %re-center points so that random positions are relative to the center
    %of the fascicle.  this only works if the fascicle is symmetric
    temp_verts(:,1)=temp_verts(:,1)-center_point(1);
    temp_verts(:,2)=temp_verts(:,2)-center_point(2);
    
    xmin=min(temp_verts(:,1));
    xmax=max(temp_verts(:,1));
    ymin=min(temp_verts(:,2));
    ymax=max(temp_verts(:,2));
    
    delta_x = xmax-xmin;       %(mm)
    delta_y = ymax-ymin;       %(mm)
    
    while (length(AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X)<axons_per_fascicle)
        xrand = rand()*delta_x + xmin;
        yrand = rand()*delta_y + ymin;
        in = inpolygon(xrand,yrand,temp_verts(:,1),temp_verts(:,2));
        
        if (in)
            xrand=xrand*1000; %(um)
            yrand=yrand*1000; %(um)
            
            %make sure this isn't a repeated point
            repeated=0;
            index_x=find(AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X==xrand);
            index_x=find(AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Y==yrand);
            
            if (~isempty(index_x) && ~isempty(index_y))
                if (index_x==index_y)
                    repeated=1;
                end
            end
            
            if ~(repeated)
                %save info
                AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X(end+1)=xrand;
                AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Y(end+1)=yrand;
            end
        end
    end
    
    all_z_points = []; % storage for all z cooridnates
    for DiamIndex=1:length(Diameter_Range) % for each diameter
        Diam=Diameter_Range(DiamIndex);
        
        %------------------------------------------------------------------
        %calculate the internode distance
        %Generally, IL = 100*fiber diameter.  However,
        %I am using the McIntyre, Richardson, and Grill Double Cable model.
        %There is a node, paranode1 (MYSA), paranode2 (FLUT), and internode
        %node length = 1, paranode 1 length = 3, the other two are
        %functions of the fiber diameter.  The following equations were
        %determined in Excel based on fitting a curve to the data presented
        %in the McIntyre et al (2002) paper.  My IL = his deltax.
        IL = [];
        IL = 969.3.*log(Diam)-1144.6;  % (um)
        %------------------------------------------------------------------
        
        for offsetCount = 1:length(Offset_Range) % 1/11 of IL/2 to 10/11 of IL/2
            %offset can be between 0 and IL/2
            offset = Offset_Range(offsetCount) * 0.2 * (IL/2);
            %------------------------------------------------------------------
            %determine the z coordinates of the 21 NoRs along the axon
            %------------------------------------------------------------------
            %the length of a node of ranvier is 1 um, so account for this
            %assume center is at z=0, center node = node 11
            NoR_z_points = [];
            center_node = round((num_of_nodes+1)/2);
            
            
            % 1. Get the nodes of Ranvier
            NoR_z_points(center_node) = offset;  %(um)
            
            for offset_from_center = 1:1:(num_of_nodes-center_node)
                NoR_z_points((center_node-offset_from_center)) = NoR_z_points((center_node-offset_from_center+1))-IL; %= (um) - (um) Note: node length is already accounted for in IL
                NoR_z_points((center_node+offset_from_center)) = NoR_z_points((center_node+offset_from_center-1))+IL; %= (um) + (um) Note: node length is already accounted for in IL
            end
            
            %2. Get all the intermediate locations for this axon
            for node_point = 1:1:(length(NoR_z_points)-1)
                
                node_z_location = NoR_z_points(node_point); %this is at the center of the node
                node_distance = IL; % (um)
                
                paralength1 = 3;
                paralength2 = 2.5811*(Diam)+19.59;
                internode_step = (IL-node_length-(2*paralength1)-(2*paralength2))/6;
                
                minstep = node_z_location+node_length/2;
                
                for myelin_points = 1:1:10
                    
                    %For Paranode1a, just after a node
                    if (myelin_points == 1)
                        myelin_z_points(((node_point-1)*10+myelin_points)) = minstep + paralength1/2;  %(um)
                    end
                    
                    %For Paranode2a, just after Paranode1
                    if (myelin_points == 2)
                        myelin_z_points(((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2/2; %(um)
                    end
                    
                    %For 6 compartments of internode between Paranode2a and
                    %Paranode2b
                    if (myelin_points > 2 && myelin_points < 9)
                        myelin_z_points(((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + (internode_step*(myelin_points-3)) + internode_step/2;  %(um)
                    end
                    
                    %For Paranode2b, just after the internode compartments
                    if (myelin_points == 9)
                        myelin_z_points(((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + internode_step*6 + paralength2/2;  %(um)
                    end
                    
                    if (myelin_points == 10)
                        myelin_z_points(((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + internode_step*6 + paralength2 + paralength1/2;  %(um)
                    end
                end
            end
            
            % Combine the NoR locations with the internodal locations
            % add to giant list of locations we care about
            % and mark the corresponding diameter and offset
            
            temp_z_points = [NoR_z_points,myelin_z_points];
            
            % And record locations of the diameter and offset
            Diameter_Offset_Indices{DiamIndex,offsetCount}(1) = length(all_z_points)+1;
            all_z_points=[all_z_points,sort(temp_z_points,2,'ascend')];
            Diameter_Offset_Indices{DiamIndex,offsetCount}(2) = length(all_z_points);
            
        end

%         AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Z=all_z_points;
    end
    AxonPositionsRelativeToCenter.Z = all_z_points;
    AxonPositionsRelativeToCenter.Diameter_Range = Diameter_Range;
    AxonPositionsRelativeToCenter.Offset_Range = Offset_Range;
    AxonPositionsRelativeToCenter.Diameter_Offset_Indices = Diameter_Offset_Indices;
end %end temp_fascicle loop

%eval(['save ' '''' '../../../' Model '/AxonLocations/AllModels.mat' '''' ' AxonPositionsRelativeToCenter']);
eval('save (''AxonPositionsRelativeToCenter.mat'', ''AxonPositionsRelativeToCenter'')'); % PVL mod.


