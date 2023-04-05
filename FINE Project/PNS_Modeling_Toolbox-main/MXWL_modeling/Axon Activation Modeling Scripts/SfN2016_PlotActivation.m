%% Modeling code. Hopefully to generate plots for SfN poster. 

%do models at the threshold PW and vary PA to get threshold activation
%define thresh activation as 1st 100 axons activated
threshPW = [25, 25, 25, 25, 23, 24, 18, 20, 23, 13, 13 ,16, 20, 25, 20]; %us
minaxons = 100;
NerveNameString = 'M19T1_Encap';

%start plot
scatter_colors=[0 128 0;...
    0 0 128;...
    0 128 128;...
    255 0 255;...
    0 255 255;...
    128 0 128;...
    255 102 0;...
    85 34 0;...
    30 45 83;...
    255 210 0;...
    193 5 52;...
    0 255 128;...
    0 139 188;...
    255 0 128;...
    92 71 23]./255;

%% PA sweep
for i = 1:15 %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString 'axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
            %plot axon location - initial color = black (no stim); will plot over
            %to show axons that are activated
            for k = 1:length(axondata.fasciclesfinal{1,j}.axons)
                scatter(axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,1),axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,2),2,'k');
            end
        end
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PA = -0.01; %mA
    numactive = 0;
    
    while sum(numactive) < minaxons %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],threshPW(i));
        PA = PA - 0.01; %increase cathode amplitude
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds),axondata.allaxons.nodeY(1,active_inds),2,scatter_colors(i,:)); %scatter colors should match colors from database
    drawnow
    %save out results
    modelresults.Params = [PA + 0.01, threshPW(i)];
    modelresults.all_active = all_active;
    modelresults.numactive = numactive;
    save([NerveNameString '_C' num2str(i) '_ThresholdActivation.mat'],'modelresults');
    clear modelresults
end

%% PW sweep
PA = -0.7; % mA
for i = 1:15 %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString 'axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
            %plot axon location - initial color = black (no stim); will plot over
            %to show axons that are activated
            for k = 1:length(axondata.fasciclesfinal{1,j}.axons)
                scatter(axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,1),axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,2),2,'k');
            end
        end
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PW = 1; %us
    numactive = 0;
    
    while sum(numactive) < minaxons %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],PW);
        PW = PW + 1; %increase PW
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds),axondata.allaxons.nodeY(1,active_inds),2,scatter_colors(i,:)); %scatter colors should match colors from database
    drawnow
    %save out results
    modelresults.Params = [PA, PW-1];
    modelresults.all_active = all_active;
    modelresults.numactive = numactive;
    save([NerveNameString '_C' num2str(i) '_ThresholdActivation.mat'],'modelresults');
    clear modelresults
end


%% Experimental Values
threshPW = [25, 25, 25, 25, 23, 24, 18, 20, 23, 13, 13 ,16, 20, 25, 20]; %us
PA = -0.7;
for i = 1:15 %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString 'axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
            %plot axon location - initial color = black (no stim); will plot over
            %to show axons that are activated
            for k = 1:length(axondata.fasciclesfinal{1,j}.axons)
                scatter(axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,1),axondata.fasciclesfinal{1,j}.axons{1,k}.location(1,2),2,'k');
            end
        end
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PA = -0.01; %mA
    numactive = 0;
    
    [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],threshPW(i));
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds),axondata.allaxons.nodeY(1,active_inds),2,scatter_colors(i,:)); %scatter colors should match colors from database
    drawnow
    %save out results
    modelresults.Params = [PA + 0.01, threshPW(i)];
    modelresults.all_active = all_active;
    modelresults.numactive = numactive;
    save([NerveNameString '_C' num2str(i) '_ThresholdActivation.mat'],'modelresults');
    clear modelresults
end
