% Okay, 
% This script assumes
% 1. You've generated an .sm2, either through nerve tracing or through
% Simple_Fascicle_Maker
% 2. You've run 'process_sm2_2019', which has told maxwell where to grab
% voltage data from, what cuff parameters you want, and has auto-run
% maxwell
% 3. You now want to use the model voltages

% After running this script, Model Outputs folder will contain
% FascicleDescriptions.mat
% AxonPositionsRelativeToCenter.mat
% Interpolated Voltages folder

% *******************
% Note: Run this script from its directory.
% And customize 'Part 1' below
% ********************


%% Part 0. setup. don't mess with.
addpath(genpath(pwd))
mkdir ([pwd, '\Model Outputs'])
My_Dir = pwd;

%% Part 1. Position axons and interpolate voltages. feel free to customize
% There are two options for positioning axons
cd ([pwd '\Intermediate Outputs'])
Axons = 100;


% Position_Axons_Random_2019(Axons)
% Interpolate_Voltages_Random_2019


Position_Axons_Grid_Diam_Offset_2019(Axons)
Interpolate_Voltages_Random_2019

cd (My_Dir)


%% Part two. Move files around
% movefile ('ExportLocations','Intermediate Outputs')
movefile ('Intermediate Outputs\InterpolatedVoltages','Model Outputs')
copyfile ([pwd '\Intermediate Outputs\FascicleDescriptions.mat'], 'Model Outputs')
copyfile ([pwd '\Intermediate Outputs\AxonPositionsRelativeToCenter.mat'], 'Model Outputs')
