
%{

This script generates the training and validation examples to be used to
train NNE. The examples will be saved in nne_trainning.mat.

Change 'for' to 'parfor' if parallel computing toolbox is available.

For the illustration of NNE on AR1 model.

%}

clear

%% settings

label_name = '\beta'; % name of the AR1 parameter to be estimated
lb = 0; % lower bound of the AR1 parameter
ub = 0.9; % upper bound of the AR1 parameter

%% simulate

L = 1000; % number of training & validation examples

% pre-allocation for training & validation examples
input = cell(L,1);
label = cell(L,1);

for l = 1:L
    
    % draw the value for the AR1 parameter
    beta = unifrnd(lb, ub);
    
    % simulate the AR1 time series data
    y = model(beta);
    
    % compute moment(s) and store the result.
    input{l} = moments(y);
    label{l} = beta;
    
end

input = cell2mat(input);
label = cell2mat(label);

%% training-validation split

L_train = floor(L*0.8); % number of training examples (80-20 split)

input_train = input(1:L_train,:);
label_train = label(1:L_train,:);

input_val = input(L_train+1:L,:);
label_val = label(L_train+1:L,:);

%% save 

save('nne_training.mat','input_train','label_train','input_val','label_val','label_name')
