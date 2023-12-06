
function output = Objective_mle(be, pos, X, consumer_id, yd, yt, R, w, eps_draw,eps0_draw,curve) 

loglik = liklOutsideFE(be, pos, X, consumer_id, yd, yt, R, w, eps_draw,eps0_draw,curve);

output = -sum(loglik);

end
