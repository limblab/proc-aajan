% This is a modified version of the MRG_COMSOL_Runner code which
% quickly takes in the voltages you want to input and outputs the axons
% that activated

% %this helps keep functions where they should be is all
% addpath('./COMSOL_Modeling/');
%this line adds the superdirectory to the path
addpath('../');

%note that, as the function below is coded, the csv file must be in that
%folder relative to the root folder. Specifically: "\COMSOL modeling\106Specific\NW File\"

%% This section should only be run once every long time. It takes about 4 minutes to run
%VERY SLOW, WATCH OUT
%here we will create a large read in file of the form X, Y, Z, Voltage with
%a depth of the number of contacts (15 for a FINE)
p = '/Users/aajanquail/Desktop/Jupyter_Notebooks/Miller_Lab/FINE Project/PNS_Modeling_Toolbox-main/COMSOL_Modeling/106Specific/NW File/'
template_voltages = [];
for i = 1:15
    vTemp = csvread(pwd+sprintf("contact%i.csv", i));
    vTemp = table( vTemp(:,1), vTemp(:,2), vTemp(:,3), vTemp(:,4) );
    vTemp = sortrows(vTemp, [1 2 3]);
    vTemp = table2array(vTemp);
    template_voltages = cat(3, template_voltages, vTemp);
end 


%% here we call the main function that provides the template voltages along each axon
tic
Vext = [];
%COULD BE CHANGED DURING SHIFTING
center_z_pos = 0.02;

%this must be manually chosen
polygon_file = "106_ulnar.mphtxt";
axons_per_fascicle = 100;
%[ Vext, axonXPositions, axonYPositions, axonDiameters ] = interpolate_voltages_generic_3dField_COMSOL_single_diameter( template_voltages, center_z_pos, polygon_file, axons_per_fascicle, 10 );
[ Vext, axonXPositions, axonYPositions, axonDiameters ] = interpolate_voltages_generic_3dField_COMSOL( template_voltages, center_z_pos, polygon_file, axons_per_fascicle );

toc
%% This section is very fast and can esily be run over and over
% Any script you make will run something similar to this over and over


%A vector that has the values of how many mA are being put in each contact,
%first 8 values are the bottom side where we have 8 contacts from right to
%left. Always numbered right to left
%contactWeights = [0 0 0 0  1 0 0 0 0  0 1 0 0 0];
contactWeights = [0 0 0.5 0  1 0 0 0 0  0 1 0 1 0 0];

%efficient way to sum all contact weights to create a final voltage on each
%axon based on the contact weights
final_axon_voltage = squeeze(sum(bsxfun(@times, Vext, reshape(contactWeights,[1 1 length(contactWeights)])),3));

%This is primarily for graphing
axons = size(final_axon_voltage,1); 

%2nd value is PW is us
%factor of 1000 is to make it in mV
[AP] = Matlab_Izad_2021(final_axon_voltage.*-1000, 50);



%% Graphing section

%Graphs a surface showing the second spatial difference of the voltage
%along axons. This is a correlate to axon activation
%close('all');
figure(1)
PlotSecondSpatialDifference(final_axon_voltage.*-1000, axonXPositions, axonYPositions, polygon_file);

%Note, right now contact 1 is the bottom right of the image


f2 = figure(2);
%This just resizes and positions the figure so it makes more sense with the
%geometry of the nerve to a person
 f2.Position =  [500 200 1300 520];
 hold on;
%This provides an overlay for the data so we can see fascicle borders
I = imread(pwd+"/106Specific/"+"MatlabSizedUlnar.png"); 
 imagesc([-0.0037 0.0035],[0.0012 -0.0014],I); 

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

scatter(nonActivatedXPositions, nonActivatedYPositions, 20,'blue' );

hold off

title 'Axon Positions and Firing'
