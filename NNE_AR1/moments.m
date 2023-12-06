
function output = moments(y)

%{

This function summarizes data into moments.

Currently the output is a single moment. To use more moments:
(a) Change k to larger than 1 to include more lags;
(b) Uncomment m{2}, m{3}, m{4} to include higher-order moments.

%}

% how many lags to use.
k = 1;

% lagged values of y
x = lagmatrix(y, 1:k);
x( isnan(x)) = 0;

% compute moments.
m{1} = mean(y.*x);
% m{2} = mean(y.^2);
% m{3} = mean(y.^2.*x);
% m{4} = mean(y.*x.^2);

% final output.
output = cell2mat(m);
