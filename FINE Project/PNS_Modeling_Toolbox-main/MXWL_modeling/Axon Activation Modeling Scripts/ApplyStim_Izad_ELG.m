function [all_active,numactive]=ApplyStim_Izad(fascicles,Vin,PW,PA)

[TotalNodes,nAxons]=size(Vin);
%Vin should be in format of nodes as rows and N(axons) columns

%make array of pws - for matrix math
pws=PW*ones(TotalNodes,nAxons);
pas=PA*ones(TotalNodes,nAxons);


%equations 2.21-2.24
alpha=307.66+0.5577./pws;
mu=exp(76.211*pws.^2-29.746*pws+4.5111);
beta=1./pws;
V=1000; %this is a coefficient, not a scaling factor!!!

%adjust interpolated voltages
%Vi should be 21 rows, N(axon) columns
%allaxons.nodeV already in proper format


%ASSIGN VOLTAGES FROM ENDO, DUPLICATED FOR
%EACH PW/PA, AND SCALED FOR EACH PA
% Vi=repmat(Vi,1,length(PAs)*length(PWs));
Vi=Vin.*pas.*1000;  %convert to mV, scaled by the appropriate PA
% Vi=single(Vi);

%pre-allocation
D2V=zeros(TotalNodes-2,nAxons);
f=zeros(TotalNodes,nAxons);
Chi=zeros(TotalNodes,nAxons);

%calculate equation 2.19
f=alpha.*exp(Vi./mu)+beta.*exp(Vi./V);
f=f(2:end-1,:);

%calculate part of equation 2.25
D2V=diff(Vi,2);
Chi=D2V-f;

%calculate the rest of equation 2.25
Chi=max(Chi>0); %find either a 0 or a 1 in each column
% Chi=reshape(permute(reshape(Chi,TotalAxons,[]),[3,2,1]),length(PAs),length(PWs),TotalAxons);
% Chi((PAs==0),:,:)=single(0); %No stimulation MUST be 0 response
% Chi(:,(PWs==0),:)=single(0); %No stimulation MUST be 0 response

all_active=Chi;

%store the axons that are active by fascicle
%need to go through and see which axons belong to which fascicle
%determine how many axons are in each fascicle
q=1;
for k=1:length(fascicles)
    axonperfasc=fascicles{k}.nAxons;
    numactive(k,1)=sum(all_active(1,q:q+axonperfasc-1));
    q=q+axonperfasc;
end

end