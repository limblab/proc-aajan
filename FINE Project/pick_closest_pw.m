function [idx, pw_sampled] = pick_closest_pw(pw_to_sample, pw)
%% Function returns pw within possible pws that are closest to pw_sample
% Inputs:
%   pw_sample: (vector) pw to sample
%   pw: (vector)(1 x n) possible pws
% Outputs:
%   pw_sampled: (vector) closest pws to input values
%
% Jessica Abreu - jxd484@case.edu 02/2020
%%
    f=@(x) (min(abs(x-pw)));
    [min_pw, idx] = arrayfun(f,pw_to_sample);
    pw_sampled = pw(idx);
end