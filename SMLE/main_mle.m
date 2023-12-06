clear; 

seed = 1; 
R = 50; % number of simulations 
w = -7; % smoothing parameter

tic;

rng(seed)

monte_carlo_data % generate a search dataset, save in data.mat

% table with (normalized) search cost and reservation utility
curve = importdata('curve_seq_search.csv');

% load monte carlo data 
load('data.mat')

data = [consumer_id, pos, z, yd, yt, order];
data = sortrows(data, [1,-9,11]); % sort by consumer_id and order of clicks

yd = data(:, end-2);
yt = data(:, end-1);
pos = data(:, 2);
z = data(:,3:(2+size(z,2)));

%draw eps for each consumer-firm combination
eps_draw = randn(length(consumer_id),R);
%draw eps for outside option
eps0_draw = randn(length(unique(consumer_id)),R);

% 1st column are parameter names.
% 2nd and 3rd columns are lower and upper bounds of parameter space Theta.

Theta = {
           '\beta_1'   -0.5,   0.5     % coefficient (stars)
           '\beta_2'   -0.5,   0.5     % coefficient (review score)
           '\beta_3'   -0.5,   0.5     % coefficient (loc score)
           '\beta_4'   -0.5,   0.5     % coefficient (chain)
           '\beta_5'   -0.5,   0.5     % coefficient (promotion)
           '\beta_6'   -0.5,   0.5     % coefficient (price)
           '\eta'       2.0,   5.0     % outside good
           '\delta_0'  -5.0,  -2.0     % search cost base
           '\delta_1'  -0.25,  0.25    % search cost position
          };

label_name = Theta(:,1)';
lb = cell2mat(Theta(:,2))';
ub = cell2mat(Theta(:,3))';

%initial parameter vector
be0 = (ub + lb)/2;


% options for estimation
options = optimoptions( 'fmincon',...
    'Display', 'iter',...
    'FinDiffType', 'central',...
    'FunValCheck', 'on',...
    'MaxFunEvals', 1e6,...
    'MaxIter', 1e6);

% [be,fval,~,output]=fminunc(@Objective_mle,be0,options,pos, X, consumer_id, yd, yt,...
% R, w, eps_draw,eps0_draw,curve);

[be,fval,~,output] = fmincon(@Objective_mle,be0,[],[],[],[],lb,ub,[],options,...
    pos, z, consumer_id, yd, yt, R, w, eps_draw,eps0_draw,curve);

be = reshape(be, [1, length(be)]);

ll_optim = liklOutsideFE(be, pos, z, consumer_id, yd, yt, R, w,eps_draw,eps0_draw,curve);

G = zeros(length(ll_optim), length(be));
for j = 1:length(be)
    par_input = be;
    par_input(j) = par_input(j) + 1e-3;
    ll_j = liklOutsideFE(par_input, pos, z, consumer_id, yd, yt, R, w,eps_draw,eps0_draw,curve);
    G(:, j) = (ll_j - ll_optim)/1e-3;
end

se = sqrt(diag(inv(G' * G)));

se = reshape(se, [1, length(se)]);

toc;
mle_time = toc/60;
 
A = [be se output.funcCount fval mle_time];

csvwrite(sprintf('theta_R%d_w%d.csv',R,-w), A);
