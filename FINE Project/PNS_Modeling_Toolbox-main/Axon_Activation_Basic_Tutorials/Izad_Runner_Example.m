
function Response = Izad_Runner_Example()
% This is virtually identical to the peterson runner
% it finds the voltages for a contact and fascicle, then runs them through
% the izad for a range of PW and PA;

%% 1. Get voltages;
addpath(genpath(pwd))
clc
clear all
close all
drawnow()
a = tic;
mydir = pwd;
cd ([pwd, '\MXWL modeling\Example MXWL Modeling output'])

%% User Defined Params part 1
Contacts = 2; % array of which contacts to look at
NumFascicles = 1; % which fascicles to look at
animate=1; % show results at end

PW_list = 50:50:250; % in us
PA_list = 3000*[0.2:0.2:1]; % not really the mA range

%% Load everything
load ('AxonPositionsRelativeToCenter.mat'); % for plotting points
load ('FascicleDescriptions.mat'); % for center offset for each fasc
% Interpolated Voltages
for n= Contacts
    filename=[pwd,'/InterpolatedVoltages/InterpolatedVoltagesContact',num2str(n),'.mat'];
    junk=load(filename);
    AllInterpolatedVoltages{n}=junk.InterpolatedVoltages;
    clear junk
end

% Run izad
for n = Contacts
    for f = NumFascicles
        
        % Acquire desired FEM voltages
        FascicleName = FascicleNames{f};
        AllV = AllInterpolatedVoltages{n}.(FascicleName); % get voltages
        
        Axons = size(AllV,1); % presumably going through all axons

        Diameters = 10 * ones (1,Axons); % nonrandom for now, but it could be. um
        Offset = 0; % and we're going with no offset.
        
        for a = 1:length(Diameters) % to accomodate different diameters and offsets
            Diameter = Diameters(a);
            Inds = AxonPositionsRelativeToCenter.Diameter_Offset_Indices{find(AxonPositionsRelativeToCenter.Diameter_Range==Diameter),find(AxonPositionsRelativeToCenter.Offset_Range==Offset)}; % find which indices that corresponds to;
            Voltage_Along_Axons(a,:) = AllV(a,Inds(1):11:Inds(2)); % Izad and peterson only need voltage at nodes, not internodes
        end

        % Izad does all scaling
        Response(n,f,:,:,:) = Step3_IzadMethod(Voltage_Along_Axons,PW_list,PA_list);
    end
end


cd (mydir)

%% Animate result
if (animate==1)
    contact=2;
    fasc=f;
    
    if (size(Response,3)>1 && size(Response,4)>1)
        Result = squeeze(Response(contact,fasc,:,:,:));
    elseif (size(Response,3)>1)
        Result(1,:,:) = squeeze(Response(contact,fasc,:,:,:));
    elseif (size(Response,4)>1)
        Result(:,1,:) = squeeze(Response(contact,fasc,:,:,:));
    else
        Result(1,1,:) = squeeze(Response(contact,fasc,:,:,:));
    end
    
Result = double(Result);

% 1. looping through PW and PA

    figure
    PAInd1=1;
    PWInd1=1;
    
    PAInd2=1;
    PWInd2=1;
    while (1==1)
        
        
        subplot(2,1,1)
        RGB = [0,0,1]'*ones(1,Axons); % start at purple...
        if (max(max(squeeze(Result(PAInd1,PWInd1,:))))>0)
            RGBmod = [1,0,-1]'* (squeeze(Result(PAInd1,PWInd1,:))./max(max(squeeze(Result(PAInd1,PWInd1,:)))))' ; % change to red if active
        else
            RGBmod = zeros(size(RGB));
        end
        scatter(AxonPositionsRelativeToCenter.(FascicleName).X,AxonPositionsRelativeToCenter.(FascicleName).Y,20,RGB'+RGBmod')
        title (['PA, ',num2str(PA_list(PAInd1)),' PW, ',num2str(PW_list(PWInd1))])
        
        pause(0.5)
        
        PWInd1=PWInd1+1;
        if (PWInd1>length(PW_list))
            PWInd1=1;
            PAInd1=PAInd1+1;
            if(PAInd1>length(PA_list))
                PAInd1=1;
            end
        end
        
        subplot(2,1,2)
        RGB = [0,0,1]'*ones(1,Axons); % start at purple...
        if (max(max(squeeze(Result(PAInd2,PWInd2,:))))>0)
            RGBmod = [1,0,-1]'* (squeeze(Result(PAInd2,PWInd2,:))./max(max(squeeze(Result(PAInd2,PWInd2,:)))))' ; % change to red if active
        else
            RGBmod = zeros(size(RGB));
        end
        scatter(AxonPositionsRelativeToCenter.(FascicleName).X,AxonPositionsRelativeToCenter.(FascicleName).Y,20,RGB'+RGBmod')
        title (['PA, ',num2str(PA_list(PAInd2)),' PW, ',num2str(PW_list(PWInd2))])
        
        PAInd2=PAInd2+1;
        if(PAInd2>length(PA_list))
            PAInd2=1;
            PWInd2=PWInd2+1;
            if (PWInd2>length(PW_list))
                PWInd2=1;
            end
        end
        
        
    end
end
    
end


