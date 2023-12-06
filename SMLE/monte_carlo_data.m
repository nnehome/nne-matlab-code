%{

This script generates a Monte Carlo data for estimation of the sequential
search model. The data will be saved in data.mat.

%}


N = 1000; % number of consumers (or search sessions)
J = 30; % number of options per consumer

% 1st column are parameter names
% 2nd column are true parameter value (for Monte Carlo studies).

set_theta = {  
               '\beta_1'    0.1     % coefficient (stars)
               '\beta_2'    0.0     % coefficient (review score)
               '\beta_3'    0.2     % coefficient (loc score)
               '\beta_4'   -0.2     % coefficient (chain)
               '\beta_5'    0.2     % coefficient (promotion)
               '\beta_6'   -0.2     % coefficient (price)
               '\eta'       3.0     % outside good
               '\delta_0'  -4.0     % search cost base
               '\delta_1'   0.1     % search cost position
              };

theta_name = set_theta(:,1)';
theta_true = cell2mat(set_theta(:,2)');

rows = N*J;

% draw the hotel attributes
z = nan(rows, 6);

z(:,1) = randsample([2, 3, 4, 5], rows, true, [0.05, 0.25, 0.4, 0.3])'; % star rating
z(:,2) = randsample([3, 3.5, 4, 4.5, 5], rows, true, [0.08, 0.17, 0.4, 0.3, 0.05])'; % review score
z(:,3) = normrnd(4, 0.3 ,rows,1); % location score
z(:,4) = randsample([0, 1], rows, true, [0.2, 0.8])'; % chain hotel dummy
z(:,5) = randsample([0, 1], rows, true, [0.4, 0.6])'; % promotion dummy
z(:,6) = normrnd(0.15, 0.6, rows,1); % log price

% ranking positions
pos = repmat((1:J)',N,1);

% consumer index
consumer_id = repelem(1:N, J)';

% search and purchase
curve = importdata('curve_seq_search.csv');
[yd, yt, order] = model_seq_search(pos, z, consumer_id, theta_true, curve);

% save data
save('data.mat','theta_name','theta_true','consumer_id','pos','z','yd','yt','order')
