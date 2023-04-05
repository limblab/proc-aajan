function [APResults,Vout,NA_Store,NA_H_Store,NA_M3_Store,K_Store,NAP_Store,VUPPERStore] = Matlab_MRG_2019 (axons,time_in_US,fiberD,tStep,passive,varargin)
% This mimics Neuron's behavior of the MRG
% In that it solves the next step by implicit Euler
% The MRG models nodes of ranvier, and 10 internodal segments between each
% pair of nodes of ranvier. You will need the voltage at each of these
% internodal segments to run this properly.

% INPUTS
% time input is in uS (ex: 20*10^3 for 20 ms)
% axons in axons
% fiberD in um.
% tStep in uS. 5 is a good number.
% passive is binary 1/0. If '1', no active behavior will be simulated
% varargin holds all information on external voltage and stimulation
% function to implement. It is complicated.
%   varargin must be a struct.
%   varargin must contain a '.Vext' field. '.Vext' must be a cell
%   containing arrays of size NODES X AXONS
%   ex: varargin.Vext{1} = zeros(221,15); % sets the external voltage field for
%   221 sub-nodal segments on 15 axons to '0'. 
%   It's okay to have multiple '.Vext' cells, but they have to have the same
%   size. Only the 1st is read to determine the number of sub-nodal
%   segments.
%    To set implement external voltage changes, you need to provide 
%       1. A pointer to a function.
%           ex: varargin.PAfunc = @Matlab_MRG_Stimulus_Function_Example.m
%       2. Things to pass to that function
%           ex: varargin.PAfuncArgs = {0,0,0,1000,StimTimes,StimArrs};
%       Every frame, PAfunc will be passed (T, PAfuncArgs, Vext). T is the
%       current time
%       Note that Vext is a cell, so you can pass multiple voltage arrays to your PAfunc 


% varargin - Vext,dPA,PA,PW, PWonset,  in a struct.
%  so temp.Vext, temp.dPA, temp.PA, temp.PW, etc.
% External activation params:
%   Vext - External voltage. node x axon 2d array
%     ... should be mostly negative, and in MILLIVOLTS
%   dPA - is the derivative of PA. This is for Vext, is a SPARSE time/tStep x axons array of change in pulse amplitude.
%     ...The dPA value, scaled by Vext, is subtracted from Vm.    
%   NOTE: dPA is defined by both pulse amplitude and pulse width
%   PAfunc -  A pointer to a function where PA is a function of t. This
%     script will handle dPA calculations if such a pointer is provided

% Outputs
% Tout - time component, in uS.
% Vout - voltage of [recording node] for each axon, in mV over time
% AP - time of first break-of-0-mV at [recording node]. in us
% The assumption is that it is far enough to not be affected by external
% voltage fields, so if it breaks 0mV this is due to a propagating wave.
% [Action potential is poorly defined. We'll go with self-propagating
% pattern]

%% Set time and such
tic

% tStep = 5; % in uS
SampleEvery = 1; % sample every 10 data points. Irrelevant if you just want binary fire/ no fire output
nodeRs = (size(varargin{1}.Vext{1},1)-1) / 11; % PVL 10/23/17 variable node size depending on input
VmStart = -80; % -80 is rest
nodes = 10*(nodeRs)+nodeRs+1; % nodes per axon. PVL 10/23/17 cap now included in previous number
RecordFrom = nodes; % we will record from the last node of Ranvier.

% MRG uses two layers of compartments. "Upper" and "Lower".
% The node and axoplasmic layers are in 'Lower'.
% The myelin and periaxonal layers are in "Upper".
VLower = VmStart*ones(nodes,axons); % voltages inside axon
VUpper = zeros(size(VLower)); % voltages under myelin layer
VSecond = zeros(size(VLower)); % voltages just outside myelin
VOuter = zeros(size(VLower)); % voltage source just outside VUpper2

AP = -1 * ones(nodes,axons); % stores first time that RecordFrom breaks zero.
APResults = zeros(1,axons); % stores final judgement on AP or not for axon.

%% Passed parameters
% dPA
if (isfield(varargin{1},'dPA'))% oddly enough, 'exist' doesn't work within cells
    dPA = varargin{1}.dPA;
    check_External_Voltage=1;
    disp('dPA format not supported after Nov 2017');
    return
elseif (isfield(varargin{1},'PAfunc')) % check voltage pointer
    PAfunc = varargin{1}.PAfunc;
    check_External_Voltage=1;
    if (isfield(varargin{1},'PAfuncArgs'))
        PAfuncArgs = varargin{1}.PAfuncArgs;
    else
        disp('function provided with no function args passed')
    end
else
    disp ('No Voltage Function pointer');
    disp ('External Voltage not being applied directly.');
    check_External_Voltage=0; % don't bother updating external voltage, it is never applied
end

if (isfield(varargin{1},'Vext'))
    Vext = varargin{1}.Vext;
%     if ( size(Vext,1)~=nodes || size(Vext,2)~=axons )         % sometimes you just want a constant external voltage (debug)
%         Vext = Vext(1) * ones(nodes,axons);
%         disp('External Voltage Not nodes x axons in size. using first value * ones')
%     end
%     if (max(max(Vext{1}))>0)
%         disp('POSSIBLE ERROR: External Voltage has positive components.'); % this is actually quite normal 
%     end
else
    check_External_Voltage=0; % don't bother updating external voltage, it is zero
    disp ('External Voltage Zero');
end

clear varargin; % No need to hold on to extra memory, and it is substantial.

%% Set values from MRG
paralength1=3;
nodelength=1.0;
space_p1=0.002;
space_p2=0.004;
space_i=0.004;
celcius=37;

xraxial_default = 1e9; % In megaohm-cm. quoting ted, to get resistance between 2 nodes: xraxial * L/nseg * 1e-4
xm_default = 1e9; % this one is conductance, actually.

rhoa=0.7e6; %//Ohm-um//
mycm=0.1; %//uF/cm2/lamella membrane//
mygm=0.001; %//S/cm2/lamella membrane//
%Transverse (vertical) capacitance, in uF/cm^2
Cn = 2; % nodal capacitance, uF/cm^2
Ci = 2; % internodal capacitance, uF.
gNAF = 3; % fast sodium
gK = 0.08;% slow potassium
gNAP = 0.01;% persistent sodium
gLK = 0.007; % leak
eNA = 50; % sodium Nernst
eNAP = eNA;
eK = -90; % potassium Nernst
eLK = -90; %Leakage reversal potential
eR = -80; % Rest potential

% From Peterson NEURON code
% /*
% Originally McIntyre had a number of if statements here such as:
% if (fiberD==5.7) {g=0.605 axonD=3.4 nodeD=1.9 paraD1=1.9 paraD2=3.4 deltax=500 paralength2=35 nl=80}
% In this version, these values are based equations.
% Relationships:
% 		g = 0.0172(FiberDiameter)+0.5076;    		R^2 = 0.9869
% 		AxonDiameter = 0.889(FiberDiameter)-1.9104;	R^2 = 0.9955
% 		NodeDiameter = 0.3449(FiberDiameter)-0.1484;	R^2 = 0.9961
% 		paraD1 = 0.3527(FiberDiameter)-0.1804;		R^2 = 0.9846
% 		paraD2 = 0.889(FiberDiameter)-1.9104;		R^2 = 0.9955
% 		deltax = 969.3*Ln(FiberDiameter)-1144.6;		R^2 = 0.9857
% 		paralength2 = 2.5811*(FiberDiameter)+19.59;	R^2 = 0.9874
% 		nl = 65.897*Ln(FiberDiameter)-32.666;		R^2 = 0.9969
% 
% The following equations are techniqually only good for fiber diameters between 5.7 and 16.0 because 
% the equations were determined (in Excel) to fit the data over that range only (y-intercept was not forced).
% Matlab randomly chooses fiber diameters and they can range from 3 to 16.  Diameters of 3, 4, or 5 may not result 
% in the correct values here.  
% 
% LATER NOTE: Diameters of 3 produce negatvie values for deltax.  Therefore, any fiber with a 3um diameter will be
% changed to a 4 um diameter fiber.
% */

if (size(fiberD,1)>size(fiberD,2)) % need this to be 1 x axons
    fiberD=fiberD';
end

g = 0.0172*(fiberD)+0.5076    		;%//??
axonD = 0.889*(fiberD)-1.9104  		;%//diameter of the axon
nodeD = 0.3449*(fiberD)-0.1484 		;%//diameter of the node
paraD1 = 0.3527*(fiberD)-0.1804		;%//diameter of paranode 1
paraD2 = 0.889*(fiberD)-1.9104 		;%//diameter of paranode 2
deltax = 969.3*log(fiberD)-1144.6	;%	//total length between nodes (including 1/2 the node on each side)
paralength2 = 2.5811*(fiberD)+19.59 ;%	//length of paranode2
nl = 65.897*log(fiberD)-32.666		;%//number of lamella

Rpn0=(rhoa*.01)./(pi*((((nodeD/2)+space_p1).^2)-((nodeD/2).^2)));
Rpn1=(rhoa*.01)./(pi*((((paraD1/2)+space_p1).^2)-((paraD1/2).^2)));
Rpn2=(rhoa*.01)./(pi*((((paraD2/2)+space_p2).^2)-((paraD2/2).^2)));
Rpx =(rhoa*.01)./(pi*((((axonD/2)+space_i).^2)-((axonD/2).^2)));
interlength=(deltax-nodelength-(2*paralength1)-(2*paralength2))/6;

% If FiberDiam is not specified
% fiberD = ones(1,axons);
% fiberD(1:9:end) = 5.70; % um
% %fiberD(1:9:end) = 15.0; % um
% if (axons>1) fiberD(2:9:end) =7.3; end
% if (axons>2) fiberD(3:9:end) =8.7; end
% if (axons>3) fiberD(4:9:end) =10.0; end
% if (axons>4) fiberD(5:9:end) =11.5; end
% if (axons>5) fiberD(6:9:end) =12.8; end
% if (axons>6) fiberD(7:9:end) =14.0; end
% if (axons>7) fiberD(8:9:end) =15.0; end
% if (axons>8) fiberD(9:9:end) =16.0; end

% Ion stuff
vtraub=-80;
bhA = 2.3;
bhB = 31.8;
bhC = 13.4;
asA = 0.3;
asB = -27;
asC = -5;
bsA = 0.03;
bsB = 10;
bsC = -1;
q10_1 = 2.2 ^ ((celcius-20)/ 10 );
q10_2 = 2.9 ^ ((celcius-20)/ 10 );
q10_3 = 3.0 ^ ((celcius-36)/ 10 );


%% Set Compartment specific values.
CompartmentLength = ones(size(VLower));
for n=0:nodeRs-1
    CompartmentLength(n*11+1,:)          = nodelength; % Nodes of ranvier have length of one
    CompartmentLength(n*11+2,:)          = paralength1; % MYSA is always 3uM
    CompartmentLength(n*11+3,:)          = paralength2; % FLUT is variable
    CompartmentLength(n*11+4:n*11+9,:)   = ones(6,axons)*interlength; % STIN is highly variable
%     CompartmentLength(n*11+4:n*11+9,:)   = kron(interlength,ones(6,1)); % STIN is highly variable PVL 05 26 2019 compat
    CompartmentLength(n*11+10,:)         = paralength2; % FLUT is variable
    CompartmentLength(n*11+11,:)         = paralength1; % MYSA
end
CompartmentLength(nodes,:) = nodelength; % last node of ranvier

CompartmentRa = ones(size(VLower)); % Axoplasmic resistivity ohm-cm
for n=0:nodeRs-1
    CompartmentRa(n*11+1,:)          = rhoa/10000; % Nodes
    CompartmentRa(n*11+2,:)          = rhoa*(1./(paraD1./fiberD).^2)/10000; % MYSA
    CompartmentRa(n*11+3,:)          = rhoa*(1./(paraD2./fiberD).^2)/10000; % FLUT
    CompartmentRa(n*11+4:n*11+9,:)   = ones(6,axons)*rhoa*(1./(axonD./fiberD).^2)/10000; % STIN
    CompartmentRa(n*11+10,:)         = rhoa*(1./(paraD2./fiberD).^2)/10000; % FLUT
    CompartmentRa(n*11+11,:)         = rhoa*(1./(paraD1./fiberD).^2)/10000; % MYSA
end
CompartmentRa(nodes,:) = rhoa/10000; % last node of ranvier

CompartmentDiam = ones(size(VLower));% Fiber diam
for n=0:nodeRs-1
    CompartmentDiam(n*11+1,:)          = nodeD; % Nodes
    CompartmentDiam(n*11+2,:)          = fiberD; % MYSA
    CompartmentDiam(n*11+3,:)          = fiberD; % FLUT
    CompartmentDiam(n*11+4:n*11+9,:)   = ones(6,axons)*fiberD; % STIN
    CompartmentDiam(n*11+10,:)         = fiberD; % FLUT
    CompartmentDiam(n*11+11,:)         = fiberD; % MYSA
end
CompartmentDiam(nodes,:) = nodeD; % last node of ranvier

CompartmentCm = ones(size(VLower));% specific capacitance. uF/cm^2
for n=0:nodeRs-1
    CompartmentCm(n*11+1,:)          = 2; % Nodes of ranvier
    CompartmentCm(n*11+2,:)          = 2*paraD1./fiberD; % MYSA
    CompartmentCm(n*11+3,:)          = 2*paraD2./fiberD; % FLUT
    CompartmentCm(n*11+4:n*11+9,:)   = ones(6,axons)*2*(axonD./fiberD); % STIN
    CompartmentCm(n*11+10,:)         = 2*paraD2./fiberD; % FLUT
    CompartmentCm(n*11+11,:)         = 2*paraD1./fiberD; % MYSA
end
CompartmentCm(nodes,:) = 2; % last node of ranvier

CompartmentG_Pas = ones(size(VLower));% Passive conductance outward. S/cm^2
for n=0:nodeRs-1
    CompartmentG_Pas(n*11+1,:)           = 0; % Nodes of ranvier
    CompartmentG_Pas(n*11+2,:)           = 0.001*paraD1./fiberD; % MYSA
    CompartmentG_Pas(n*11+3,:)           = 0.0001*paraD2./fiberD; % FLUT
    CompartmentG_Pas(n*11+4:n*11+9,:)    = ones(6,axons)*0.0001*(axonD./fiberD); % STIN
    CompartmentG_Pas(n*11+10,:)          = 0.0001*paraD2./fiberD; % FLUT
    CompartmentG_Pas(n*11+11,:)          = 0.001*paraD1./fiberD; % MYSA
end
CompartmentG_Pas(nodes,:) = 0; % last node of ranvier

CompartmentXRaxial = ones(size(VLower)); % Extracellular axial resistance
for n=0:nodeRs-1
    CompartmentXRaxial(n*11+1,:)         = Rpn0; % Nodes
    CompartmentXRaxial(n*11+2,:)         = Rpn1; % MYSA
    CompartmentXRaxial(n*11+3,:)         = Rpn2; % FLUT
    CompartmentXRaxial(n*11+4:n*11+9,:)  = ones(6,axons)*Rpx; % STIN
    CompartmentXRaxial(n*11+10,:)        = Rpn2; % FLUT
    CompartmentXRaxial(n*11+11,:)        = Rpn1; % MYSA
end
CompartmentXRaxial(nodes,:) = Rpn0; % last node of ranvier

CompartmentXg = ones(size(VLower)); % Extracellular outward conductance
for n=0:nodeRs-1
    CompartmentXg(n*11+1,:)          = 1e10; % Nodes of ranvier
    CompartmentXg(n*11+2,:)          = mygm./(nl*2); % MYSA
    CompartmentXg(n*11+3,:)          = mygm./(nl*2); % FLUT
    CompartmentXg(n*11+4:n*11+9,:)   = ones(6,axons)*(mygm./(nl*2)); % STIN
    CompartmentXg(n*11+10,:)         = mygm./(nl*2); % FLUT
    CompartmentXg(n*11+11,:)         = mygm./(nl*2); % MYSA
end
CompartmentXg(nodes,:) = 1e10; % last node of ranvier

CompartmentXc = ones(size(VLower));% Extracellular outward capacitance
for n=0:nodeRs-1
    CompartmentXc(n*11+1,:)          = 0; % Nodes
    CompartmentXc(n*11+2,:)          = mycm./(nl*2); % MYSA
    CompartmentXc(n*11+3,:)          = mycm./(nl*2); % FLUT
    CompartmentXc(n*11+4:n*11+9,:)   = ones(6,axons)*(mycm./(nl*2)); % STIN
    CompartmentXc(n*11+10,:)         = mycm./(nl*2); % FLUT
    CompartmentXc(n*11+11,:)         = mycm./(nl*2); % MYSA
end
CompartmentXc(nodes,:) = 0; % last node of ranvier

% The second external layer. Conductances outward, preceding external src
CompartmentXgSecond = ones(size(VLower)); % VExt[1] outward conductance
for n=0:nodeRs-1
    CompartmentXgSecond(n*11+1,:)          = xm_default; % Nodes of ranvier
    CompartmentXgSecond(n*11+2,:)          = xm_default; % MYSA
    CompartmentXgSecond(n*11+3,:)          = xm_default; % FLUT
    CompartmentXgSecond(n*11+4:n*11+9,:)   = xm_default; % STIN
    CompartmentXgSecond(n*11+10,:)         = xm_default; % FLUT
    CompartmentXgSecond(n*11+11,:)         = xm_default; % MYSA
end
CompartmentXgSecond(nodes,:) = xm_default; % last node of ranvier

% Second external layer. Resistances along length of axon
CompartmentXRaxialSecond = ones(size(VLower));% 
for n=0:nodeRs-1
    CompartmentXRaxialSecond(n*11+1,:)          = xraxial_default; % Nodes
    CompartmentXRaxialSecond(n*11+2,:)          = xraxial_default; % MYSA
    CompartmentXRaxialSecond(n*11+3,:)          = xraxial_default; % FLUT
    CompartmentXRaxialSecond(n*11+4:n*11+9,:)   = xraxial_default; % STIN
    CompartmentXRaxialSecond(n*11+10,:)         = xraxial_default; % FLUT
    CompartmentXRaxialSecond(n*11+11,:)         = xraxial_default; % MYSA
end
CompartmentXRaxialSecond(nodes,:) = xraxial_default; % last node of ranvier
%% Now we compute resistances and capacitances between compartments

AxoPlasmicResistance = CompartmentRa      .* 10^4 .* CompartmentLength ./ (pi .* (CompartmentDiam/2).^2); % Resistance of any individual compartment axonally
PeriaxonalResistance = CompartmentXRaxial .* 10^-2 .* 10^4 .* CompartmentLength ; %Resistance of any individual compartment extracellularly. multipliers return the RPN0-1-2 notation to ohm-um, and then accounts for dimensions
SecondLayerResistance = CompartmentXRaxialSecond.* CompartmentLength .* 10^4.* 10^-2 ; % same conversion as periaxonal

LowerConduct = 1./ ( (AxoPlasmicResistance(2:end,:)+AxoPlasmicResistance(1:end-1,:) )/2 );
UpperConduct = 1./ ( (PeriaxonalResistance(2:end,:)+PeriaxonalResistance(1:end-1,:) )/2 );
SecondConduct = 1./ ( (SecondLayerResistance(2:end,:)+SecondLayerResistance(1:end-1,:) )/2 );


gAxoplasmicPlus  = [LowerConduct;LowerConduct(end,:)]; % looking from every node "forward"
gAxoplasmicMinus = [LowerConduct(1,:);LowerConduct]; % looking from every node "back" into MYSA
gPeriaxonalPlus  = [UpperConduct;UpperConduct(end,:)];
gPeriaxonalMinus = [UpperConduct(1,:);UpperConduct];
gSecondPlus  = [SecondConduct;SecondConduct(end,:)];
gSecondMinus = [SecondConduct(1,:);SecondConduct];

cLower = CompartmentCm .* CompartmentLength .* pi .* CompartmentDiam .*10^-8;
cUpper = CompartmentXc .* CompartmentLength .* pi .* CompartmentDiam .*10^-8;

% Convert capacitances to Farad from uF
%  cLower = cLower * 10^-6;
%  cUpper = cUpper * 10^-6;

gLower = CompartmentG_Pas .* CompartmentLength .* pi .* CompartmentDiam.*10^-8;
gUpper = CompartmentXg .* CompartmentLength .* pi .* CompartmentDiam.*10^-8;
gSecond = CompartmentXgSecond.* CompartmentLength .*10^-8 .* pi .* CompartmentDiam; % Scaling by 1.1 somehow reduces error

% Node specific values. Will only be used in Node of Ranvier
NgNAF = gNAF .* CompartmentLength .* CompartmentDiam *pi .*10^-8; % fast sodium
NgK   = gK   .* CompartmentLength .* CompartmentDiam *pi .*10^-8;% slow potassium
NgNAP = gNAP .* CompartmentLength .* CompartmentDiam *pi .*10^-8;% persistent sodium
NgLK  = gLK  .* CompartmentLength .* CompartmentDiam *pi .*10^-8; % leak

% NgNAF = gNAF 
% NgK   = gK  
% NgNAP = gNAP 
% NgLK  = gLK  
% disp('stupid node conductances test')

%% Initialize channels and upper compartment voltages
% initialize M,N,H channels, staring at steady state for given Vm
MaNAP = q10_1 * vtrap1(VLower); % Persistent Na
MbNAP = q10_1 * vtrap2(VLower);
MaNA  = q10_1 * vtrap6(VLower);
MbNA  = q10_1 * vtrap7(VLower);
HaNA  = q10_2 * vtrap8(VLower);
HbNA  = q10_2 * bhA ./ ( 1 + Exp(-(VLower+bhB)/bhC) );
v2 = VLower - vtraub; % convert to traub convention
SaK = q10_3*asA ./ ( Exp( (v2+asB) /asC ) + 1) ;
SbK = q10_3*bsA ./ ( Exp( (v2+bsB) /bsC ) + 1);
% These are listed out in MRG. Presumably get solved with cnexp
mp_inf = MaNAP ./ (MaNAP + MbNAP);
m_inf = MaNA ./ (MaNA + MbNA);
h_inf = HaNA ./ (HaNA + HbNA);
s_inf = SaK ./ (SaK + SbK);

MNA  = m_inf; % M channel
HNA  = h_inf;

SK   = s_inf;% K values
MNAP = mp_inf;% persistent sodium

% External Voltage Structure. currently not in use
t = 0:tStep:time_in_US; % in uS

% Vmstore=Vm;
% Istore=[];
% MNAstore=[];
% HNAstore=[];
% SKstore=[];
% MNAPstore=[];
% ILKstore=[];


% storage arrays
INA = zeros(size(VLower));
IK = zeros(size(VLower));
INAP = zeros(size(VLower));
ILK = zeros(size(VLower));
cINA = zeros(size(VLower)); % temporary for dv/dt
cIK = zeros(size(VLower));
cINAP = zeros(size(VLower));
cILK = zeros(size(VLower));
deltaT = tStep; %  time step, in us to match the uF

V = zeros(size(VLower,1),size(VLower,2),floor(size(VLower,3)/SampleEvery));
V(:,:,1 )=(VLower); % gathering only

%% Implicit Euler setup.
% AV = B; V = A\B;
% Order of unknown V's will be VL-,VU-,VU2-,VL,VU,VU2,VL+,VU+,VU2+.
% Where VL is voltage inside axon, VU is voltage outside axon under myelin,
% VU2 is voltage outside myelin. (Applied voltage would then be in series
% to grnd). Think of it as a double cable, then add one more layer with 0 cap, then
% power sources (applied voltage) to ground
% Then follow with KCL at t+deltaT:

% For inner layer, equations must satisfy:
% GA (dVL+ - dVL) + GA(dVL- - dVL) + GM(dVU - dVL) - dIHH/dV * (dVL - dVU)
% + CM/dT (dVU - dVL) = - GA(VL+ - VL) - GA(VL- - VL) - GM(VU - VL) + IHH@(VL-VU)

% For outer (upper) layer, equations must satisfyu
% GP(dVU+ - dVU) + GP(dVU- - dVU) + GM(dVL - dVU) + CM/dT (dVL - dVU) + CU/dT([dVOuter=0] - dVU) +
% dIHH/dV *(dVL - dVU) + GU (dVU2 - dVU)= -GP (VU+ - VU) - GP(VU- - VU) -
% GM(VL - VU) - IHH@(VL-VU) - CU/dT (VOuter - VU) - GU (VU2 - VU)

% Where GA is axoplasmic conductance, VU+ is the upper compartment node one
% to the right, VU- is the upper compartment node one to the left...
% GM is membrane condudctance, GP is periaxonal conductance...
% GU is conductance between upper layer and next outer layer
% IHH is hodkin huxley currents at VM = VL - VU
% VOuter is the external voltage
% and dIHH/dv is the derivative of hodkin huxley currents

% So we'll set this up as A * (del V) = B. B must therefore include
% everything that depends on the voltage at the running time step. 
% So B =-G * V + IHH@V + GExt * VExt
% A must include everything depending on future voltage, 
% So A = (G + dIHH + CM + CU). Of these, only dIHH can't be precomputed.

% Because we have two layers we're going to write these out two at a time
% In the neuron model, there is no prefirst and postlast node. Just
% % resistors going off into nothingness.
% for a=1:axons
%     tempG = sparse(nodes*3);
%     for i=1:nodes
%         if (i==1)
%             tempG(1,1:4) = [-gAxoplasmicPlus(i,a)-gLower(i,a),gLower(i,a),gAxoplasmicPlus(i,a),0];
%             tempG(2,1:4) = [gLower(i,a),-gPeriaxonalPlus(i,a)-gUpper(i,a)-gLower(i,a),0,gPeriaxonalPlus(i,a)];
%         elseif (i==nodes)
%             tempG((nodes-1)*2+1,(nodes-2)*2+1:(nodes-2)*2+4) = [gAxoplasmicMinus(i,a),0,-gAxoplasmicMinus(i,a)-gLower(i,a),gLower(i,a)];
%             tempG((nodes-1)*2+2,(nodes-2)*2+1:(nodes-2)*2+4) = [0,gPeriaxonalMinus(i,a),gLower(i,a),-gPeriaxonalMinus(i,a)-gUpper(i,a)-gLower(i,a)];
%         else
%             tempG(2*(i-1)+1,2*(i-2)+1:2*(i-2)+6) = [gAxoplasmicMinus(i,a),0,-gAxoplasmicPlus(i,a)-gAxoplasmicMinus(i,a)-gLower(i,a),gLower(i,a),gAxoplasmicPlus(i,a),0];
%             tempG(2*(i-1)+2,2*(i-2)+1:2*(i-2)+6) = [0,gPeriaxonalMinus(i,a),gLower(i,a),-gPeriaxonalMinus(i,a)-gPeriaxonalPlus(i,a)-gUpper(i,a)-gLower(i,a),0,gPeriaxonalPlus(i,a)];
%         end
%     end
%     if (exist('G','var'))
%         G=blkdiag(G,tempG);
%     else
%         G=tempG;
%     end
% end
% % Speed up A calculation. This part of it never changes
% constA = -G...
%     + spdiags(kron(reshape(cUpper/deltaT,nodes*axons,1),[0;1]),0,2*axons*nodes,2*axons*nodes)...  % CU*VU, btm right
%     + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[0;1]),0,2*axons*nodes,2*axons*nodes)...  % cL*VU, brm right
%     + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[1;0]),0,2*axons*nodes,2*axons*nodes)...  % cL*VL, top left
%     + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[0;-1]),1,2*axons*nodes,2*axons*nodes)... % cL * VL, top right
%     + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[-1;0]),-1,2*axons*nodes,2*axons*nodes);% cL * VL, btm left


% Because we have 3 layers we're going to write these out 3 at a time
% In the neuron model, there is no prefirst and postlast node. Just
% resistors going off into nothingness.
% If you want to imagine this, draw a 3 x long set of points
% this goes through each point, labeling what goes in and what goes out
% Starting in the bottom left (inside axon, on edge), and working to top
% left (Outside Myelin) before returning inside.
for a=1:axons
    tempG = sparse(nodes*3);
    for i=1:nodes
        if (i==1)
            tempG(1,1:6) = [-gAxoplasmicPlus(i,a)-gLower(i,a),gLower(i,a),0,gAxoplasmicPlus(i,a),0,0];
            tempG(2,1:6) = [gLower(i,a),-gPeriaxonalPlus(i,a)-gUpper(i,a)-gLower(i,a),gUpper(i,a),0,gPeriaxonalPlus(i,a),0];
            tempG(3,1:6) = [0,gUpper(i,a),-gUpper(i,a)-gSecondPlus(i,a)-gSecond(i,a),0,0,gSecondPlus(i,a)];
        elseif (i==nodes)
            tempG((nodes-1)*3+1,(nodes-2)*3+1:(nodes-2)*3+6) = [gAxoplasmicMinus(i,a),0,0,-gAxoplasmicMinus(i,a)-gLower(i,a),gLower(i,a),0];
            tempG((nodes-1)*3+2,(nodes-2)*3+1:(nodes-2)*3+6) = [0,gPeriaxonalMinus(i,a),0,gLower(i,a),-gPeriaxonalMinus(i,a)-gUpper(i,a)-gLower(i,a),gUpper(i,a)];
            tempG((nodes-1)*3+3,(nodes-2)*3+1:(nodes-2)*3+6) = [0,0,gSecondMinus(i,a),0,gUpper(i,a),-gSecondMinus(i,a)-gUpper(i,a)-gSecond(i,a)];
        else
            tempG(3*(i-1)+1,3*(i-2)+1:3*(i-2)+9) = [gAxoplasmicMinus(i,a),0,0,-gAxoplasmicPlus(i,a)-gAxoplasmicMinus(i,a)-gLower(i,a),gLower(i,a),0,gAxoplasmicPlus(i,a),0,0];
            tempG(3*(i-1)+2,3*(i-2)+1:3*(i-2)+9) = [0,gPeriaxonalMinus(i,a),0,gLower(i,a),-gPeriaxonalMinus(i,a)-gPeriaxonalPlus(i,a)-gUpper(i,a)-gLower(i,a),gUpper(i,a),0,gPeriaxonalPlus(i,a),0];
            tempG(3*(i-1)+3,3*(i-2)+1:3*(i-2)+9) = [0,0,gSecondMinus(i,a),0,gUpper(i,a),-gSecondMinus(i,a)-gSecondPlus(i,a)-gUpper(i,a)-gSecond(i,a),0,0,gSecondPlus(i,a)];
        end
    end
    if (exist('G','var'))
        G=blkdiag(G,tempG); % for multiple axons simultaneously
    else
        G=tempG;
    end
end

% Speed up A calculation. This part of it never changes
constA = -G...
    + spdiags(kron(reshape(cUpper/deltaT,nodes*axons,1),[0;1;0]),0,3*axons*nodes,3*axons*nodes)...  % CU*VU, btm right
    + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[0;1;0]),0,3*axons*nodes,3*axons*nodes)...  % cL*VU, brm right
    + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[1;0;0]),0,3*axons*nodes,3*axons*nodes)...  % cL*VL, top left
    + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[0;-1;0]),1,3*axons*nodes,3*axons*nodes)... % cL * VL, top right
    + spdiags(kron(reshape(cLower/deltaT,nodes*axons,1),[-1;0;0]),-1,3*axons*nodes,3*axons*nodes);% cL * VL, btm left

% One more step before we get to the loop.
% When we apply external voltages, we need this to use (VSecond - VOuter)
% when considering how much current escapes the system, not VSecond - 0.
% So we'll create a GVext which only includes this term.
GVext2 = sparse([3:3:(axons*nodes*3)],[3:3:(axons*nodes*3)],-gSecond);

B=zeros(3*nodes*axons,1);
IHH=zeros(nodes,axons);
dIHH=zeros(nodes,axons);
cIHH=zeros(nodes,axons);
Vcat = zeros(3*nodes*axons,1); % alternating VL and VU

deltaT=tStep*10^-3; % convert deltaT to ms for HH

VM = VLower - VUpper; % For use in IHH equations on first run
    
for timeVal=1:1:length(t)-1
    
    % 0. Apply new external voltages 11/1/2017 push all to PAfunc
    if (check_External_Voltage)
        
        % Need to get difference in external voltage between previous time
        % point and next time point. Output will be nodes x axons
        Vprev = PAfunc((timeVal-1) * tStep, PAfuncArgs, Vext);
        Vnext = PAfunc(timeVal * tStep, PAfuncArgs, Vext);
        
        if (max(max(abs(Vnext-Vprev)))>1e-10) % something changed
            VLower = VLower + Vnext - Vprev;
            VUpper = VUpper + Vnext - Vprev;
            VSecond = VSecond + Vnext - Vprev;
            VOuter = VOuter + Vnext - Vprev;
            
% Historic. apply external voltage at particular time points. Section Obsolete 11/1/17            
%              for a = 1:axons
%                 VLower (:,a) = VLower(:,a) + Vnext(:,a)-Vprev(:,a) ; % If Ve goes up, both vLower and vUpper drop.
%                 VUpper(:,a) = VUpper(:,a) + dPA(timeVal,a) * Vext(:,a) ; % [in Neuron, Vext does not affect Vm directly in 2cable]
%                 VSecond(:,a) = VSecond(:,a) + dPA(timeVal,a) * Vext(:,a) ; % [in Neuron, Vext does not affect Vm directly in 2cable]
%                 % There's one more thing. With external voltages, we need
%                 % to modify how much leaks out of the upper compartments.
%                 % Its no longer VUpper * Gupper, but (Vupper - Vext) *
%                 % GUpper.
%                 VOuter(:,a) = VOuter(:,a) + dPA(timeVal,a) * Vext(:,a) ;
%              end
        end
    end
            
    % 0. Apply new external voltages
%     if (check_External_Voltage) % If external voltages ever change
%         if (exist ('PAfunc','var')) % have dPA function - use that (This isn't in a cell, so it works)
%             dPA(timeVal,:) = sparse(PAfunc(timeVal * tStep * ones(1,axons),PAfuncArgs ) - PAfunc((timeVal-1) * tStep * ones(1,axons),PAfuncArgs ));
%         end
%         if (dPA(timeVal,a)~=0)
%             for a = 1:axons
%                 VLower (:,a) = VLower(:,a) + dPA(timeVal,a) * Vext(:,a) ; % If Ve goes up, both vLower and vUpper drop.
%                 VUpper(:,a) = VUpper(:,a) + dPA(timeVal,a) * Vext(:,a) ; % [in Neuron, Vext does not affect Vm directly in 2cable]
%                 VSecond(:,a) = VSecond(:,a) + dPA(timeVal,a) * Vext(:,a) ; % [in Neuron, Vext does not affect Vm directly in 2cable]
%                 % There's one more thing. With external voltages, we need
%                 % to modify how much leaks out of the upper compartments.
%                 % Its no longer VUpper * Gupper, but (Vupper - Vext) *
%                 % GUpper.
%                 VOuter(:,a) = VOuter(:,a) + dPA(timeVal,a) * Vext(:,a) ;
%                 
%             end
%         end
%     end
    
    
    
    
    
    % 1. find Ionic contributions and di/dv
    
    if (~passive)
        % Current Ionic contributions are
        INA(1:11:end,:) = NgNAF(1:11:end,:) .* (MNA(1:11:end,:).^3) .* HNA(1:11:end,:) .* (VM(1:11:end,:)-eNA); % NA current
        IK(1:11:end,:) = NgK(1:11:end,:) .* SK(1:11:end,:) .* (VM(1:11:end,:)-eK); % K current
        INAP(1:11:end,:) = NgNAP(1:11:end,:) .* (MNAP(1:11:end,:).^3) .* (VM(1:11:end,:)-eNA);  % slow NA current
        ILK(1:11:end,:) = NgLK(1:11:end,:).*(VM(1:11:end,:)-eLK); % Leak current
        IHH = ILK + INAP + IK + INA; % make sure signs are correct here. All hodgkin huxley currents are in this term.
        
        dv = 0.001;
        % and if Vm is off by a little bit, it would be
        cINA(1:11:end,:) = NgNAF(1:11:end,:) .* (MNA(1:11:end,:).^3) .* HNA(1:11:end,:) .* (VM(1:11:end,:)+dv-eNA);
        cIK(1:11:end,:) = NgK(1:11:end,:) .* SK(1:11:end,:) .* (VM(1:11:end,:)+dv-eK);
        cINAP(1:11:end,:) = NgNAP(1:11:end,:) .* (MNAP(1:11:end,:).^3) .* (VM(1:11:end,:)+dv-eNA);
        cILK(1:11:end,:) = NgLK(1:11:end,:).*(VM(1:11:end,:)+dv-eLK);
        cIHH = cILK + cINAP+ cIK+ cINA;
        
        dIHH = (cIHH - IHH) / dv;
    end
    
    % Now we construct A and B, so A*deltaV = B
    % A is 2*axons*nodes ^2, B is 2*axons*nodes x 1, as is V.
    % All deltaV dependents are in A, everything else in B
    % Note that leak sources in all lower compartments mess with B
    Vcat(1:3:end) = reshape(VLower,axons*nodes,1);
    Vcat(2:3:end) = reshape(VUpper,axons*nodes,1);
    Vcat(3:3:end) = reshape(VSecond,axons*nodes,1);
    
    % B uses everything depending on V@t. so G*V,IHH,eR adjustments for
    % ...G*V, and VExt - VUpper
    B = G*Vcat - GVext2* reshape(kron (VOuter, [0;0;1]),axons*nodes*3,1); % adjust for external and IHH
    B(1:3:end,:)= B(1:3:end,:) + reshape(-IHH + eR.*gLower,axons*nodes,1);
    B(2:3:end,:)= B(2:3:end,:) + reshape(IHH - eR.*gLower,axons*nodes,1);
    
    % Now adjust A. A relies on dIHH/dV at two columns per row
    t1 = sparse(1:1:nodes*axons*3,1:1:nodes*axons*3,kron(reshape(dIHH,nodes*axons,1),[1;0;0])); 
    A = constA + t1 - circshift(t1,1,1)- circshift(t1,1,2)+circshift(circshift(t1,1,1),1,2);
    
    
    C=A\B; % get deltaV.
    VSecond = VSecond + reshape(C(3:3:end),nodes,axons);
    VUpper  = VUpper  + reshape(C(2:3:end),nodes,axons);
    VLower  = VLower  + reshape(C(1:3:end),nodes,axons);
    
    VM = VLower - VUpper; % So as not to compute this over and over again.
    
    % 1. calculate gates at new VM, Change to conventional notation
    MaNAP = q10_1*vtrap1(VM); % Persistent Na
    MbNAP = q10_1*vtrap2(VM);
    tau_mp = 1 ./ (MaNAP + MbNAP);
    mp_inf = MaNAP ./ (MaNAP + MbNAP);
    
    MaNA = q10_1*vtrap6(VM);
    MbNA = q10_1*vtrap7(VM);
    tau_m = 1 ./ (MaNA + MbNA);
    m_inf = MaNA ./ (MaNA + MbNA);
    
    HaNA = q10_2*vtrap8(VM);
    HbNA = q10_2*bhA ./ (1 + Exp(-(VM+bhB)/bhC));
    tau_h = 1 ./ (HaNA + HbNA);
    h_inf = HaNA ./ (HaNA + HbNA);
    
    v2 = VM - vtraub; % convert to traub convention
    SaK = q10_3*asA ./ (Exp((v2+asB)/asC) + 1) ;
    SbK = q10_3*bsA ./ (Exp((v2+bsB)/bsC) + 1);
    tau_s = 1 ./ (SaK + SbK);
    s_inf = SaK ./ (SaK + SbK);
    
    %ionics a time step in the future
    MNA  = MNA  + (1-exp(-deltaT./tau_m))  .* (m_inf-MNA);
    %     MNA = min(max(MNA,0),1);
    HNA  = HNA  + (1-exp(-deltaT./tau_h))  .*(h_inf-HNA);
    %   HNA = min(max(HNA,0),1);
    SK   = SK   + (1-exp(-deltaT./tau_s))  .*(s_inf-SK);
    %   SK = min(max(SK,0),1);
    MNAP = MNAP + (1-exp(-deltaT./tau_mp)) .*(mp_inf-MNAP);
    %   MNAP = min(max(MNAP,0),1);
    
    % AP recording
    for a=1:axons
        for n = 1:11:221
            if ( (VM(n,a))>0 && AP(n,a)==-1 )
                AP (n,a)= timeVal*tStep;
            end
        end
    end
    
    % SAMPLING
    if (mod(timeVal,SampleEvery)==0)
            V(:,:,timeVal/SampleEvery)=(VM);
            VUPPERStore(:,:,timeVal/SampleEvery)=(VUpper);
            VUPPERStore2(:,:,timeVal/SampleEvery)=(VSecond);
            
            
            NA_Store(:,:,timeVal/SampleEvery)=INA; % NA 
            
            NA_H_Store(:,:,timeVal/SampleEvery)=HNA(1:11:end,:); % NA 
            NA_M3_Store(:,:,timeVal/SampleEvery)=(MNA(1:11:end,:).^3); % NA 
            
            K_Store(:,:,timeVal/SampleEvery)=IK; % K
            NAP_Store(:,:,timeVal/SampleEvery)=INAP; % NAP
            
            
            
            
        if (max(max(V(:,:,timeVal/SampleEvery)))>500 || min(min(V(:,:,timeVal/SampleEvery)))<-200) % DEBUG
            toc
            disp('Possible error. Huge voltage. look at me.');
        end
        
    end
end

%% finalize AP results into binary
% "AP" if all last 5 nodes broke through 0 mv
% AND did so within 1 millisecond.
    for a=1:axons
        if (AP(221,a)~=-1 && min(AP(166:11:221,a)>-1)>0 && max(AP(221,a)-AP(166:11:221,a))<1000)
        APResults(a)=AP(221,a); % return time of AP, in us
        end
    end
    
%% plot results
Tout = 1:SampleEvery*tStep:time_in_US;

Vout = squeeze(V);
VUPPERStore=squeeze(VUPPERStore);


NA_Store=squeeze(NA_Store);
NA_H_Store=squeeze(NA_H_Store);
NA_M3_Store=squeeze(NA_M3_Store);

K_Store=squeeze(K_Store);
NAP_Store=squeeze(NAP_Store);
% figure
% hold on
% for i=1:axons
%     plot(Tout/1000,squeeze(V(RecordFrom,i,:))')
% end
% xlabel 'ms'
% title 'all V'

disp('done.');
end

%% Functions taken directly from MRG
function vtrap = vtrap(x) % NEVER USED
bsA = 0.03;
bsB = 10;
bsC = -1;
if (x < -50)
    vtrap = 0*ones(size(x));
else
    vtrap = bsA ./ (Exp((x+bsB)/bsC) + 1);
end
end

function vtrap1=vtrap1(x)

ampA = 0.01;
ampB = 27;
ampC = 10.2;

vtrap1 = (ampA*(x+ampB)) ./ (1 - Exp(-(x+ampB)/ampC));
vtrap1(logical(abs((x+ampB)/ampC) < 1e-6)) = ampA*ampC;
%vtrap1 = zeros(size(x));
%vtrap1(find(abs((x+ampB)/ampC) < 1e-6))=ampA*ampC;
% if (abs((x+ampB)/ampC) < 1e-6)
%     vtrap1 = ampA*ampC*ones(size(x));
% else
%     vtrap1 = (ampA*(x+ampB)) ./ (1 - Exp(-(x+ampB)/ampC));
% end
end

function vtrap2=vtrap2(x)

bmpA = 0.00025;
bmpB = 34;
bmpC = 10;

vtrap2 = (bmpA*(-(x+bmpB))) ./ (1 - Exp((x+bmpB)/bmpC));
vtrap2(logical(abs((x+bmpB)/bmpC) < 1e-6))=bmpA*bmpC;
% if (abs((x+bmpB)/bmpC) < 1e-6)
%     vtrap2 = bmpA*bmpC*ones(size(x)); % Ted Carnevale minus sign bug fix
% else
%     vtrap2 = (bmpA*(-(x+bmpB))) ./ (1 - Exp((x+bmpB)/bmpC));
% end
end

function vtrap6=vtrap6(x)

amA = 1.86;
amB = 21.4;
amC = 10.3;

vtrap6 = (amA*(x+amB)) ./ (1 - Exp(-(x+amB)/amC));
vtrap6(logical(abs((x+amB)/amC) < 1e-6)) = amA*amC;
% if (abs((x+amB)/amC) < 1e-6)
%     vtrap6 = amA*amC*ones(size(x));
% else
%     vtrap6 = (amA*(x+amB)) ./ (1 - Exp(-(x+amB)/amC));
% end
end

function vtrap7 = vtrap7(x)

bmA = 0.086;
bmB = 25.7;
bmC = 9.16;

vtrap7 = (bmA*(-(x+bmB))) ./ (1 - Exp((x+bmB)/bmC));
vtrap7(logical(abs((x+bmB)/bmC) < 1e-6)) = bmA*bmC;
% if (abs((x+bmB)/bmC) < 1e-6)
%     vtrap7 = bmA*bmC*ones(size(x)); % Ted Carnevale minus sign bug fix
% else
%     vtrap7 = (bmA*(-(x+bmB))) ./ (1 - Exp((x+bmB)/bmC));
% end
end


function vtrap8 = vtrap8(x)

ahA = 0.062;
ahB = 114.0;
ahC = 11.0;

vtrap8 = (ahA*(-(x+ahB))) ./ (1 - Exp((x+ahB)/ahC));
vtrap8(logical(abs((x+ahB)/ahC) < 1e-6)) = ahA*ahC;

% if (abs((x+ahB)/ahC) < 1e-6)
%     vtrap8 = ahA*ahC*ones(size(x)); % Ted Carnevale minus sign bug fix
% else
%     vtrap8 = (ahA*(-(x+ahB))) ./ (1 - Exp((x+ahB)/ahC));
% end
end

function [Exp] = Exp(x)

Exp=exp(x);
Exp(logical(x<-100))=0;


% if (x < -100)
%     Exp = 0*ones(size(x));
% else
%     Exp = exp(x);
% end
end
