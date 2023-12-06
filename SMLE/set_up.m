
%% config

N = 1000; % number of consumers
J = 30; % options per consumer

% z dim = 7, the same as the empirical data
bounds = {  
            0.1,   -0.5,  0.5,	'\beta_1'   	% coefficient (stars)
            0.0,   -0.5,  0.5, 	'\beta_2'   	% coefficient (review score)
            0.2,   -0.5,  0.5, 	'\beta_3'   	% coefficient (loc score)
           -0.2,   -0.5,  0.5, 	'\beta_4'       % coefficient (chain)
            0.2,   -0.5,  0.5,  '\beta_5'   	% coefficient (promotion)
           -0.2,   -0.5,  0.5,  '\beta_6'     	% coefficient (price)
            3.0,    2.0,  5.0, 	'\eta'          % outside good
           -4.0,   -5.0,  -2.0,	'\delta_0'      % search cost base
            0.1,   -0.25,  0.25,'\delta_1'  % search cost position
          };

theta_true = cell2mat(bounds(:,1))';
lb = cell2mat(bounds(:,2))';
ub = cell2mat(bounds(:,3))';
label_name = bounds(:,4)';

%% simulate data

curve = importdata('tableData.csv');

rows = N*J;

outside = false(N*J,1);
outside(1:J:N*J) = 1;

% draw the hotel characteristics z
z = [randsample([2, 3, 4, 5], rows, true, [0.05, 0.25, 0.4, 0.3])',...
     randsample([3, 3.5, 4, 4.5, 5], rows, true, [0.08, 0.17, 0.4, 0.3, 0.05])',...
     4 + 0.3*randn(rows,1),...
     randsample([0, 1], rows, true, [0.2, 0.8])',...
     randsample([0, 1], rows, true, [0.4, 0.6])',...
     (0.15 + 0.6*randn(rows,1))];

pos = repmat((1:J)',N,1);
consumer_id = cumsum(outside);
index = find(z(:,end));

%draw eps for each consumer-firm combination
eps = randn(length(consumer_id),1);

%draw eps for outside option
eps0 = randn(length(unique(consumer_id)),1);

[yd, yt] = gen_seq_search(pos, z, consumer_id, theta_true, eps, eps0, curve);

Statistics(yd, yt, pos, consumer_id, true);

%% save

save('data.mat','label_name','theta_true','lb','ub','consumer_id','pos','z','yd','yt')
