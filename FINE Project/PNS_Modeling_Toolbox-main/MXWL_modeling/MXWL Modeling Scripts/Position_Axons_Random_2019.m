function Position_Axons_Random_2019(axons)
%PositionAxons() randomly selects the location of axons within each fascicle
%and saves this data relative to the center of the fascicle
% Random, physiologically distributed, Diameter
% Random, offset

% Simplified.


num_of_nodes=21;
node_length=1;

total_axons=axons;

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


for temp_fascicle=1:length(FascicleNames)
    
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X=[];
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Y=[];
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Z=[];

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
   
    while (length(AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).X)<total_axons)
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
    
    %------------------------------------------------------------------
    %assign diameters
    %Data from:
    %
    %  H.S.D. Garven et al.
    %  Scottish Medical Journal 7:250-265, 1962
    %  pertaining to human posterior tibial nerve
    %  Note, fibers 4um or smaller were ignored
    
    % diameter_range = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; %(um)
    % occurrances = [2148, 476, 472, 811, 1359, 1932, 1236, 501, 174, 17, 4, 4];
    diameter_range = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]; %(um)
    occurrances = [476, 472, 811, 1359, 1932, 1236, 501, 174, 17, 4, 4];
    
    
    occurrances=occurrances./sum(occurrances);
    cum_occurrances=[];
    for o_index = 1:length(occurrances)
        cum_occurrances(o_index)=sum(occurrances(1:o_index));
    end
    occurrances=cum_occurrances;
    occurrances=round(occurrances.*10000)./10000;  %make sure there aren't small numerical errors
    
    random_diameters=[];
    for i=1:total_axons
        random_diameters(i)=diameter_range(find(occurrances>=rand(),1)); %choose a random number and determine where it falls in the cumulative percentage
    end
    
    %save info
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Diam=random_diameters;
    
    %OUTPUT: random_diameters has 100 random FIBER diameters (um) that follow the
    %published distrbibutions depending on fiber type.
    %------------------------------------------------------------------
    
    
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
    IL = 969.3.*log(random_diameters)-1144.6;  % (um)
    %------------------------------------------------------------------

    
    %------------------------------------------------------------------
    %randomly calculate the offset of the center node
    %offset can be between 0 and IL/2
    offset = [];
    offset = rand()*(IL/2);  %(um)
    %------------------------------------------------------------------
    
    
    %------------------------------------------------------------------
    %determine the z coordinates of the 21 NoRs along the axon
    %------------------------------------------------------------------
    %the length of a node of ranvier is 1 um, so account for this
    %assume center is at z=0, center node = node 11
    NoR_z_points = [];
    center_node = round((num_of_nodes+1)/2);
    
    for row=1:total_axons
        
        NoR_z_points(row,center_node) = offset(row);  %(um)
        
        for offset_from_center = 1:1:(num_of_nodes-center_node)
            NoR_z_points(row,(center_node-offset_from_center)) = NoR_z_points(row,(center_node-offset_from_center+1))-IL(row); %= (um) - (um) Note: node length is already accounted for in IL
            NoR_z_points(row,(center_node+offset_from_center)) = NoR_z_points(row,(center_node+offset_from_center-1))+IL(row); %= (um) + (um) Note: node length is already accounted for in IL
        end
    end
    
    %OUTPUT: NoR_z_points is a [num_of_random_axons x num_of_nodes]
    %matrix where the nodes of ranvier are for each randomly positioned fiber
    
    
    %------------------------------------------------------------------
    %determine the z coordinates of 10 points
    %between the nodes of ranvier because the model has 10 myelin
    %compartments between nodes.  HOWEVER, some of these values are
    %fixed from McIntyre et al (2002).
    %Paranode1 (MYSA) = 3.  This is the myelin that abuts the node.
    %Paranode2 (FLUT) = 2.5811*(fiberD)+19.59.  This is the myelin
    %between paranode1 and the main segment of myelin in the center of
    %the internode.
    %Internode = (IL-nodelength-(2*paralength1)-(2*paralength2))/6
    %This is the section in the center of the internode.
    %NOTE: access points in NEURON are at (0.5), so I step 1/2
    %distances
    %------------------------------------------------------------------
    myelin_z_points = [];
    
    for row=1:total_axons
        for node_point = 1:1:(num_of_nodes-1)
            
            node_z_location = NoR_z_points(row,node_point); %this is at the center of the node
            node_distance = IL(row); % (um)
            
            paralength1 = 3;
            paralength2 = 2.5811*(random_diameters(row))+19.59;
            internode_step = (IL(row)-node_length-(2*paralength1)-(2*paralength2))/6;
            
            minstep = node_z_location+node_length/2;
            
            for myelin_points = 1:1:10
                
                
                %For Paranode1a, just after a node
                if (myelin_points == 1)
                    myelin_z_points(row,((node_point-1)*10+myelin_points)) = minstep + paralength1/2;  %(um)
                end
                
                %For Paranode2a, just after Paranode1
                if (myelin_points == 2)
                    myelin_z_points(row,((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2/2; %(um)
                end
                
                %For 6 compartments of internode between Paranode2a and
                %Paranode2b
                if (myelin_points > 2 && myelin_points < 9)
                    myelin_z_points(row,((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + (internode_step*(myelin_points-3)) + internode_step/2;  %(um)
                end
                
                %For Paranode2b, just after the internode compartments
                if (myelin_points == 9)
                    myelin_z_points(row,((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + internode_step*6 + paralength2/2;  %(um)
                end
                
                if (myelin_points == 10)
                    myelin_z_points(row,((node_point-1)*10+myelin_points)) = minstep + paralength1 + paralength2 + internode_step*6 + paralength2 + paralength1/2;  %(um)
                end
            end
        end
    end
    %OUTPUT: myelin_z_points is a [num_of_random_axons x (num_of_nodes*10)]
    
    
    %------------------------------------------------------------------
    %Build a z_matrix for all coordinates: nodes of Ranvier
    %and the 10 myelin points between each node for each randomly
    %placed axon
    %------------------------------------------------------------------
    all_z_points = [];
    all_z_points = [NoR_z_points,myelin_z_points];
    all_z_points = sort(all_z_points,2,'ascend');
    
    %OUTPUT: all_z_points is a [num_of_random_axons x
    %num_of_nodes+(num_of_nodes*10)] matrix of all the z locations
    %where I need voltages to apply them to the model
    %------------------------------------------------------------------

    
    %save info
    AxonPositionsRelativeToCenter.(['Endo' num2str(temp_fascicle)]).Z=all_z_points;
    
    
end %end temp_fascicle loop

%eval(['save ' '''' '../../../' Model '/AxonLocations/AllModels.mat' '''' ' AxonPositionsRelativeToCenter']);
eval('save (''AxonPositionsRelativeToCenter.mat'', ''AxonPositionsRelativeToCenter'')'); % PVL mod.


