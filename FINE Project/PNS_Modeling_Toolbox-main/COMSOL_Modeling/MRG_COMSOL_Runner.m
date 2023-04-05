% This is a modified version of the MRG_COMSOL_Runner code which
% quickly takes in the voltages you want to input and outputs the axons
% that activated

% %this helps keep functions where they should be is all
% addpath('./COMSOL_Modeling/');
%this line adds the superdirectory to the path
addpath('../');

fiberD = 10; %um, only diameters of 4um to 16/14um
tStep = 5; % in us
passive = 0; % If '1', Passive components only - no gate behavior
time_in_US = 3*10^3; % 3 ms simulation time, in us

%note that, as the function below is coded, the csv file must be in that
%folder relative to the root folder. Specifically: "\COMSOL modeling\106Specific\NW File\"

%% This section should only be run once every long time. It takes about 4 minutes to run
%VERY SLOW, WATCH OUT
%here we will create a large read in file of the form X, Y, Z, Voltage with
%a depth of the number of contacts (15 for a FINE)
template_voltages = [];
%Note that the indicies of the for loop vary based on the cuff you test
for i = 1:16
%    vTemp = csvread(pwd+"\106Specific\NW File\"+sprintf("contact%i.csv", i));
     vTemp = csvread(pwd+"\109Specific\"+sprintf("contact%i.csv", i));
    vTemp = table( vTemp(:,1), vTemp(:,2), vTemp(:,3), vTemp(:,4) );
    vTemp = sortrows(vTemp, [1 2 3]);
    vTemp = table2array(vTemp);
    template_voltages = cat(3, template_voltages, vTemp);
end 


%% here we call the main function that provides the template voltages along each axon
tic
Vext = [];
center_z_pos = 0.02;
%center_z_pos = 0.0065;
%subject must be manually chosen 
%polygon_file = "106_ulnar.mphtxt";
polygon_file = "109Median.mphtxt";

axons_per_fascicle = 100;
[ Vext, axonXPositions, axonYPositions, axonDiameters ] = interpolate_voltages_generic_3dField_COMSOL_single_diameter( template_voltages, center_z_pos, polygon_file, axons_per_fascicle, fiberD );
toc
%% This section is very fast and can esily be run over and over
% Any script you make will run something similar to this over and over


%A vector that has the values of how many mA are being put in each contact
contactWeights = [0.5 0.5 0.5 0.5 0.5 0.5 0.5 0 0 0.0 0.0 0 0 0 0 -7]/50;
%efficient way to sum all contact weights to create a final voltage on each
%axon based on the contact weights
final_axon_voltage = squeeze(sum(bsxfun(@times, Vext, reshape(contactWeights,[1 1 length(contactWeights)])),3));

%This is primarily for graphing
axons = size(final_axon_voltage,1); 

% tic



% %a required struct for the MRG function below
% %this factor of 1000 is inserted because the voltage data is in V, but the
% %function uses mV
% StimData.PAfunc = @Matlab_MRG_Stimulus_Function_Example;
% StimData.PAfuncArgs = {-1000 100 500}; % PA of '1', 50us PW, start at 1 ms.

%     %TEMP
%     StimData.PAfunc = @Matlab_MRG_Stim_Train_Function;
%     StimData.PAfuncArgs = {-1000 50 1000/2 300};

%     %TEMP
      StimData.PAfunc = @Matlab_MRG_Sinusoidal_Function;
      StimData.PAfuncArgs = {-1000 50 1000/2 300};


%setting the field to be applied for the given time
StimData.Vext{1} = final_axon_voltage';

%have to loop because whenever MRG is called it wants a diameter
MRGAP = [];
tic
[AP2,Vm,NA_Store,NA_H_Store,NA_M3_Store,K_Store,NAP_Store,VUPPERStore] =  Matlab_MRG_2019(axons,time_in_US,fiberD,tStep,passive,StimData);
toc
AP = AP2;



%% Graphing section

% Section for graphing the voltage across a single particular axon
figure(1);

%making a 3d array that shows a single axon through time into a 2d array
%that can be graphed
%by changing this 1 to any number between 1 and number of axons, we can look at
%different axons
tempV = reshape(Vm(:,10,:), [221, 600]);
s = surf(tempV);
s.EdgeColor = 'none';
title 'Single axon'
xlabel 'time(AU)'
ylabel 'node'
zlabel 'voltage(mV)'

%Graphing of the entire nerve cross section and the associated firing

f2 = figure(2);
%This just resizes and positions the figure so it makes more sense with the
%geometry of the nerve to a person
f2.Position =  [500 200 1300 520];
hold on;
%This provides an overlay for the data so we can see fascicle borders

%for 106
% I = imread(pwd+"\106Specific\"+"MatlabSizedUlnar.png");
% imagesc([3.8e-3 10.9e-3],[0.475e-3 -2.2e-3],I);
%for 109
I = imread(pwd+"\109Specific\"+"109Median.png");
imagesc([-0.0059 0.0060 ],[ 0.0016 -0.0014],I); 

hold on;
activatedXPositions = [];
activatedYPositions = [];
nonActivatedXPositions = [];
nonActivatedYPositions = [];

for i = (1:axons)
    if (AP(i)>0)
        activatedXPositions = [activatedXPositions; axonXPositions(i)];
        activatedYPositions = [activatedYPositions; axonYPositions(i)];
    else
        nonActivatedXPositions = [nonActivatedXPositions; axonXPositions(i)];
        nonActivatedYPositions = [nonActivatedYPositions; axonYPositions(i)];
    end
end


scatter(activatedXPositions, activatedYPositions, 20,'red' );
hold on;
scatter(nonActivatedXPositions, nonActivatedYPositions, 20,'blue' );

hold off

title 'Axon Positions and Firing'

