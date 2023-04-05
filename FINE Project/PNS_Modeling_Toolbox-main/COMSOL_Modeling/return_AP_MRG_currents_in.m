function [ activation ] = return_AP_MRG_currents_in( inputCurrents, diameter  )

%INPUT:     inputCurrents:  A vector with elements equal to the number of
%                           contacts being used in the electrode. Each
%                           value is the current in mA.
%           diameter:       The diameter of the fiber being stimulated in
%                           um

% OUTPUT:   activation:     an array with elements equal to the number of
%                           fibers. Non-zero if an activation happened

fiberD = diameter; %um, only diameters of 4um to 16/14um
tStep = 5; % in us
passive = 0; % If '1', Passive components only - no gate behavior
time_in_US = 3*10^3/4; % 3 ms simulation time, in us

%note that, as the function below is coded, the csv file must be in that
%folder relative to the root folder. Specifically: "\COMSOL modeling\106Specific\NW File\"
VextMatrix = zeros(114,221,10);
for i = 1:10
    %This function applies the COMSOL voltages to the axons in a form that
    %the MRG model can read appropriately given the fiber diameter (see
    %function for many details)
    [VTemp, ~, ~] = external_voltage_interpolated_for_diameter(sprintf("NW_Contact%iV.csv", i), 0.00636104, fiberD);
    VextMatrix(:,:,i) = VTemp;
end    

%voltages linearly superimpose from currents and the base field is for ~1mA
%A vector that has the values of how many mA are being put in each contact
contactWeights = inputCurrents;

% Loop which incorporates each contact current into the final voltage field
% that an axon is experiencing
Vext = contactWeights(1).*VextMatrix(:,:,1);
for i = 2:length(contactWeights)
    Vext = Vext + contactWeights(i).*VextMatrix(:,:,i);
end

axons = size(Vext,1); %the function must know how many axons are being given beforehand

%a required struct for the MRG function below
StimData.PAfunc = @Matlab_MRG_Stimulus_Function_Example;

%this factor of 1000 is inserted because the voltage data is in V, but the
%function uses mV
StimData.PAfuncArgs = {-1000 25 1000/8}; % PA of '1', 25us PW, start at 1 ms.
%setting the field to be applied for the given time
StimData.Vext{1} = Vext';

[AP,~,~,~,~,~,~,~] =  Matlab_MRG_2019(axons,time_in_US,fiberD,tStep,passive,StimData);

activation = AP;



end
