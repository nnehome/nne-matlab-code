
%{

This script trains the neural net in NNE, and then applies the trained
neural net on data.mat to obtain a parameter estimate.

%}

clear

%% settings

num_nodes = 64; % number of hidden nodes (in shallow neural net)
learn_sd = true; % whether to learn estimates of statistical accuracy

%% load training & validation examples

load('nne_training.mat')

L_train = size(input_train, 1); % number of training examples
L_val   = size(input_val,   1); % number of validation examples

dim_input = size(input_train, 2); % number of inputs by neural net
dim_label = size(label_train, 2); % number of parameters

% extend neural net outputs in the case of learn_sd = true  
output_train = [label_train, zeros(L_train, dim_label*learn_sd)];
output_val   = [label_val,   zeros(L_val,   dim_label*learn_sd)]; 

dim_output = size(output_train, 2); % number of outputs by neural net

%% train a neural net

opts = trainingOptions( 'adam', ...
                        'ExecutionEnvironment','cpu',...
                        'LearnRateSchedule','piecewise', ...
                        'LearnRateDropPeriod', 200, ...
                        'InitialLearnRate' , 0.01, ...
                        'GradientThreshold', 1,...
                        'MaxEpochs', 300, ...
                        'Shuffle','every-epoch',...
                        'MiniBatchSize', 500,...
                        'L2Regularization', 0, ...
                        'Plots','none', ...
                        'Verbose', true, ...
                        'VerboseFrequency', 500, ...
                        'ValidationData', {input_val, output_val}, ...
                        'ValidationFrequency', 500);

layers = [  featureInputLayer(dim_input, 'normalization', 'rescale-symmetric')
            fullyConnectedLayer(num_nodes)
            reluLayer
            fullyConnectedLayer(dim_output)
            normalRegressionLayer('learn_sd', learn_sd)
            ];

[net, info] = trainNetwork(input_train, output_train, layers, opts);

disp(" ")
disp("Final validation loss is: " + info.FinalValidationLoss)

%% display figure: estimate vs. truth in validation

pred_val = predict(net, input_val, exec='cpu');

figure
sgtitle('Estimate vs. Truth in Validation')

p = round(sqrt(dim_label));

for i = 1:dim_label
    subplot(p, p+1, i)
    scatter(label_val(:,i), pred_val(:,i), '.')
    xlabel(label_name(i))
    axis equal
end

%% apply the trained neural net to data.mat

load('data.mat'); % load data for estimation

input = moments(pos, z, consumer_id, yd, yt); % calculate data moments to be used as neural net input
pred = predict(net, input, exec='cpu'); % apply the trained neural net

estimate = pred(1:dim_label)'; % get point estimate
sd = exp(pred(dim_label+1:end))'; % get estimate of statistical accuracy
sd = [sd; nan(dim_label*~learn_sd, 1)]; % fill sd with nan if learn_sd=0

% display estimates
result = table(estimate, sd, 'row', label_name, 'var', {'Estimate','SD'});
result = rmmissing(result, 2);
disp(" ")
disp(result)


