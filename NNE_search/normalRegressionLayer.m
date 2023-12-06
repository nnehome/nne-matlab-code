
classdef normalRegressionLayer < nnet.layer.RegressionLayer

%{

This file codes the loss function for neural net training. It extends the
Matlab built-in regressionLayer. The regressionLayer uses the MSE loss.
This file adds a normal cross-entropy loss.

Set property learn_sd to true to use the cross-entropy loss. In this case,
the number of neural net outputs doubles to give both the mean and standard
deviation terms.

%}

    properties

        learn_sd
        
    end
 
    methods
        
        function layer = normalRegressionLayer(varargin) 

            p = inputParser;
            addOptional(p, 'learn_sd', false, @islogical)
            parse(p, varargin{:})
            
            layer.learn_sd = p.Results.learn_sd;

        end

        function loss = forwardLoss(layer, Y, T)
             
            if ~ layer.learn_sd

                Q = 0.5*(Y - T).^2;

            else

                k = size(Y,1)/2;
                
                S = exp(Y(k+1:2*k, :));
                V = Y(1:k, :);
                U = T(1:k, :);
                
                Q = log(S) + 0.5*((V - U)./S).^2;

            end
            
              loss = sum(Q(:))/size(Y,2);

        end
        
        function dLdY = backwardLoss(layer, Y, T)
            
            if ~ layer.learn_sd

                dLdY = (Y - T)/size(Y,2);

            else

                k = size(Y,1)/2;
                
                S = exp(Y(k+1:2*k, :));
                dS = S;
                V = Y(1:k, :);
                U = T(1:k, :);
                
                dLdS = 1./S - 1./S.^3.*(V - U).^2;
                dLdV = (V - U)./S.^2;
                
                dLdY = [dLdV; dLdS.*dS]/size(Y,2);

            end
        end

    end
end
