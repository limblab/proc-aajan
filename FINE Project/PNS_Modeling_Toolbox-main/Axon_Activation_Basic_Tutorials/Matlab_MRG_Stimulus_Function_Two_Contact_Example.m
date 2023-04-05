function [ output ] = Matlab_MRG_Stimulus_Function_Two_Contact_Example( t,PAfuncArgs,Vext )
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

% In this example, we have 2 Vexts that we want to apply at the same time.
% Practically, this comes up if you want to stimulate two different
% contacts at different levels, or at different times, or whatever.

% 1. We are going to assume that PAfuncArgs contains two PA values, two PW
% values, two onset times.
% So 'StimData.PAfuncArgs = {1,250,1000,0.2,300,1200};'
% In principle, you can pass whatever you want - arrays would be more
% useful if you have something complicated, like a biomimetic pattern ;)
%
% Vext{1} and Vext{2} will be the two voltages from two contacts. These are
% provided outside of PAfuncArgs because Matlab_MRG_2019 needs them to
% build the model. (and for consistency).

%% interpret
PA1 = PAfuncArgs{1};
PW1 = PAfuncArgs{2};
Onset1 = PAfuncArgs{3};

PW2 = PAfuncArgs{4};
PAs2 = PAfuncArgs{5};
Onsets2 = PAfuncArgs{6};

%% initiate
output=zeros(size(Vext{1})); % default output says we've applied a voltage of '0', everywhere

%% C1 Block pulse
if (t>Onset1 && t <Onset1+PW1) % C1 
    output = output + PA1 * Vext{1};
end
if (t>Onset1+PW1 && t <Onset1+(11)*PW1) % c1 charge balance over 10x
    output = output - PA1 * Vext{1}/10;
end

%% C2 Block pulse

if (t>Onset2 && t <Onset2+PW2) % C1 
    output = output + PA2 * Vext{2};
end
if (t>Onset2+PW1 && t <Onset2+(11)*PW2) % c1 charge balance over 10x
    output = output - PA1 * Vext{2}/10;
end


%% conclude
 output = output + tempout;
