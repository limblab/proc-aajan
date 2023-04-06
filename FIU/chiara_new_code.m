clear all
close all
clc
data=importdata('/Users/aajanquail/Downloads/new_labels_proc.mat');
%% consider only the neurons with firing rata higher than 1Hz
% thr_fr=1;
% T=length(data.spike_counts(:,1))/data.time_frame(end);
% fr=sum(data.smoothed_spik e_counts)./T;
% ind_low_fr=find(fr<thr_fr);
% data.smoothed_spike_counts(:,ind_low_fr)=[];
% data.spikes(ind_low_fr)=[];
% data.unit_names(ind_low_fr)=[];
% unit_num=30;
% mod_method='Perc';
% [mod_unit_idx,var_ord_neu] = Unit_Modulation_Check(data, unit_num, mod_method);
% ALTERNATIVE DEPTH OF MOD CODE
%[var_ord_neu, mod_unit_idx] = sort(var(data.smoothed_spike_counts), 'descend');
mod_neu=data.smoothed_spike_counts(:,:);
%% Encoding model
glm_distribution     =  'poisson';
n_folds=4;
cross_val=cvpartition(length(data.joint_angles),'KFold',n_folds);
n_units=size(mod_neu,2);
pR2_tr=zeros(n_folds,n_units); %gli indici qui li metto cosi perche prendo il + grande della partizione
VAF_tr=zeros(n_folds,n_units);
pR2_ts=zeros(n_folds,n_units);
R2_tr=zeros(n_folds,n_units);
VAF_ts=zeros(n_folds,n_units);
pR2_tr_emg=zeros(n_folds,n_units); %gli indici qui li metto cosi perche prendo il + grande della partizione
VAF_tr_emg=zeros(n_folds,n_units);
pR2_ts_emg=zeros(n_folds,n_units);
R2_ts=zeros(n_folds,n_units);
VAF_ts_emg=zeros(n_folds,n_units);
tot_len=size(mod_neu,1);
% kf = kron( 1:n_folds, ones(1,round(tot_len/n_folds)));
% kf(1:length(kf)-length(data.new_time_frames_EMG))=[];
for s = 1:n_folds
    splt1 = floor(size(mod_neu,1)*0.8);
    splt2 = ceil(size(mod_neu,1)*0.2);
    tr1 = ones(splt1,1);
    tr2 = zeros(splt2,1);
    ts1 = zeros(splt1,1);
    ts2 = ones(splt2,1);
    idxTrain = training(cross_val,s);%logical(cat(1,tr1,tr2));%training(cross_val,s);%
    idxTest = test(cross_val,s);%logical(cat(1,ts1,ts2));%test(cross_val,s);%

    yfit_tr=zeros(cross_val.TrainSize(s),size(mod_neu,2));%zeros(splt1,size(mod_neu,2));%zeros(cross_val.TrainSize(s),size(mod_neu,2));%
    yfit_ts=zeros(cross_val.TestSize(s),size(mod_neu,2));%zeros(splt2,size(mod_neu,2));%zeros(cross_val.TestSize(s),size(mod_neu,2));%
    yfit_tr_emg=zeros(cross_val.TrainSize(s),size(mod_neu,2));
    yfit_ts_emg=zeros(cross_val.TestSize(s),size(mod_neu,2));
%     yfit_tr=zeros(length(idxTrain),size(mod_neu,2));
%
%     yfit_ts=zeros(length(idxTest),size(mod_neu,2));
%     yfit_tr_emg=zeros(length(idxTrain),size(mod_neu,2));
%
%     yfit_ts_emg=zeros(length(idxTest),size(mod_neu,2));
    for neu_n=1: size(mod_neu,2)
        %%%%%% train
        mdl_kin= fitglm(data.joint_angles(idxTrain,:),mod_neu(idxTrain,neu_n)','distribution',glm_distribution);
        b(:,neu_n,s)=table2array(mdl_kin.Coefficients(:,1));
        yfit_tr(:,neu_n) = exp([ones(size(data.joint_angles(idxTrain,:),1),1), data.joint_angles(idxTrain,:)]*b(:,neu_n,s));
        pR2_tr(s,neu_n) = pseudoR2( mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)', mean(mod_neu(idxTrain,neu_n)));
        R2_tr(s,neu_n) = aajan_rsquared(mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)');
        %VAF_tr(s,neu_n) = compute_vaf(mod_neu(idxTrain,neu_n), yfit_tr(:,neu_n));
        %%%%%%% test
        yfit_ts(:,neu_n) = exp([ones(size(data.joint_angles(idxTest,:),1),1), data.joint_angles(idxTest,:)]*b(:,neu_n,s));
        pR2_ts(s,neu_n) = pseudoR2( mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)', mean(mod_neu(idxTest,neu_n)));
        R2_ts(s,neu_n) = aajan_rsquared(mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)');
        %VAF_ts(s,neu_n) = compute_vaf(mod_neu(idxTest,neu_n), yfit_ts(:,neu_n));
        %mdl_emg= fitglm(data.EMG(idxTrain,:),mod_neu(idxTrain,neu_n)','distribution',glm_distribution);
        %b_emg(:,neu_n,s)=table2array(mdl_emg.Coefficients(:,1));
        %yfit_tr_emg(:,neu_n) = exp([ones(size(data.EMG(idxTrain,:),1),1), data.EMG(idxTrain,:)]*b_emg(:,neu_n,s));
        %pR2_tr_emg(s,neu_n) = pseudoR2( mod_neu(idxTrain,neu_n)', yfit_tr_emg(:,neu_n)', mean(mod_neu(idxTrain,neu_n)));
        %VAF_tr_emg(s,neu_n) = compute_vaf(mod_neu(idxTrain,neu_n), yfit_tr_emg(:,neu_n));
        %yfit_ts_emg(:,neu_n) = exp([ones(size(data.EMG(idxTest,:),1),1), data.EMG(idxTest,:)]*b_emg(:,neu_n,s));
        %pR2_ts_emg(s,neu_n) = pseudoR2( mod_neu(idxTest,neu_n)', yfit_ts_emg(:,neu_n)', mean(mod_neu(idxTest,neu_n)));
        %VAF_ts_Emg(s,neu_n) = compute_vaf(mod_neu(idxTest,neu_n), yfit_ts_emg(:,neu_n));
    end
    %%%%%%% general metrics
    pR2_tr_m=mean(pR2_tr,1);
    pR2_ts_m=mean(pR2_ts,1);
    R2_tr_m=mean(R2_tr,1);
    R2_ts_m=mean(R2_ts,1);
%     VAF_tr_m=mean(VAF_tr,1);
%     VAF_ts_m=mean(VAF_ts,1);
%     pR2_tr_m_emg=mean(pR2_tr_emg,1);
%     pR2_ts_m_emg=mean(pR2_ts_emg,1);
%     VAF_tr_m_emg=mean(VAF_tr_emg,1);
%     VAF_ts_m_emg=mean(VAF_ts_emg,1);
    %     figure;
    %     imagesc(b(:,:,s));
    %     title('Parameter value');
    %     clim([-15 15])
    %     %clim([-max(max(abs(b(:,:,s)))) +max(max(abs(b(:,:,s))))]);
    %     colorbar;
    %     colormap(autumn);
end
nn=1;
%%
% evaluation of which k to choose
figure;
subplot(1,2,1);
[h,L,MX,MED,bw]=violin(pR2_tr_m(1:end,:)');
title('Training pR^2')
subplot(1,2,2);
[h,L,MX,MED,bw]=violin(pR2_ts_m(1:end,:)');
title('Test pR^2')
sgtitle('GLM with shuffling and x-validation pR^2')
%%
% evaluation of which k to choose
figure;
subplot(1,2,1);
[h,L,MX,MED,bw]=violin(R2_tr_m(1:end,:)');
title('Training R^2')
subplot(1,2,2);
[h,L,MX,MED,bw]=violin(R2_ts_m(1:end,:)');
title('Test R^2')
sgtitle('GLM with shuffling and x-validation R^2')
%%
disp(mean(pR2_tr_m))
disp(mean(pR2_ts_m))
disp(mean(R2_tr_m))
disp(mean(R2_ts_m))
