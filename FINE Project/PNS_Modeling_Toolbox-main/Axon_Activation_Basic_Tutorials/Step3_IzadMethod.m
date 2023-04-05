function [Chi] = Step3_IzadMethod(Voltages,PW,PA)
% Acquired from Matthew Schiefer Aug 29 2016
% Modified PVL 12/6/16
% To only be the izad method.
% And to not scale voltages by 1000
% -> Voltages need to me in mV
% input:
%  voltages (axons x nodes)
%  PW array (ex: 1:1:30)
%  PA array (ex: 5:5:250 us)
%

PWs = PW;
PAs = PA;

TotalAxons=size (Voltages,1)
TotalNodes=21; % PVL 12/7/16 changed to 21

%START IZAD METHOD:
%equations 2.21-2.24
%pre-allocation
pws=zeros(TotalNodes,TotalAxons*length(PAs)*length(PWs));
alpha=pws;
mu=alpha;
beta=alpha;

%non fascicle-specific calculations
temp_PA=single(repmat(reshape(repmat(PAs,TotalAxons,1),1,[]),TotalNodes,length(PWs)));
pws=single(repmat(reshape(repmat(PWs,TotalAxons*length(PAs),1),1,[]),TotalNodes,1));

%equations 2.21-2.24
alpha=single(307.66+0.5577./pws);
mu=single(exp(76.211*pws.^2-29.746*pws+4.5111));
beta=single(1./pws);
V=1000;

PopulationResponse.PWs=PWs;
PopulationResponse.PAs=PAs;

%adjust interpolated voltages
Voltages=Voltages'; %21 rows, N(axon) columns

Vi=Voltages; % PVL 12/7/16 this line seems to be missing

%ASSIGN VOLTAGES FROM ENDO, DUPLICATED FOR
%EACH PW/PA, AND SCALED FOR EACH PA
Vi=repmat(Vi,1,length(PAs)*length(PWs));
Vi=Vi.*temp_PA;  %convert to mV, scaled by the appropriate PA
Vi=single(Vi);

%pre-allocation
D2V=single(zeros(TotalNodes-2,size(Vi,2)));
f=single(zeros(TotalNodes,size(Vi,2)));
Chi=single(zeros(TotalNodes,size(Vi,2)));

%calculate equation 2.19
f=single(alpha.*exp(Vi./mu)+beta.*exp(Vi./V));
f=f(2:end-1,:);

%calculate part of equation 2.25
D2V=diff(Vi,2);
Chi=D2V-f;

%calculate the rest of equation 2.25
Chi=max(Chi>0); %find either a 0 or a 1 in each column
Chi=reshape(permute(reshape(Chi,TotalAxons,[]),[3,2,1]),length(PAs),length(PWs),TotalAxons);
Chi((PAs==0),:,:)=single(0); %No stimulation MUST be 0 response
Chi(:,(PWs==0),:)=single(0); %No stimulation MUST be 0 response



end %end function
