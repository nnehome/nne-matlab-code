
function y = model(beta)

%{

This function codes a simple AR1 model: y(i) = beta*y(i-1) + epsilon(i),
with epsilon ~ N(0,1) and  y(1) drawn from the stationary distribution.

Input:
    beta .. the coefficient.
Output:
    y .. simulated time series stored in a vector of length n.

%}

n = 100; % number of observations (or periods).

epsilon = randn(n,1); % error terms

y = nan(n,1);

y(1) = epsilon(1)/sqrt(1 - beta^2); % draw initial value

% draw rest of the values
for i = 2:n
    y(i) = beta*y(i-1) + epsilon(i);
end