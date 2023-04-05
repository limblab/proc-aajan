function Step3_IzadMethod(model,SizeStr,NumberOfContacts,PoleStr,AxonPositionsRelativeToCenter)

%To be used in conjunction with output from PositionAxons() and InterpVoltages()

%set the stim params
PWs=[0:.001:.2]; %ms
PAs=[0:.01:1.75]; %mA

%Point to the needed directories
InterpolatedVoltagesDir=['../../Model F' num2str(model.F) '.v' num2str(model.V) '/' SizeStr ' ' PoleStr '/Interpolated Voltages/'];
PopulationResponseDir=['../../Model F' num2str(model.F) '.v' num2str(model.V) '/' SizeStr ' ' PoleStr '/Population Responses/'];
if ~exist(PopulationResponseDir,'dir')
    mkdir(PopulationResponseDir)
end


if strcmpi(PoleStr,'Monopole')
    TotalPoles=1;
elseif strcmpi(PoleStr,'Bipole')
    TotalPoles=2;
elseif strcmpi(PoleStr,'Tripole')
    TotalPoles=3;
end

NumberOfFascicles=model.F;
TotalAxons=length(AxonPositionsRelativeToCenter.Endo1.Diam);
TotalNodes=41;

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


for temp_Contact=1:NumberOfContacts
    
    PopulationResponse.PWs=PWs;
    PopulationResponse.PAs=PAs;

    save_file_name=[PopulationResponseDir 'Electrode' num2str(temp_Contact) '.mat'];

    if ~exist(save_file_name,'file')
            
        for temp_Fascicle=1:NumberOfFascicles
            disp([SizeStr ', ' PoleStr ', temp_Contact=' num2str(temp_Contact) ', temp_Fascicle=' num2str(temp_Fascicle)])
            
            %Gather the axon voltage information, sum in anodes if needed
            clear Vi
            for temp_pole=1:TotalPoles
                if TotalPoles==1
                    temp_file_in=[InterpolatedVoltagesDir 'Cathode' num2str(temp_Contact) '.Fascicle' num2str(temp_Fascicle) '.mat'];
                    scale=1;
                elseif TotalPoles==2
                    if temp_pole==1
                        temp_file_in=[InterpolatedVoltagesDir 'Cathode' num2str(temp_Contact) '.Fascicle' num2str(temp_Fascicle) '.mat'];
                        scale=1;
                    else
                        temp_file_in=[InterpolatedVoltagesDir 'Anode' num2str(temp_Contact) '.Fascicle' num2str(temp_Fascicle) '.mat'];
                        scale=1;
                    end
                elseif TotalPoles==3
                    if temp_pole==1
                        temp_file_in=[InterpolatedVoltagesDir 'Cathode' num2str(temp_Contact) '.Fascicle' num2str(temp_Fascicle) '.mat'];
                        scale=1;
                    elseif temp_pole==2
                        temp_file_in=[InterpolatedVoltagesDir 'Anode' num2str(temp_Contact) 'P.Fascicle' num2str(temp_Fascicle) '.mat'];
                        scale=0.5;
                    else
                        temp_file_in=[InterpolatedVoltagesDir 'Anode' num2str(temp_Contact) 'N.Fascicle' num2str(temp_Fascicle) '.mat'];
                        scale=0.5;
                    end
                end
                temp_Vi=load(temp_file_in);
                if ~exist('Vi','var')
                    Vi=temp_Vi.Vi.*scale;
                else
                    Vi=Vi+temp_Vi.Vi.*scale;
                end
            end
            %adjust interpolated voltages
            Vi=Vi'; %21 rows, N(axon) columns
            
            %ASSIGN VOLTAGES FROM ENDO, DUPLICATED FOR
            %EACH PW/PA, AND SCALED FOR EACH PA
            Vi=repmat(Vi,1,length(PAs)*length(PWs));
            Vi=Vi.*temp_PA.*1000;  %convert to mV, scaled by the appropriate PA
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
            
            %save
            PopulationResponse.(['Endo' num2str(temp_Fascicle)]).Activated=sum(Chi,3);
            PopulationResponse.(['Endo' num2str(temp_Fascicle)]).ActiveIndex=Chi;
            
            clear Vi D2V f Chi
            % END IZAD METHOD
           
        end %end temp_fascicle
        save(save_file_name,'PopulationResponse');
        clear PopulationResponse
    end %end if file ~exist
end %end temp_Electrode

end %end function
