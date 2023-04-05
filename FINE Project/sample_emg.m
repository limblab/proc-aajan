function [pw_resampled, emg_resampled, handles] = sample_emg(pw, emg, pw_sampled, emg_sampled, pw_to_sample,handles)
%% Function samples signal at input values
% Function will sample signal emg at closest possible value to
% pw_to_sample.
%
% Inputs:
%   pw: vector (1xn) with all possible values of pw
%   emg: vector (mxn) with ground truth emg values (only for simulation)
%   pw_sampled: vector (1xn) with all pw values currently sampled
%   emg_sampled: vector (1xn) with all emg values currently sampled
%   pw_to_sample: (float) pw value to be sampled
% Outputs:
%   pw_resampled: vector including new pw to be sampled
%   emg_resampled: vector with sampled emg values including emg at new pw
%   
% Jessica Abreu - jxd484@case.edu - 02/2020 
%%
    [idx, new_pw] = pick_closest_pw(pw_to_sample, pw);
    pw_resampled = [pw_sampled new_pw];
    [pw_resampled,i_sort] = sort(pw_resampled,'ascend');
    

    stim_index = new_pw
    handles = RecDaq(handles,stim_index)
    emg_point = (handles.MeasuredValues.temp_data'-handles.MeasuredValues.minEmg)/handles.MeasuredValues.maxEmg;
    
    emg_sampled = horzcat(emg_sampled, emg_point);
    emg_resampled = emg_sampled(:, i_sort);
end