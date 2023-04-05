function [AP] = Matlab_Izad_2021(Vext, PW)
%all information for creating this function can be found in Izad's master's
%thesis:
%https://etd.ohiolink.edu/apexprod/rws_etd/send_file/send?accession=case1232751033&disposition=inline

%INPUT
% Vext: The external voltage field in mV
%       The external voltage is in form Axons X NodeVoltages
% PW:   Pulsewidth being used in us, it is converted to ms (divide by 1000)

%OUTPUT
% AP:   A boolean array that indicates which of the axons fired according to its
%       location by the index

%the equations are made to use ms, that was the issue
PW = PW/1000;

%the voltages at all of the nodes of ranvier only. These are what matter
%for the Izad method
nodeVoltages = Vext(:, 1:11:end)';

%equations 2.2, 2.9-2.13 in the link above, ~page 45 of the pdf
%parameter values are not what is cited in the paper, this is odd,
%they are values created on a later date to account for longer pulse widths
% alpha = 307.66 + 0.5577/PW;
% mu    = exp( 76.211 * PW^2 - 29.746 * PW + 4.5111);
% beta  = 1/PW;
% nu     = 1000;


%pages 48 and 49 of the pdf give the real values
%times are in ms, PW is in us, need make PW ms
alpha   =   (280-670)*exp(-(PW/1000)/0.457)+670;
mu      =   1/(   1/2.998 + (1/3.001-1/2.998)*exp(-(PW/1000)/0.457)     );
beta    =   0.001*(1+882/(PW/1000) );
nu      =   1000;


%equation (2.2) for use with equation (2.14) in the paper linked above
f  = alpha * exp(nodeVoltages./mu) + beta * exp(nodeVoltages./nu);

% This calculates the second spatial derivative
D2V = diff(nodeVoltages,2);
% This is equation (2.14)
chi = D2V-f(2:end-1,:);

%All this is saying is that if the value of the second spatial derivative
%is greater than the value of this double exponential function, f, then the
%axon should be firing 
AP = max(chi>0); %find either a 0 or a 1 in each row after checking each row for a value greater than zero

