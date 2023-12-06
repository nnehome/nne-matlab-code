
%{

This script generates the training and validation examples to be used to
train NNE. The examples will be saved in nne_trainning.mat.

Change 'for' to 'parfor' if parallel computing toolbox is available.

%}

clear

%% settings

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

L = 1e4; % number of training & validation examples

% load reservation utility curve (to be used in search model)
curve = importdata('curve_seq_search.csv');

% load observed attributes in data
load('data.mat', 'pos', 'z', 'consumer_id', 'N', 'J')

%% generate training & validation examples

% pre-allocation for training & validation examples
input = cell(L,1);
label = cell(L,1);

for l = 1:L
    
    % draw the value for the search model parameter
    theta = unifrnd(lb, ub);

    % simulate search and purchase outcomes
    [yd, yt] = model_seq_search(pos, z, consumer_id, theta, curve);
    
    % drop corner cases

    buy_rate = sum(yt)/N; % fraction of consumers who purchased
    num_srh  = sum(yd)/N; % number of searches per consumer
    
    if buy_rate > 0 && buy_rate < 1 && num_srh > 1 && num_srh < J

        input{l} = moments(pos, z, consumer_id, yd, yt);
        label{l} = theta;

    end

end

% convert cells to matrices
input = cell2mat(input);
label = cell2mat(label);

%% training-validation split

L = size(input,1); % number of examples excluding corner cases
L_train = floor(L*0.9); % number of training examples (90-10 split)

input_train = input(1:L_train,:);
label_train = label(1:L_train,:);

input_val = input(L_train+1:L,:);
label_val = label(L_train+1:L,:);

%% save

save('nne_training.mat','input_train','label_train','input_val','label_val','label_name')

