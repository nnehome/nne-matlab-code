%% set up

clear; 
seed = 1; 
R = 50; % number of simulations
w = -7; % smoothing parameter

tic;

rng(seed)

set_up % generate a search dataset, save in data.mat

load('data.mat')

% table with (normalized) search cost and reservation utility
curve = importdata('tableData.csv');

%% MLE  estimation for Monte Carlo

%draw eps for each consumer-firm combination
eps = randn(length(consumer_id),1);
%draw eps for outside option
eps0 = randn(length(unique(consumer_id)),1);

% simulate data
[yd, yt, order] = gen_seq_search(pos, z, consumer_id, theta_true, eps, eps0, curve);

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
