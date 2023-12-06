
function output = moments(pos, z, consumer_id, yd, yt)

%{

This function specifies the data moments to be used in NNE.

Output: 
    A vector collecting the data moments.
Inputs: 
    pos .. product ranking positions
    z .. other product attributes
    consumer_id .. consumer indices
    yd .. search dummies
    yt .. purchase dummies

%}

rows = size(z, 1);

y = [yd, yt]; % all outcome variables
x = [z, log(pos)]; % all covariates

ydn = accumarray(consumer_id, yd); % consumer-level number of searches
ytn = accumarray(consumer_id, yt); % consumer-level purchase

y_tilde = [ydn>1, ydn, ytn]; % consumer-level outcomes

% consumer-level average of x
% x_bar = splitapply(@mean, x, consumer_id);
x_sum = arrayfun(@(i)accumarray(consumer_id, x(:,i)), 1:size(x,2), 'uni', false);
x_bar = cell2mat(x_sum)./accumarray(consumer_id, 1);

% mean vector of y
m1 = mean(y);

% cross-covariances between y and x
m2 = (y - mean(y))'*x/rows;
m2 = m2(:)';

% mean vector of y_tilde
m3 = mean(y_tilde);

% cross-covariances between y_tilde and x_bar
m4 = (y_tilde - mean(y_tilde))'*x_bar/rows;
m4 = m4(:)';

% covariance matrix of y_tilde
m5 = cov(y_tilde); 
m5 = m5(tril(true(length(m5))))';

% collect all moments
output = [m1, m2, m3, m4, m5];
