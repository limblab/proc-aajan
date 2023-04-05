%% Each section here contains an example.

%this line adds the superdirectory to the path
% IT IS NEEDED FOR ANY SECTION BELOW TO RUN
addpath('../');

%% 1. Single Axon, Artificial Stim.
% Matlab_MRG_2019 (axons,time_in_US,fiberD,tStep,passive,StimData)

axons = 1;
time_in_US = 3*10^3; % 3 ms simulation time, in us
fiberD = 10; % 10 um
tStep = 5; % in us
passive = 0; % If '1', Passive components only - no gate behavior

% Build StimData
StimData.PAfunc = @Matlab_MRG_Stimulus_Function_Example;
StimData.PAfuncArgs = {5 25 1000}; % PA of '1', 250us PW, start at 1 ms.

V_Field = zeros(221, axons); % Artificial external voltage field. NODES X AXONS
V_Field (10*11+1, axons)  = -50; % with a -50mv poke in the middle.
StimData.Vext{1} = V_Field; % 

[AP,Vm,NA_Store,NA_H_Store,NA_M3_Store,K_Store,NAP_Store,VUPPERStore] =  Matlab_MRG_2019(axons,time_in_US,fiberD,tStep,passive,StimData);

s = surf(Vm);
s.EdgeColor = 'none';
title 'Single Contact, -50mv pulse '

%% 2. 10 Axons, Variable Fields. Artificial Stim. 
% Matlab_MRG_2019 (axons,time_in_US,fiberD,tStep,passive,StimData)

axons = 10;
time_in_US = 3*10^3; % 3 ms simulation time, in us
fiberD = 10; % 10 um
tStep = 5; % in us
passive = 0; % If '1', Passive components only - no gate behavior 

% Build StimData
StimData.PAfunc = @Matlab_MRG_Stimulus_Function_Example;
StimData.PAfuncArgs = {1 250 1000}; % PA of '1', 250us PW, start at 1 ms.

V_Field = zeros(221, axons); % Artificial external voltage field. NODES X AXONS
V_Field (10*11+1, :)  = 80:-20:-100; % with a positive...negative poke in the middle (anodic...cathodic)
StimData.Vext{1} = V_Field; % 

[AP,Vm,NA_Store,NA_H_Store,NA_M3_Store,K_Store,NAP_Store,VUPPERStore] =  Matlab_MRG_2019(axons,time_in_US,fiberD,tStep,passive,StimData);

f = figure;
for i = 1:10
    subplot(2,5,i)
    s = surf(squeeze(Vm(:,i,:)));
    s.EdgeColor = 'none';
    title ([num2str(100-i*20),' mv pulse'])
end

% -20mv is the textbook case.
% Notice how for the positive external voltage (anodic stim), activation is
% actually starting at the side lobes. This depends on the stim shape -
% we're doing something very pointy, so you'll see this for a big PA range.
% Also, see how things are getting really weird for the strong negatives
% (cathoidc stim)? The H gates are getting shut down very fast. If you
% change the charge balance to 1:10 you won't actually see an AP in the
% -100mv case. The AP is actually happening from 'anodic break' on
% the side lobes: the 

%% 3. 100 Axons, Simulated. Uses Example MXWL Modeling output voltages. Takes ~3 minutes!

addpath(genpath(pwd))
clc
clear all
close all
drawnow()
a = tic;
mydir = pwd;
cd ([pwd, '\MXWL modeling\Example MXWL Modeling output'])

% get information on nerve layout
load('FascicleDescriptions.mat')
load('AxonPositionsRelativeToCenter.mat')
X = AxonPositionsRelativeToCenter.Endo1.X;
Y = AxonPositionsRelativeToCenter.Endo1.Y;
axons = length(X);

% get information on voltages
Contact = 1; % We'll just be looking at contact 1.
load ([pwd, '\InterpolatedVoltages\InterpolatedVoltagesContact', num2str(Contact),'.mat' ])

% Alright, now we are using voltages and axon positions that were generated
% by Position_Axons_Grid_Diam_Offset_2019, which you can tell by
% AxonPositionsRelativeToCenter.Endo1.Z not existing - each fiber has not
% been limited to a diameter; instead we can play with that here.
% This means that first we need to determine which voltage field indices to
% use.

figure(1); % plot which axons fire


for DiamInd = 1:6
    Diameter = AxonPositionsRelativeToCenter.Diameter_Range(DiamInd+4); % we want to look at some of the larger axons
    Offset = AxonPositionsRelativeToCenter.Offset_Range(1); % and we're going with no offset.
    Inds = AxonPositionsRelativeToCenter.Diameter_Offset_Indices{find(AxonPositionsRelativeToCenter.Diameter_Range==Diameter),find(AxonPositionsRelativeToCenter.Offset_Range==Offset)}; % find which indices that corresponds to;
    
    % Get the voltages you want
    Endo = 1;
    V_Applied = InterpolatedVoltages.(['Endo',num2str(Endo)])(1:axons,[Inds(1):Inds(2)]);
    
    % Set MRG parameters
    time_in_US = 3*10^3; % 3 ms simulation time, in us
    fiberD = Diameter; % 10 um
    tStep = 5; % in us
    passive = 0; % If '1', Passive components only - no gate behavior
    
    % Build StimData
    StimData.PAfunc = @Matlab_MRG_Stimulus_Function_Example;
    StimData.PAfuncArgs = {80 250 1000}; % Nominal PA of '80' gives us a reasonable kick, 250us PW, start at 1 ms.
    
    V_Field = V_Applied'; % external voltage field. NODES X AXONS
    StimData.Vext{1} = V_Field; %
    
    [AP,Vm,NA_Store,NA_H_Store,NA_M3_Store,K_Store,NAP_Store,VUPPERStore] =  Matlab_MRG_2019(axons,time_in_US,fiberD,tStep,passive,StimData);
    
    
    % Draw xsection of nerve and mark active
    
    figure(1)
    subplot(2,3,DiamInd)
    RGB = [0,0,1]'*ones(1,axons); % start at purple for all axons
    RGBmod = zeros(size(RGB));
    if (max(AP)>0)
        RGBmod(3,AP>0)=-1;
        RGBmod(1,AP>0)=1;
    end
    scatter(X(1:axons),Y(1:axons),20,(RGB+RGBmod)')
    hold on
    line(1000*Fascicles.Endo1.Vertices(:,1),1000*Fascicles.Endo1.Vertices(:,2))
    title (['activity for ',num2str(Diameter), ' um fiber'])
    drawnow()

end

cd (mydir)
toc(a)
% Useful for debug
% max(max(max(Vm)))
% s = surf(Vm(1:11:end,:));
% s.EdgeColor = 'none';

