
function [yd, yt, order] = gen_seq_search(pos, X, consumer_id, theta, eps, eps0, curve)
%% setup

% number of options for each consumer
Ji = accumarray(consumer_id,1);
Ji = Ji(consumer_id);

bepos = theta(end); % last par, position
constc = theta(end - 1); % par (2nd to last): constant in search cost

v0 = theta(end - 2); % outside option

rows = length(consumer_id); % number of observations
N = consumer_id(rows); % number of consumers

[~, index] = ismember(1:N, consumer_id); % index of consumers in the data

%form utility from data and param
eutility = X * theta(1:size(X,2))';

utility = eutility + eps;

% utility of the outside option
u0 = v0 + eps0;

%search cost c, and therefore m, only changes with pos
sz = size(curve,1);
pos_unique = sort(unique(pos));
m_pos = zeros(length(pos_unique),1);
for i = 1:length(pos_unique)
    c_i = exp(constc + log(i).*bepos);
    if c_i<curve(1,2) && c_i>=curve(sz,2)
        for n = 2:length(curve)
            if (curve(n,2) == c_i)
                m_pos(i) = curve(n,1);
            elseif ((curve(n-1,2)>c_i)&& (c_i>curve(n,2)))
                m_pos(i) = (curve(n,1)+curve(n-1,1))/2;
            end
        end
    elseif c_i>=curve(1,2)
        m_pos(i) = -c_i;
    elseif c_i<curve(sz,2)
        m_pos(i) = 4.001;
    end
end
m = m_pos(pos);

%reservation utilities
z = m + eutility;

%order by z for each consumer
da = [consumer_id, pos, Ji, X, utility, eutility, z];
whatz = size(da,2);
whateu = whatz - 1;
whatu = whateu - 1;

order = zeros(rows,1);

for m = 1:N
    n = index(m);
    J = Ji(n);
%     for j = n:n+J-1
    [~, order(n:n+J-1)] = sort(da(n:n+J-1, whatz),'descend');
%     end
end

o = ones(rows, 1);
for m = 1:N
    n = index(m);
    J = Ji(n);
    for j = n:n+J-1
        o(j) = order(j) + n - 1;
    end
end

data = da(o, :);

% click decisions
yd = zeros(rows, 1);
ydn = zeros(rows, 1);

% order of clicks
order = zeros(rows,1);

% free first click
yd(index) = 1;

%for next click decisions: if z is higher than outside
%option and higher than all utilities so far, then increase click d by one
% It is ok to do this because we ordered the z's first, so we know that zn>zn+1
for i = 1:N
    J = Ji(index(i));
    for j = 1:(J-1)
        ma = max(data(index(i):(index(i)+j-1), whatu), u0(i));
        if data(index(i)+j, whatz) > ma
            yd(index(i)+j) = 1;
        else
            break
        end
    end
    ydn(index(i):(index(i)+J-1)) = sum(yd(index(i):(index(i)+J-1)));
end

%tran decisions: if out of those clicked (the set of indices from first to
%max) u=max, then put a 1, otherwise put zero; finally reshape
yt = zeros(rows, 1);
mi = zeros(rows, 1);

for i = 1:N
    J = Ji(index(i));
    ydn_i = ydn(index(i));
%     if ydn_i>0
        order(index(i):index(i)+ydn_i-1) = 1:ydn_i;
%     end
    mi(index(i):index(i)+J-1) = max([data(index(i):index(i)+ydn_i-1, whatu); u0(i)]);
end
yt(data(:, whatu) == mi) = 1;

[~, i] = ismember((1:rows)', o);
yd = yd(i);
yt = yt(i);
order = order(i);

end

