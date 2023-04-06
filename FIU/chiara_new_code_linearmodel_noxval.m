clear all
close all
clc
data=importdata('/Users/aajanquail/Downloads/new_labels_proc.mat');

mod_neu=data.smoothed_spike_counts(:,:);
%% Encoding model
glm_distribution     =  'poisson';
n_folds=1;%4;
%cross_val=cvpartition(length(data.joint_angles),'KFold',n_folds);
n_units=size(mod_neu,2);
pR2_tr=zeros(n_folds,n_units);
VAF_tr=zeros(n_folds,n_units);
R2_tr=zeros(n_folds,n_units);
pR2_ts=zeros(n_folds,n_units);
VAF_ts=zeros(n_folds,n_units);
R2_ts=zeros(n_folds,n_units);
tot_len=size(mod_neu,1);

% XVAL for s = 1:n_folds
splt1 = floor(size(mod_neu,1)*0.8);
splt2 = ceil(size(mod_neu,1)*0.2);
tr1 = ones(splt1,1);
tr2 = zeros(splt2,1);
ts1 = zeros(splt1,1);
ts2 = ones(splt2,1);
idxTrain = logical(cat(1,tr1,tr2));% XVAL training(cross_val,s);%
idxTest = logical(cat(1,ts1,ts2));% XVAL test(cross_val,s);%

yfit_tr=zeros(splt1,size(mod_neu,2));%XVAL zeros(cross_val.TrainSize(s),size(mod_neu,2));
yfit_ts=zeros(splt2,size(mod_neu,2));%XVAL zeros(cross_val.TestSize(s),size(mod_neu,2));

for neu_n=1: size(mod_neu,2)
    %%%%%% train
    mdl_kin= fitlm(data.joint_angles(idxTrain,:),mod_neu(idxTrain,neu_n)');
    yfit_tr(:,neu_n) = predict(mdl_kin,data.joint_angles(idxTrain,:));
    pR2_tr(1,neu_n) = pseudoR2( mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)', mean(mod_neu(idxTrain,neu_n)));
    R2_tr(1,neu_n) = aajan_rsquared(mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)');
    %XVAL pR2_tr(s,neu_n) = pseudoR2( mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)', mean(mod_neu(idxTrain,neu_n)));
    %XVAL R2_tr = aajan_rsquared(mod_neu(idxTrain,neu_n)', yfit_tr(:,neu_n)');
    %VAF_tr(s,neu_n) = compute_vaf(mod_neu(idxTrain,neu_n), yfit_tr(:,neu_n));
    %%%%%%% test
    yfit_ts(:,neu_n) = predict(mdl_kin,data.joint_angles(idxTest,:));
    pR2_ts(1,neu_n) = pseudoR2( mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)', mean(mod_neu(idxTest,neu_n)));
    R2_ts(1,neu_n) = aajan_rsquared(mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)');
    %XVAL pR2_ts(s,neu_n) = pseudoR2( mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)', mean(mod_neu(idxTest,neu_n)));
    %XVAL R2_ts(s,neu_n) = aajan_rsquared(mod_neu(idxTest,neu_n)', yfit_ts(:,neu_n)');
end
%%%%%%% general metrics
% XVAL pR2_tr_m=mean(pR2_tr,1);
% XVAL pR2_ts_m=mean(pR2_ts,1);
% XVAL R2_tr_m=mean(R2_tr,1);
% XVAL R2_ts_m=mean(R2_ts,1);
% XVAL end
%%
disp(mean(R2_tr))
disp(mean(R2_ts))
%%
% evaluation of which k to choose
figure;
subplot(1,2,1);
[h,L,MX,MED,bw]=violin(pR2_tr_m(1:end,:)');
title('Training pR^2')
subplot(1,2,2);
[h,L,MX,MED,bw]=violin(pR2_ts_m(1:end,:)');
title('Test pR^2')
%%
% evaluation of which k to choose
figure;
subplot(1,2,1);
% XVAL [h,L,MX,MED,bw]=violin(R2_tr_m(1:end,:)');
[h,L,MX,MED,bw]=violin(R2_tr(1:end,:)');
title('Training R^2')
subplot(1,2,2);
% XVAL [h,L,MX,MED,bw]=violin(R2_ts_m(1:end,:)');
[h,L,MX,MED,bw]=violin(R2_ts(1:end,:)');
title('Test R^2')

sgtitle('Linear Model with no x-validation R^2')