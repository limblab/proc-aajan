function axon_activated = PetersonResponse(vA1,Diameters,PW,all_threshold,w_node_mat,PWthreshold)

%This script is a modification of 'PetersonSingleResponse'
% Prereqs:
% 1. Axon positions in positionaxons.m (As made by FastInterpModSimplePositionAxons.m)
% 2. voltages exported from maxwell, then interpolated by SimpleInterpVoltages
% 3. node_weights, fascicleDescriptions, data_weights, AxonPositions, all_threshold_3d all preloaded/computed and passed as args.
% based on scripts by Matt Schiefer, Emily Graczyk, Eric Peterson

%CalculatePopulationResponse() uses the interpolated voltages from
%InterpVoltages() to find the population response to stimulation.
%UPDATED: 11 May 2010
%WRITTEN BY: Matthew Schiefer, Ph.D.
% Modified 2/25/16 PVL
% Further modified 3/4/16 to use Emily's version of the peterson
% Finalized 12/x/16
% Last comment:
% I've checked this many times and find nothing wrong with the script
% PW based recruitment does not appear to be monotonic. 

% if (min(min(vA1))<-500)
%     disp('Peterson not supported for this voltage')
% end

vA1=vA1'; % Emily's code needs voltages in rows
d2Ve= diff(vA1,2); %calculate 2nd difference along rows
nodenum=size(d2Ve,1)*size(d2Ve,2); %number of nodes in all axons for all fascicles
nAxons=size(d2Ve,2); %total num of axons

%             d2Ve_mat=repmat(d2Ve,19,1);
%             d2Ve_final=reshape(d2Ve_mat,19,nodenum)';
%
%             % Diameter is now given by diameter_range(DiameterIndex)
%             toe=cat(1,w_node_mat{(Diameters-3)*ones(1,nAxons)});
%
%             toed2Ve=toe.*d2Ve_final; %element by element multiplication - then sum across the rows - to get a col vector
%             MDF2temp=sum(toed2Ve,2);
%             MDF2=reshape(MDF2temp,19,nAxons); % There was a bug here. guessing left side is MDF2

% 12/7/16 PVL just going for a loop. will optimize later
% Further comment: The most expensive line, by far, is threshold
% interpolation. There is virtually no benefit in optimizing other parts of
% this script.
for j = 1:nAxons
    MDF2(:,j) = w_node_mat{Diameters(j)-3} * d2Ve(:,j);
end


for j=1:nAxons % find thresholds for these voltages
    th_axon = PWthreshold(:,:,Diameters(j)-3);
    th_nodes(:,j)=interp1(-1*all_threshold.ves,th_axon,vA1(2:20,j),'linear');
end

node_aboveth = MDF2-th_nodes;
[~,actIndices] = find((node_aboveth)>0);
actIndices = unique(actIndices); %This line is too expensive
axon_activated=zeros(1,nAxons);
axon_activated(actIndices) = 1; %store which nodes are active
end



