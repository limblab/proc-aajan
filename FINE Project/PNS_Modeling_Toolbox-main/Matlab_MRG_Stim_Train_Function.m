function [ output ] = Matlab_MRG_Stimulus_Function_Example( t,PAfuncArgs,Vext )
% This is an example of a stimulation function that can be used with Matlab_MRG_2019
% Every frame, Matlab_MRG_2019 passes the stimulation function the current simulation time (in ms),
% anything you told Matlab_MRG_2019 the function will need, and a cell
% structure with the external voltages to apply.
%
% Inputs: 
% t: current time in simulation (us)
% PAfuncArgs: Whatever this function needs to operate
% Vext: cells of voltages that you may want to apply. Must be NODES X AXONS
% Ex: Vext{1} = -50*ones(221,15); % 15 axons, 21 NoR, -50 mV applied.
%
% Outputs:
% An array of size NODES X AXONS describing how the external voltage
% changed.
if (nargin<2)
    disp('stim func fail')
end

% In this example, there's 1 external voltage you want to apply

% 1. We are going to assume that PAfuncArgs contains {PA, PW, Onset (in ms)}
% So 'StimData.PAfuncArgs = {1,250,1000};
% In principle, you can pass whatever you want - arrays would be more
% useful if you have something complicated, like a biomimetic pattern ;)
%
% Vext{1} ais the voltage from your contact. Shape is Nodes x Axons

%% interpret
PA1 = PAfuncArgs{1};
PW1 = PAfuncArgs{2};
Onset1 = PAfuncArgs{3};
TimeBetweenPulses = PAfuncArgs{4};
%value for the second pulse
Onset2 = Onset1+TimeBetweenPulses;
%% initiate
output=zeros(size(Vext{1})); % default output says we've applied a voltage of '0', everywhere
tempout=0;
Balance_Time = 2; % for a 1:1 stim:charge balance time use '1', for 1:10 use '10'
%% C1 Block pulse
if (t>Onset1 && t <Onset1+PW1) % C1 
    output = output + PA1 * Vext{1};
elseif (t>Onset1+PW1 && t <Onset1+(Balance_Time+1)*PW1) % c1 charge balance over 10x
    output = output - PA1 * Vext{1}/Balance_Time;
elseif (t>Onset2 && t <(Onset2+PW1))
    output = output + PA1 * Vext{1};
elseif (t>(Onset2+PW1) && t <(Onset2+(Balance_Time+1)*PW1))
    output = output - PA1 * Vext{1}/Balance_Time;
end



%% conclude
 output = output + tempout;
