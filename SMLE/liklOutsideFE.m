%Matlab replication code--RMUrsu "The Power of Rankings"

%likelihood function

function loglik = liklOutsideFE(be, pos, X, consumer_id, yd, yt, R, w, eps_draw,eps0_draw,curve)

bepos = be(end); % last par, position
constc = be(end - 1); % 2nd to last par: constant in search cost
v0 = be(end - 2); % outside option

Ji = accumarray(consumer_id,1); % number of options per consumer (size N by 1)

rows = length(consumer_id);
N = consumer_id(rows);

% index of consumers in the data (size N by 1)
index = [1; find(ischange(consumer_id))];

% form utility from data and param
eutility = X * be(1:size(X,2))';
utility = repmat(eutility, [1,R]) + eps_draw;

% utility of the outside option
u0 = v0 + eps0_draw;

% search cost & reservation utility
sz = size(curve,1);
pos_unique = sort(unique(pos));
m_pos = zeros(length(pos_unique),1);
for i = 1:length(pos_unique)
%     c_i = exp(constc + i.*bepos);
    c_i = exp(constc + log(i).*bepos);
    if c_i<curve(1,2) && c_i>=curve(sz,2)
        for n = 2:length(curve)
            if (curve(n,2) == c_i)
                m_pos(i) = curve(n,1);
            elseif ((curve(n-1,2)>c_i)&& (c_i>curve(n,2)))
%                m_pos(i) = (curve(n,1) + curve(n-1,1))/2;
                m_pos(i) = curve(n,1) + (c_i - curve(n,2))/(curve(n-1,2)-curve(n,2))...
                    *(curve(n-1,1) - curve(n,1));
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

%%%% LIKELIHOOD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% idea: denominator = 1 + sum(w_click + w_tran)
% probability prob = 1 / denominator

% w_click
denomd = zeros(rows,R);
for r = 1:R
    for i = 1:N
        n = index(i);
        J = Ji(i);
        % find entry s where last click occurs for a consumer
        s = find(yd(n:n+J-1),1,'last');
        % if consumer has at least one click (s>1; one free search)
        if (s > 1 && s < J)
            % compute ma = max utility of those searchd (incl. outside option)
            ma = max([utility(n:n+s-1,r); u0(i,r)]);
            % continue to search condition
            %1. z_searched(i) > max{u_searched(i-1), u_outside}
            for l = n+1:n+s-1
                denomd(l,r) = exp(w*(z(l) - u0(i,r)));
                k = n;
                while k<=l-1
                    denomd(l,r) = denomd(l,r) + exp(w*(z(l) - utility(k,r)));
                    k = k + 1;
                end
            end
            %  stopping rules
            %2. max u_searched > z_notsearched
            for l = n+s:n+J-1
                denomd(l,r) = exp(w*(ma - z(l)));
            end
        elseif (s > 1 && s == J)
            % continue to search
            for l = n+1:n+s-1
                denomd(l,r) = exp(w*(z(l) - u0(i,r)));
                k = n;
                while k<=l-1
                    denomd(l,r) = denomd(l,r) + exp(w*(z(l) - utility(k,r)));
                    k = k + 1;
                end
            end
        elseif s==1
            % if there is only one free search
            % max(u_outside, u1) > all other z's
            for l = n+1:n+J-1
                denomd(l,r) = exp(w*(max([utility(n:n+s-1,r); u0(i,r)]) - z(l)));
            end
        end
    end
end


%w_tran
denomt = zeros(rows,R);
for r = 1:R
    for m = 1:N
        n = index(m);
        J = Ji(m);
        %find index of tran st and of last click
        st = find(yt(n:n+J-1),1,'last');
        sd = find(yd(n:n+J-1),1,'last');
        kt = n;
        if isempty(st) % no purchase
            while kt <= n+sd-1
                % outside option is better than all clicked options
                denomt(n,r) = denomt(n,r) + exp(w*(u0(m,r) - utility(kt,r)));
                kt = kt+1;
            end
        else % purchase option st
            % purchased option is better than outside option
            denomt(n+st-1,r) = denomt(n+st-1,r) + exp(w*(utility(n+st-1,r) - u0(m,r)));
            while kt<=n+sd-1
                % purchased option is better than all other clicked options
                if kt~=n+st-1
                    denomt(n+st-1,r) = denomt(n+st-1,r) + exp(w*(utility(n+st-1,r) - utility(kt,r)));
                end
                kt = kt+1;
            end
        end
    end
end

%add up search and tran partial denoms: add w_tran and w_click up
den = denomd + denomt;

denfull = zeros(N,R);
for r = 1:R
    denfull(:,r) = 1 + accumarray(consumer_id, den(:,r));
end

%probability
prob = 1./denfull;
%likelihood
loglik = log(mean(prob,2) + 1e-16);


end
