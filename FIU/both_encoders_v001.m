clear all
close all
clc
data=importdata('/Users/aajanquail/Desktop/Jupyter_Notebooks/Miller_Lab/FIU/neural_data/for_GLM/20220405_Pop_FR_002_unsorted_binned_smoothed.mat');
%%
data.new_time_frames_EMG=data.joint_angle_time_frame;

data.joint_angles = fillmissing(data.joint_angles,'linear');
%% Encoding model

glm_distribution     =  'poisson';
n_folds=4;
% cross_val=cvpartition(length(data.joint_angles),'KFold',n_folds);
n_units=size(data.smoothed_spike_counts,2);

pR2_tr=zeros(n_folds,n_units); %gli indici qui li metto cosi perche prendo il + grande della partizione
VAF_tr=zeros(n_folds,n_units);
pR2_ts=zeros(n_folds,n_units);
VAF_ts=zeros(n_folds,n_units);

pR2_tr_emg=zeros(n_folds,n_units); %gli indici qui li metto cosi perche prendo il + grande della partizione
VAF_tr_emg=zeros(n_folds,n_units);
pR2_ts_emg=zeros(n_folds,n_units);
VAF_ts_emg=zeros(n_folds,n_units);
tot_len=size(data.smoothed_spike_counts,1);

kf = kron( 1:n_folds, ones(1,round(tot_len/n_folds)));
kf(1:length(kf)-length(data.new_time_frames_EMG))=[];
for s = 1:n_folds

    idxTrain = find(kf ~= s);
    idxTest = find(kf == s);
    
    yfit_tr=zeros(length(idxTrain),size(data.smoothed_spike_counts,2));

    yfit_ts=zeros(length(idxTest),size(data.smoothed_spike_counts,2));
    yfit_tr_emg=zeros(length(idxTrain),size(data.smoothed_spike_counts,2));

    yfit_ts_emg=zeros(length(idxTest),size(data.smoothed_spike_counts,2));


    %     idxTrain = training(cross_val,s);
    %
    %     idxTest = test(cross_val,s);

    for neu_n=1: size(data.smoothed_spike_counts,2)
        %%%%%% train

        [b(:,neu_n,s),~,s_temp] = fitglm(data.joint_angles(idxTrain,:),data.smoothed_spike_counts(idxTrain,neu_n)',glm_distribution);
        yfit_tr(:,neu_n) = exp([ones(size(data.joint_angles(idxTrain,:),1),1), data.joint_angles(idxTrain,:)]*b(:,neu_n));
        pR2_tr(s,neu_n) = pseudoR2( data.smoothed_spike_counts(idxTrain,neu_n)', yfit_tr(:,neu_n)', mean(data.smoothed_spike_counts(idxTrain,neu_n)));

        %%%%%%% test

        yfit_ts(:,neu_n) = exp([ones(size(data.joint_angles(idxTest,:),1),1), data.joint_angles(idxTest,:)]*b(:,neu_n));
        pR2_ts(s,neu_n) = pseudoR2( data.smoothed_spike_counts(idxTest,neu_n)', yfit_ts(:,neu_n)', mean(data.smoothed_spike_counts(idxTest,neu_n)));

    end
    %%%%%%% general metrics
    pR2_tr_m=mean(pR2_tr,1);
    pR2_ts_m=mean(pR2_ts,1);

end
nn=1;
%%
figure;
subplot(2,1,2);
plot(data.new_time_frames_EMG(1:size(yfit_ts,1)),  yfit_ts(:,nn),'b');
hold on
plot(data.new_time_frames_EMG(1:size(yfit_ts,1)),data.smoothed_spike_counts(idxTest,nn),'k');
title(strcat('Prediction - Neuron ', num2str(nn), 'pR^2',num2str(pR2_ts(4,nn))));
xlabel('Time (s)','FontSize', 12)
ylabel('Prediction','FontSize', 12)
legend({'Kinematic Prediction','Real Values'},'FontSize',12);
set(gca,'FontSize',18)
subplot(2,1,1);
plot(data.new_time_frames_EMG(1:size(yfit_ts_emg,1)),yfit_ts_emg(:,nn),'r');
hold on
plot(data.new_time_frames_EMG(1:size(yfit_ts,1)),data.smoothed_spike_counts(idxTest,nn),'k');
title(strcat('Prediction - Neuron ', num2str(nn),'pR^2',num2str(pR2_ts_emg(4,nn))));
xlabel('Time (s)','FontSize', 12)
ylabel('Prediction','FontSize', 12)
legend({'EMG prediction','Real Values'},'FontSize',12);
set(gca,'FontSize',18)
%%
nn=18;
figure;
plot(data.new_time_frames_EMG(1:size(yfit_ts,1)),  yfit_ts(:,nn),'b');
hold on
plot(data.new_time_frames_EMG(1:size(yfit_ts,1)),data.smoothed_spike_counts(idxTest,nn),'k');
plot(data.new_time_frames_EMG(1:size(yfit_ts_emg,1)),yfit_ts_emg(:,nn),'r');
title(strcat('Prediction - Neuron ', num2str(nn)));
xlabel('Time (s)','FontSize', 12)
ylabel('Prediction','FontSize', 12)
legend({'Kinematic Prediction','Real Values','EMG prediction'},'FontSize',12);
set(gca,'FontSize',18)
% %% Predictions and metric plots
% neuron=1;
% figure;
% plot(yfit_ts(:,neuron));
% hold on
% plot(data.smoothed_spike_counts(idxTest,neuron));
%
%%
f3=figure;
%boxplot([pR2_ts_rest_emg', pR2_ts_emg',pR2_ts_rest_kin', pR2_ts_kin'],'Notch','on','Labels',{'EMG Rest and activity','EMG Activity','Kin Rest and activity','Kin Activity'});
boxplot([pR2_ts_m_emg',pR2_ts_m'],'Notch','on','Labels',{'EMG encoder','Kin encoder'});
set(gca,'FontSize',14)
h = findobj(gca,'Tag','Box');
colors=[ 0 0 1; 1 0 0;];
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',.5);
end
title('pR^2');
ylim([-0.1 0.6]);
%saveas(f3,strcat('/Users/chiaraciucci/Documents/lag/20220309/', 'b_lag_',num2str(round(lag_act*10^3))),'png');

%%
figure;
plot(pR2_ts_m_emg,pR2_ts_m,'o');
xlim([0 0.6]);
ylim([0 0.6]);
refline([1 0]);
xlabel('EMG pR2');
ylabel('KIN pR2');
title('Encoders comparison')
set(gca,'FontSize',14)
%%
figure;
sgtitle('Metric for each neuron');
subplot(2,1,1);
bar(pR2_tr_m);
title('training pR2');
subplot(2,1,2);
bar(pR2_ts_m);
title('test pR2');
figure;
sgtitle('Metric for each neuron');
subplot(2,1,1);
bar(VAF_tr_m);
title('training Vaf');
subplot(2,1,2);
bar(VAF_ts_m);
title('test Vaf');
%%
n_bin_h=20;
f1= figure;
sgtitle('Metric distribution pR^2 kinematic encoder');
subplot(2,1,1);
histogram(pR2_tr_m,n_bin_h);
title('training pR2');
subplot(2,1,2);
histogram(pR2_ts_m,n_bin_h);
title('test pR2');
f2= figure;
sgtitle('Metric distribution pR^2 EMG encoder');
subplot(2,1,1);
histogram(pR2_tr_m_emg,n_bin_h);
title('training pR^2');
subplot(2,1,2);
histogram(pR2_ts_m_emg,n_bin_h);
title('test pR^2');
saveas(f1,strcat('/Users/chiaraciucci/Documents/lag/20220309/', 'lag_',num2str(round(lag_act*10^3)),'kin_enc'),'png');
saveas(f2,strcat('/Users/chiaraciucci/Documents/lag/20220309/', 'lag_', num2str(round(lag_act*10^3)),'emg_enc'),'png');
