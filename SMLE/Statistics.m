
function [buy_rate, search_rate, num_search, pos_search] = Statistics(yd, yt, pos, consumer_id, display)

% index = find(X(:,end));

ydn = accumarray(consumer_id, yd);
ytn = accumarray(consumer_id, yt);

buy_rate = mean(ytn);
search_rate = mean( ydn > 1);
num_search = mean(ydn);
search_position = pos(yd==1);
pos_search = mean(search_position);

if display
    disp(' ')
    disp("Frequency of buying: " + buy_rate)
%     disp("Frequency of search: " + search_rate)
    disp("Average number of searches: " + num_search)
    disp("Average position of searches: " + pos_search)
    
end
% accumarray(pos, yd)
% tabulate(ydn)