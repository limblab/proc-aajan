inputs = randperm(250);
x = sort(transpose(inputs(1:200)));
x_test = sort(transpose(inputs(201:250)));
noise = 0.1*randn(200,1);
noise_test = 0.1*randn(50,1);
a1 = 0.0;
a2 = 1.0;
a3 = 0.15; 
a4 = 125;
% a3 = 10;
% a4 = 0.5;
f = 2*(a1+(a2-a1)./(1+exp(-a3*(x-a4))))-1;
f_test = 2*(a1+(a2-a1)./(1+exp(-a3*(x_test-a4))))-1;
% f = a1+(a2-a1)./(1+exp(-a3*(x-a4)));
% f_test = a1+(a2-a1)./(1+exp(-a3*(x_test-a4)));
y = f+noise;
y_test = f_test+noise_test;

hold on
plot(x,f)
scatter(x,y)
title('Single Sigmoid with Additive Gaussian Noise')
xlabel('Pulse Width') 
ylabel('Activation') 
%%
meanfunc = [];      % empty: don't use a mean function
% covfunc = @covNNone;              % NN covariance function
covfunc = @covSEiso;              % Squared Exponental covariance function
% covfunc = @covLINone;             % Linear Covariance 
% covfunc = @covPoly;             % Polynomial Covariance 
% covfunc = {@covSum, {@covNNone, @covSEiso}} ;
likfunc = @likErf; % Erf likelihood
inffunc = @infEP;

hyp = struct('mean', [], 'cov', [1 1], 'lik', []);
hyp2 = minimize(hyp, @gp, -100, inffunc, meanfunc, covfunc, likfunc, x, y);
[mu, s2] = gp(hyp2, inffunc, meanfunc, covfunc, likfunc, x, y, x_test);
%%
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)];
fill([x_test; flipdim(x_test,1)], f, [7 7 7]/8, 'DisplayName','GP Predictive Distribution 95% Conf. Int.')
hold on; plot(x_test, mu, 'DisplayName','GP Predictive Distribution Mean')
plot(x_test, y_test, 'o', 'DisplayName','Test Points') 
plot(x, y, '+', 'DisplayName','Train Points') 
title('Gaussian Process Predictions (Single Sigmoid) - RBF Kernel + Erf Likelihood')
xlabel('Pulse Width') 
ylabel('Activation')
legend