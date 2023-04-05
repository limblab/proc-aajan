function [handles] = sample_recruitment_gomperz_fit(pw, emg, initial_points, initial_fit, lower_bound, upper_bound, emg_diff_lim, plot_results,handles)
%% Function samples recruitment curve assuming gomperz model
%
% Inputs:
%   pw: (1 x n) full spectrum of possible pulse widths. 
%   emg: (m x n) ground truth normalized emg vector for emg at input pulse widths. m
%   is the number of muscles (or measured outputs).
%   initial_points: (integer) number of points for initial sampling =>
%   recommended 5.
%   initial_fit: (vector) => (a, b, c) initial parameters  to fit gomperz
%   curves. Recommended: [0.5, 125, 0.1]
%   lower_bound: (vector) => lower bound for (a, b, c). Recommended:
%   [0,5,0]
%   upper_bound: (vector) => upper bound for (a, b, c). Recommended: [1.2, inf, 0.5]
%   emg_diff_lim: (float) => max normalized difference allowed in EMG.
%   Recommended: 0.25
%   plot_results: (0/1) if 0, no plot. if 1, plots results.
% Outputs:
%   param_vec: (n x 3) vector containing (a, b, c) for all channels
%   f_vec: (n x 1) containing fit objects for all channels
%   gof_vec: (n x 1) vector containing goodnees of fit objects
%   lxb_vec: (n x 1) left boundary calculated as 1/8 of the curve amplitude
%   rxb_vec: (n x 1) right boundary calculated as 7/8 of the curve
%   amplitude
%   c_vec: (n x 1) estimated center of the curves
%   number_of_sampled_points: total number of sampled points
%   pw_sampled: pw points that were sampled
%   emg_sampled: emg at sampled pw values
%
% Jessica Abreu - jxd484@case.edu - 02/2020
%%
% Initial sampling
pw_min = min(pw); pw_max = max(pw);
number_of_muscles = size(emg, 1); %%NEEDS TO BE ALTERED
pw_to_sample  = linspace(pw_min, pw_max, initial_points);
[idx, pw_samp] = pick_closest_pw(pw_to_sample, pw);
% Checking if all elements are different
% Won't happen in actual experiment, but may happen when testing with low
% resolution datasets
all_unique = @(x)isequal(length(x), length(unique(x)));
assert(all_unique(pw_samp), 'Repeated elements in pw_samp for initial sampling')
% Passed assertion, now sampling EMG and refining until all curves have at
% least a point in target region (1/8-7/8 of the rising part). As long as
% resolution allows, and only if center is in domain.

% get initial emg values
for i = 1:initial_points
    stim_index = pw_samp(i)
    handles = RecDaq(handles,stim_index)
    sampled_emg(:,i) = handles.MeasuredValues.temp_data;
end
handles.MeasuredValues.raw_sampled_emg = sampled_emg;
handles.MeasuredValues.minEmg = min(sampled_emg,[],2);

handles.MeasuredValues.maxEmg = max(max(sampled_emg-repmat(handles.MeasuredValues.minEmg,[1,size(sampled_emg,2)]),[],2));
sampled_emg = (sampled_emg-repmat(handles.MeasuredValues.minEmg,[1,size(sampled_emg,2)]))/handles.MeasuredValues.maxEmg;

[param_vec, f_vec, gof_vec, lxb_vec, rxb_vec, c_vec] = fit_gomperz_channels(pw_samp, sampled_emg, initial_fit, lower_bound, upper_bound);
flag_good_curve = zeros(number_of_muscles, 1);

for i=1:number_of_muscles
    if any(and(and(pw_samp>=lxb_vec(i), pw_samp<=rxb_vec(i)), c_vec(i)<pw_max))
        flag_good_curve(i) = 1; 
    elseif c_vec(i) < pw_max
        p_pos= pw_samp(c_vec(i) - pw_samp>0); lb = p_pos(end);
        p_neg= pw_samp(c_vec(i) - pw_samp<0); rb = p_neg(1);
        to_sample = lb + (rb - lb)/2;
        to_sample = pick_closest_pw(to_sample, pw);
        while and(and(and(flag_good_curve(i) == 0, to_sample<pw_max), not(any(to_sample==pw_samp))), c_vec(i)<pw_max)
            [pw_samp, sampled_emg, handles] = sample_emg(pw, emg, pw_samp, sampled_emg, to_sample,handles);
            [param_vec, f_vec, gof_vec, lxb_vec, rxb_vec, c_vec] = fit_gomperz_channels(pw_samp, sampled_emg, initial_fit, lower_bound, upper_bound);
            if any(and(and(pw_samp>=lxb_vec(i), pw_samp<=rxb_vec(i)), c_vec(i)<pw_max))
                flag_good_curve(i) = 1;
            elseif c_vec(i)<pw_max
                p_pos= pw_samp(c_vec(i) - pw_samp>0); lb = p_pos(end);
                p_neg= pw_samp(c_vec(i) - pw_samp<0); rb = p_neg(1);
                to_sample = lb + (rb - lb)/2;
            end
        end
    end
end
if plot_results == 1
    figure(2);
    subplot(1, 2, 1);
    hold on
    for i=1:size(emg,1)
        plot(f_vec{i},handles.settings.colors{i},pw_samp, sampled_emg(i, :),[handles.settings.colors{i} '*'])
    end
    title({'Targeting rising', ['Number of Points: '  num2str(size(pw_samp, 2)-1)]}, 'FontSize', 16)
    ylabel('Normalized EMG', 'FontSize', 14)
    xlabel('PW', 'FontSize', 14)
    f=(get(gca,'Children'));
    ylim([0 1.1])
    legend(f((fliplr(2*(1:size(emg,1))-1))),handles.settings.muscles, 'FontSize', 12)
end
% All suitable curves (center smaller than max pw and enough resolution)
% have at least a point in target zone.
%% Here we are refining the curves by sampling more points in the target region and making sure the differences are within max
dif = abs(diff(sampled_emg,[], 2));
eligible = ones(size(dif,1), size(dif,2));
dif_eligible_idx = and(dif>=emg_diff_lim, eligible);
while any(dif_eligible_idx(:))
    dif_elegible_values = dif(dif_eligible_idx);
    max_dif_elegible =  max(dif_elegible_values(:));
    [x, y] = find(dif==max_dif_elegible);
    n = param_vec(x, 1) * exp(-param_vec(x, 2)*exp(-param_vec(x, 3)* pw_samp(y)));
    m = param_vec(x, 1) * exp(-param_vec(x, 2)*exp(-param_vec(x, 3)* pw_samp(y+1)));
    g = log((n+m)/(2*param_vec(x, 1)));
    pw_to_sample = (-1/param_vec(x, 3))*log(-g/param_vec(x, 2));
    [idx, pw_to_sample] = pick_closest_pw(pw_to_sample, pw);
    % If the resolution is too low for a point to be sampled between the
    % boundaries, than that dif is ineligible
    if any(pw_to_sample==pw_samp)
        % If is trying to repeat a point, likely due to lack of resolution
        % => Make sure code does not get trapped in infinite loop by
        % ignoring that interval
        dif_eligible_idx(x, y) = 0;
    else
        [pw_samp, sampled_emg,handles] = sample_emg(pw, emg, pw_samp, sampled_emg, pw_to_sample,handles);
        [param_vec, f_vec, gof_vec, lxb_vec, rxb_vec, c_vec] = fit_gomperz_channels(pw_samp, sampled_emg, initial_fit, lower_bound, upper_bound);
        dif = abs(diff(sampled_emg,[], 2));
        eligible = ones(size(dif,1), size(dif,2));
        dif_eligible_idx = and(dif>=emg_diff_lim, eligible);
    end
    if length(pw_samp) > 20;
        break
    end
        
end
number_of_sampled_points = size(pw_samp, 2) - 1;
pw_sampled = pw_samp;
emg_sampled = sampled_emg;
if plot_results ==1
    figure(2)
    subplot(1, 2, 2);
    hold on
    for i=1:size(emg,1)
        plot(f_vec{i},handles.settings.colors{i},pw_samp, sampled_emg(i, :),[handles.settings.colors{i} '*'])
    end
    title({'Refining',  ['Number of Points: ' num2str(size(pw_samp, 2)-1)]}, 'FontSize', 16)
    xlabel('PW', 'FontSize', 14)
    ylabel('Normalized EMG', 'FontSize', 14)
    f=get(gca,'Children');
    ylim([0 1.1])
    legend(f(fliplr(2*(1:size(emg,1))-1)),handles.settings.muscles, 'FontSize', 12)
end
handles.results.param_vec = param_vec;
handles.results.f_vec = f_vec;
handles.results.gof_vec = gof_vec;
handles.results.lxb_vec = lxb_vec;
handles.results.rxb_vec = rxb_vec;
handles.results.c_vec = c_vec;
handles.results.number_of_sampled_points = initial_points %number_of_sampled_points;
handles.results.pw_sampled = pw_samp;
handles.results.emg_sampled = sampled_emg;

end