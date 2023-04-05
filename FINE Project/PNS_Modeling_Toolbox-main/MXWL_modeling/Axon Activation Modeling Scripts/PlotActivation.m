%% Modeling code. Hopefully to generate plots for SfN poster. 

%do models at the threshold PW and vary PA to get threshold activation
%define thresh activation as 1st 100 axons activated
threshPW = [25, 25, 25, 25, 23, 24, 18, 20, 23, 13, 13 ,16, 20, 25, 20]./1000; %us
minaxons = [70,70,70,68,83,68,825,825,825,300,200,400,350,175,350];
maxaxons = [950,950,950,860,1000,860,4950,4950,4950,3600,2300,4500,4000,2000,4000];
plottingorder = [1 2 3 4 5 8 7 6 9 10 11 12 13 14 15];
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
for i = plottingorder %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString '_axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
        end
        %initialize scatter size vector
        fasccount = 1;
        for j = 1:length(axondata.fasciclesfinal)
            fascind(j,1) = fasccount;
            fascind(j,2) = fasccount + axondata.fasciclesfinal{1,j}.nAxons - 1;
            fasccount = fasccount + axondata.fasciclesfinal{1,j}.nAxons;
        end
        sz = 16.*ones(1,length(axondata.allaxons.nodeX(1,:)));
        sz(fascind(4,1):fascind(17,2)) = 4;
        %plot axon location - initial color = black (no stim); will plot over
        %to show axons that are activated
        scatter(axondata.allaxons.nodeX(1,:),axondata.allaxons.nodeY(1,:),4,'o','MarkerEdgeColor','none','MarkerFaceColor',[0.9 0.9 0.9]);
        alpha(.1)
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PA = -0.01; %mA
    numactive = 0;
    
    while sum(numactive) < minaxons(i) %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],threshPW(i));
        PA = PA - 0.01; %increase cathode amplitude
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds)+(2*rand(1)-1)/100,axondata.allaxons.nodeY(1,active_inds)+(2*rand(1)-1)/100,sz(active_inds),'o','MarkerFaceColor',scatter_colors(i,:),'MarkerEdgeColor','none'); %scatter colors should match colors from database
    for j = 1:length(axondata.fasciclesfinal)
        if sum(double(active_inds>=fascind(j,1) & active_inds<=fascind(j,2))) > 5
            sz(fascind(j,1):fascind(j,2)) = ceil(sz(fascind(j,1):fascind(j,2))/2);
        end
    end
    %sz(active_inds) = ceil(sz(active_inds)/2); 
    %alpha(0.2);
    %outline activated areas in each fascicle
    
%     actxy = [axondata.allaxons.nodeX(1,active_inds)',axondata.allaxons.nodeY(1,active_inds)'];
%     sk = ones(2,2);
%     for j = 1:length(axondata.fasciclesfinal)
%         %create grid
%         minx = min(axondata.fasciclesfinal{1,j}.vertices(:,1));
%         maxx = max(axondata.fasciclesfinal{1,j}.vertices(:,1));
%         dx = (maxx-minx)/10;
%         xvec = minx-2*dx:dx:maxx+2*dx;
%         miny = min(axondata.fasciclesfinal{1,j}.vertices(:,2));
%         maxy = max(axondata.fasciclesfinal{1,j}.vertices(:,2));
%         dy = (maxy-miny)/10;
%         yvec = miny-2*dy:dy:maxy+2*dy;
%         [X,Y] = meshgrid(xvec(1:end-1),yvec(1:end-1));
%         activegrd = zeros(length(xvec)-1,length(yvec)-1);
%         for k = 1:length(xvec)-1
%             for l = 1:length(yvec)-1
%                 activegrd(k,l) = sum(double(actxy(:,1)>=xvec(k) & actxy(:,1)<xvec(k+1) & actxy(:,2)>=yvec(l) & actxy(:,2)<yvec(l+1))); 
%             end
%         end
%         if max(max(activegrd)) > 0;
%             activegrdsmooth = filter2(sk,activegrd);
%             activegrdsmooth(activegrdsmooth>0) = 1;
%             contourgrd = contour(X,Y,activegrdsmooth,[0,1]);
%             index1=find(contourgrd(1,:)==1);
%             [~,index2]=max(contourgrd(2,index1));
% 
%             start_col=index1(index2)+1;
%             end_col=index1(index2)+contourgrd(2,index1(index2));
%             contourxy=contourgrd(:,start_col:end_col)';
% 
%             [in,on] = inpolygon(contourxy(:,1),contourxy(:,2),axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2));
%             in(end) = [];
%             if sum(double(in))<2
%                 [in,on] = inpolygon(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),contourxy(:,1),contourxy(:,2));
%                 in(end) = [];
%             end
% 
%             plot(contourxy(in,1),contourxy(in,2),'Color',scatter_colors(i,:),'LineWidth',2);
%         end
%     end
%     exy = confellipse2([axondata.allaxons.nodeX(1,active_inds)',axondata.allaxons.nodeY(1,active_inds)'],0.67);
%     for j = 1:length(axondata.fasciclesfinal)
%         [in,on] = inpolygon(exy(:,1),exy(:,2),axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2));
%         in(end) = [];
%         if sum(double(in))<2
%             [in,on] = inpolygon(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),exy(:,1),exy(:,2));
%             in(end) = [];
%         end
%         plot(exy(in,1),exy(in,2),'Color',scatter_colors(i,:),'LineWidth',2);
%     end

    drawnow
    disp(['C' num2str(i) ': ' num2str(PA+0.01)]);
    %save out results
    modelresults{i}.Params = [PA + 0.01, threshPW(i)];
    modelresults{i}.all_active = all_active;
    modelresults{i}.numactive = numactive;
    modelresults{i}.axondata = axondata;
end
    save([NerveNameString '_ThresholdActivationPASweepResults.mat'],'modelresults');
    clear modelresults

beep
beep
beep
%% PW sweep
PA = -0.07; % mA
for i = plottingorder %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString '_axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
        end
        %initialize scatter size vector
        fasccount = 1;
        for j = 1:length(axondata.fasciclesfinal)
            fascind(j,1) = fasccount;
            fascind(j,2) = fasccount + axondata.fasciclesfinal{1,j}.nAxons - 1;
            fasccount = fasccount + axondata.fasciclesfinal{1,j}.nAxons;
        end
        sz = 16.*ones(1,length(axondata.allaxons.nodeX(1,:)));
        %sz(fascind(4,1):fascind(17,2)) = 4;
        %plot axon location - initial color = black (no stim); will plot over
        %to show axons that are activated
        scatter(axondata.allaxons.nodeX(1,:),axondata.allaxons.nodeY(1,:),4,'o','MarkerEdgeColor','none','MarkerFaceColor',[0.9 0.9 0.9]);
        alpha(.1)
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PW = 0.010; %10 us
    numactive = 0;
    
    while sum(numactive) < maxaxons(i) %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],PW);
        PW = PW + 0.001; %increase cathode amplitude
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds)+(2*rand(1)-1)/100,axondata.allaxons.nodeY(1,active_inds)+(2*rand(1)-1)/100,sz(active_inds),'o','MarkerFaceColor',scatter_colors(i,:),'MarkerEdgeColor','none'); %scatter colors should match colors from database
    for j = 1:length(axondata.fasciclesfinal)
        if sum(double(active_inds>=fascind(j,1) & active_inds<=fascind(j,2))) > 5
            sz(fascind(j,1):fascind(j,2)) = ceil(sz(fascind(j,1):fascind(j,2))/2);
        end
    end

    drawnow
    disp(['C' num2str(i) ': ' num2str(PW-0.001)]);
    %save out results
    modelresults{i}.Params = [PA, PW-0.001];
    modelresults{i}.all_active = all_active;
    modelresults{i}.numactive = numactive;
    modelresults{i}.axondata = axondata;
end
    save([NerveNameString '_ThresholdActivationPWSweepResults.mat'],'modelresults');
    clear modelresults

beep
beep
beep

%% PA sweep looking at fascicle selectivity
for i = 1:15 %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString '_axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
        end
        %plot axon location - initial color = black (no stim); will plot over
        %to show axons that are activated
        scatter(axondata.allaxons.nodeX(1,:),axondata.allaxons.nodeY(1,:),4,'o','MarkerEdgeColor','none','MarkerFaceColor','k');
        alpha(.1)
        drawnow;
        axis equal;
    end
    %find model's threshold PA
    PA = -0.01; %mA
    numactive = 0;
    spillover = 0;
    while max(numactive) < minaxons(i) && spillover < 10 %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],threshPW(i));
        spillover = sum(numactive) - max(numactive);
        PA = PA - 0.01; %increase cathode amplitude
    end
    %want to look at activation without the spillover
    if spillover >= 10
        PA = PA + 0.02; %undo the PA-0.01 in the while loop. and undo the last increase in PA that resulted in all of the spillover
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],threshPW(i));
        spillover = sum(numactive) - max(numactive);
    else
        PA = PA + 0.1; %undo the PA-0.01 in the while loop.
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds),axondata.allaxons.nodeY(1,active_inds),6,scatter_colors(i,:),'filled'); %scatter colors should match colors from database
    drawnow
    disp(['C' num2str(i) ' PA: ' num2str(PA)]);
    disp(['C' num2str(i) ' active axon: ' num2str(max(numactive))]);
    disp(['C' num2str(i) ' spillover: ' num2str(sum(numactive) - max(numactive))]);

    %save out results
    modelresults{i}.Params = [PA, threshPW(i)*1000];
    modelresults{i}.all_active = all_active;
    modelresults{i}.numactive = numactive;
    modelresults{i}.axondata = axondata;
end
    save([NerveNameString '_FascicleSelectiveThresholdActivationPASweepResults.mat'],'modelresults');
    clear modelresults

beep
beep
beep


%% PW sweep looking at fascicle selectivity

PA = -0.07; %mA
for i = 1:15 %number of contacts
    if i == 1;
        %plot fascicle oulines and locations of all nerves (open any file
        %to do so)
        load([NerveNameString '_axondata_C1_pos1mA.mat']);
        figure; hold on
        for j = 1:length(axondata.fasciclesfinal);
            %plot fascicle outlines
            plot(axondata.fasciclesfinal{1,j}.vertices(:,1),axondata.fasciclesfinal{1,j}.vertices(:,2),'k','LineWidth',1.5);
        end
        %plot axon location - initial color = black (no stim); will plot over
        %to show axons that are activated
        scatter(axondata.allaxons.nodeX(1,:),axondata.allaxons.nodeY(1,:),4,'o','MarkerEdgeColor','none','MarkerFaceColor','k');
        alpha(.1)
        drawnow;
        axis equal;
    end
    %find model's threshold PW
    PW = 0.010; %10us
    numactive = 0;
    spillover = 0;
    while max(numactive) < minaxons(i) && spillover < 10 %until threshold reached
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],PW);
        spillover = sum(numactive) - max(numactive);
        PW = PW + 0.001; %increase PW by 1us
    end
    %want to look at activation without the spillover
    if spillover >= 10
        PW = PW - 0.002; %undo the PW + 0.001 in the while loop. and undo the last increase in PW that resulted in all of the spillover
        [all_active,numactive] = ApplyStim_Izad(NerveNameString,[i,PA],PW);
        spillover = sum(numactive) - max(numactive);
    else
        PW = PW - 0.001; %undo the PW + 0.001 in the while loop.
    end
    
    %plot results
    active_inds = find(all_active == 1);
    scatter(axondata.allaxons.nodeX(1,active_inds),axondata.allaxons.nodeY(1,active_inds),6,scatter_colors(i,:),'filled'); %scatter colors should match colors from database
    drawnow
    disp(['C' num2str(i) ' PW: ' num2str(PW*1000)]);
    disp(['C' num2str(i) ' active axon: ' num2str(max(numactive))]);
    disp(['C' num2str(i) ' spillover: ' num2str(sum(numactive) - max(numactive))]);

    %save out results
    modelresults{i}.Params = [PA, PW*1000];
    modelresults{i}.all_active = all_active;
    modelresults{i}.numactive = numactive;
    modelresults{i}.axondata = axondata;
end
    save([NerveNameString '_FascicleSelectiveThresholdActivationPASweepResults.mat'],'modelresults');
    clear modelresults

beep
beep
beep
