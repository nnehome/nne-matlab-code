
%{

This script trains the neural net in NNE, and then applies the trained
neural net on data.mat to obtain a parameter estimate.

For the illustration of NNE on AR1 model.

%}

clear

%% settings

num_nodes = 32; % number of hidden nodes (in shallow neural net)

%% load training & validation examples

load('nne_training.mat')

L_train = size(input_train, 1); % number of training examples
L_val   = size(input_val,   1); % number of validation examples

dim_input = size(input_train, 2); % number of inputs by neural net

%% train a neural net

opts = trainingOptions( 'adam', ...
                        'L2Regularization', 0, ...
                        'ExecutionEnvironment', 'cpu', ...
                        'MaxEpochs', 500, ...
                        'InitialLearnRate', 0.01, ...
                        'GradientThreshold', 1, ...
                        'MiniBatchSize', 500, ...
                        'Plots','none', ...
                        'Verbose', true, ...
                        'VerboseFrequency', 100, ...
                        'ValidationData', {input_val, label_val},...
                        'ValidationFrequency', 100);

layers = [  featureInputLayer(dim_input)
            fullyConnectedLayer(num_nodes)
            reluLayer
            fullyConnectedLayer(1)
            regressionLayer
            ];

[net, info] = trainNetwork(input_train, label_train, layers, opts);

disp("Final validation loss is: " + info.FinalValidationLoss)

%% display figure: estimate vs. truth in validation

pred_val = predict(net, input_val, exec='cpu');

figure('position', [750,500,250,250])
sgtitle('Estimate vs. Truth in Validation')
scatter(label_val, pred_val, '.')
xlabel(label_name)
axis equal

%% apply the trained neural net on data.mat

load('data.mat') % load the data

input = moments(y); % calculate data moments to be used as neural net input
estimate = predict(net, input, exec='cpu'); % apply the trained neural net

% display estimates
result = table(estimate, 'row', {label_name}, 'var', {'Estimate'});
disp(result)
