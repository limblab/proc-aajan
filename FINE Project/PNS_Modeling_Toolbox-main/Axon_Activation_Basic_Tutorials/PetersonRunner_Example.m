
function Response = PetersonRunner()
% This is an example of a Peterson-Model runner
% The idea is to frontload all calculations and interpolations
% and to only have the model script run the model.
% that way you can swap models at will.
% and do contact combinations however you like without altering the model.
%
% Calls Peterson model for a given PA, PW, then draws the result.
%
% assumes you used the extensive positionaxons file (all offsets and all
% diams), and then interpolated those voltages.
% That allows quickly changing diameters without recomputing everything.

%% -1. reset
addpath(genpath(pwd))
clc
clear all
close all
drawnow()
%% 0. Get peterson params

% Peterson Params
load([pwd, '\Peterson support files\node_weights.mat'])
load([pwd, '\Peterson support files\all_threshold.mat'])

%% 1. Get voltages;

a = tic;
mydir = pwd;
cd ([pwd, '\MXWL modeling\Example MXWL Modeling output'])

%% User Defined Params part 1
Contacts = 2; % array of which contacts to look at
NumFascicles = 1; % which fascicles to look at
animate=1; % show results at end

PW_list = 50:50:250; % in us
PA_list = 10*[0.2:0.2:1]; % not really the mA range

%% Load everything
load ('AxonPositionsRelativeToCenter.mat'); % for plotting points
load ('FascicleDescriptions.mat'); % for center offset for each fasc
FascicleNames = fieldnames(AxonPositionsRelativeToCenter);
% Interpolated Voltages
for n= Contacts
    filename=[pwd,'/InterpolatedVoltages/InterpolatedVoltagesContact',num2str(n),'.mat'];
    junk=load(filename);
    AllInterpolatedVoltages{n}=junk.InterpolatedVoltages;
    clear junk
end

%% Load PW-dependent values
for PWInd = 1:length(PW_list)
    disp(['On PW ', num2str(PWInd), ' of ', num2str(length(PW_list))])
    [PWthreshold,w_node_mat] = updatePWdepParams(PW_list(PWInd),all_threshold,node_weights); % 
    for PAInd = 1:length(PA_list)
        for n = Contacts
            for f = NumFascicles
                
                % Acquire desired FEM voltages
                FascicleName = FascicleNames{f};
                AllV = AllInterpolatedVoltages{n}.(FascicleName); % get voltages
                
                Axons = size(AllV,1); % presumably going through all axons
                Diameters = 12*ones(1,Axons); % doesn't have to be uniform
                Offset = 0; % and we're going with no offset.
                
                for a = 1:length(Diameters) % to accomodate different diameters and offsets
                    Diameter = Diameters(a);
                    Inds = AxonPositionsRelativeToCenter.Diameter_Offset_Indices{find(AxonPositionsRelativeToCenter.Diameter_Range==Diameter),find(AxonPositionsRelativeToCenter.Offset_Range==Offset)}; % find which indices that corresponds to;
                    vA1(a,:) = AllV(a,Inds(1):11:Inds(2));
                end
                % modify by PA and run through Peterson
                vA1 = vA1 * PA_list(PAInd);
                
                Response(n,f,PWInd,PAInd,:) = PetersonResponse(vA1,Diameters,PW_list(PWInd),all_threshold,w_node_mat,PWthreshold);
            end
        end
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
    
    Result = permute(Result,[2,1,3]); % match drawing script

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



function [PWthreshold,w_node_mat] = updatePWdepParams(PW,all_threshold,node_weights)

%% Update PW dependent values. namely node weights and PW interp of threshold
%calculate threshold values for the specific PW we are interestedin
alldiams=[4:1:20]; % list of diameters
PWthreshold = interp3(all_threshold.pws, all_threshold.ves, all_threshold.diams, all_threshold.data, PW, all_threshold.ves, alldiams, 'spline');%this is cubic

% Frontload weight calculations
for i=4:20 % diameters in petersen model go from 4 to 20um.
    %interpolate in order to find the exact weights for the given PW
    for j=1:19 % 19 d2Ve nodes.
        weight_PWset(i-3,j)=interpn(node_weights.PW',node_weights.(['diam' num2str(i)])(:,j),PW,'spline');
    end
    %makes matrix to calculate MDF for each node
    w_node_mat{i-3} = toeplitz([fliplr(weight_PWset(i-3,1:10)) zeros(1,9)],[weight_PWset(i-3,10:19) zeros(1,9)]);
end
end

