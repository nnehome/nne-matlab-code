
%{

This script generates a Monte Carlo data for estimation of AR1 model. The
data will be saved in data.mat.

%}

clear

% set true parameter value
beta_true = 0.6;

% simulate the data
y = model(beta_true);

% save data
save('data.mat', 'y')