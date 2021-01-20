function [white_data] = mvnn_whitening(data,trials)
% do multivariate noise normalization and whitening

% Input: data: 4D matrix with dimensions conditions x pseudotrials x channels x timepoints
%       trials: vector with bins. 

    % multivariate noise normalization II
    sz = size(data);
    E  = NaN(sz(4),sz(1),sz(3),sz(3)); % Epsilon for mvnn
    
    for time = 1:sz(4)

        for condition = 1:sz(1)
            
      X = squeeze(data(condition,trials,:,time));

            [sigma,shrinkage] = covCor(X);

            E(time,condition,:,:) = sigma;
        end
    end 
    
    EE = squeeze(mean(mean(E,1),2));
    clear E
    IE = EE^(-0.5);
    
    % whiten data
    white_data = NaN(condition,sz(2),sz(3),time); 
    for time = 1:sz(4)

        for condition = 1:sz(1)
            for bins  = 1:sz(2)
                
                X = squeeze(data(condition,bins,:,time))';
                W = X*IE; 
                white_data(condition,bins,:,time) = W;
            end
            
        end
    end 

end
