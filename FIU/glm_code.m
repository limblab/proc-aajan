% clear all
% close all
% clc
% data_20220203=load('/Users/aajanquail/Downloads/20220203_data.mat');
% data_20220210_001=load('/Users/aajanquail/Downloads/20220210_001_data.mat');
% data_20220210_002=load('/Users/aajanquail/Downloads/20220210_002_data.mat');

% Encoding model
% data = data_20220210_002;
data = load('/Users/aajanquail/Desktop/Jupyter_Notebooks/Miller_Lab/FIU/neural_data/for_GLM/20220405_Pop_FR_002_unsorted_binned_smoothed.mat');
input = data.data.joint_angles;
output = data.data.smoothed_spike_counts;

input = fillmissing(input,'linear');
% p = randperm(18000);
% input = input(p, :);
% output = output(p, :);
%%
train_split = floor(size(input,1)*0.8);
train_x = input(1:train_split,:);
train_y = output(1:train_split,:);
test_x = input(train_split+1:end,:);
test_y = output(train_split+1:end,:);

yfit_tr=zeros(size(train_y,1),size(train_y,2));
yfit_ts=zeros(size(test_y,1),size(test_y,2));

pR2_tr=zeros(size(test_y,2));
pR2_ts=zeros(size(test_y,2));
%
%%
glm_distribution = 'poisson';

for neu_n=1: size(train_y,2)
    disp(neu_n)
    %%%%%% train with joint angles as input
    
    %%% b are coefficients of glmfit
    %%% exp comes from paper sent by Chiara
    [b(:,neu_n),~,s_temp] = glmfit(train_x,train_y(:,neu_n)',glm_distribution);
    yfit_tr(:,neu_n) = exp([ones(size(train_x,1),1), train_x]*b(:,neu_n));
    pR2_tr(neu_n) = pseudoR2(train_y(:,neu_n)', yfit_tr(:,neu_n)', mean(train_y(:,neu_n)));

    %%%%%%% test with joint angles as input

    yfit_ts(:,neu_n) = exp([ones(size(test_x,1),1), test_x]*b(:,neu_n));
    pR2_ts(neu_n) = pseudoR2(test_y(:,neu_n)', yfit_ts(:,neu_n)', mean(test_y(:,neu_n)));

end
%%%%%%% general metrics
%%% avg of pr2, VAF across all neurons (tr = train, ts = test) for
%%% joint
pR2_tr_m=mean(pR2_tr,1);
pR2_ts_m=mean(pR2_ts,1);