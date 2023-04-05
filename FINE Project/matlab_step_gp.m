num_points = 500;
inputs = linspace(-1,1, num_points);
my_indices = randperm(num_points);
x = transpose(sort(inputs(my_indices(1:.9*num_points))));
xs = transpose(sort(inputs(my_indices(.9*num_points+1:num_points))));
H = 2*heaviside(x)-1; 
y = H+(0.05*randn(0.9*num_points,1)); 

hold on; plot(x,H); scatter(x, y)
title('Step Function with Additive Gaussian Noise')
xlabel('Input') 
ylabel('Output') 


%%
meanfunc = [];      % empty: don't use a mean function
% covfunc = @covNNone;              % NN covariance function
covfunc = @covSEiso;              % Squared Exponental covariance function
% covfunc = @covLINone;             % Linear Covariance 
% covfunc = @covPoly;             % Polynomial Covariance 
% covfunc = {@covSum, {@covNNone, @covSEiso}} ;
likfunc = @likErf; % Gaussian likelihood
inffunc = @infEP;

hyp = struct('mean', [], 'cov', [1 1], 'lik', []);
hyp2 = minimize(hyp, @gp, -100, inffunc, meanfunc, covfunc, likfunc, x, y);
[mu, s2] = gp(hyp2, inffunc, meanfunc, covfunc, likfunc, x, y, xs);
%%
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
fill([xs; flipdim(xs,1)], f, [7 7 7]/8)
hold on; plot(xs, mu); plot(x, y, '+')
title('Gaussian Process Predictions (Modified Step Function) - RBF Kernel + Erf Likelihood')
xlabel('Input') 
ylabel('Output')