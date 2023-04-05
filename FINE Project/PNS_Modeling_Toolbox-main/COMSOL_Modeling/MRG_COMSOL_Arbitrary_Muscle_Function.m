function [ percentageMmActivation ] = MRG_COMSOL_Arbitrary_Muscle_Function( AP, mmGroups  )

%INPUT
%   AP:         An array of size of the number of axons with a zero where
%               no AP (action potential) chappens and a non-zero number where APs do happen.
%
%   mmGroups:   An array of structs which each contain a single element
%               (called axons) which indicates which axons are associated with each muscle

%OUTPUT
%   percentageMmActivation: An array which is the size of mmGroups. It
%                           indicates a percentage activation for all muscle groups 


%instantiating all of the muscle group activations
muscleActivations = zeros(length(mmGroups),1);

%checks all axons for the particular muscle group it belongs to and
%increments a value for the number of axons in each group 
for i = (1:length(AP))    
    for j = (1:length(mmGroups))
        if (AP(i)>0 && ismember(i, mmGroups(j).axons))
           muscleActivations(j) = muscleActivations(j) + 1;        
        end
    end
end

%now making activation proportional to the number of axons in each
%predefined muscle group that was input
percentageMmActivation = zeros(length(mmGroups),1);
for i = (1:length(mmGroups))
    percentageMmActivation(i) = muscleActivations(i) / length(mmGroups(i).axons);
end


end
