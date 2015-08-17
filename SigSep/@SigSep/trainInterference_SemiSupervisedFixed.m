function W = trainInterference_SemiSupervisedFixed(obj, V, maxitr)
    %
    % Author : Dakota Murray
    % Version: 26 June 2014
    %
    % Implements the semi-supervised algorithm where the interference model is trained from 
    % a mixture by using the target model as a starting point and training components for 
    % all parts of the signal not related to the target. In this algorithm the target model
    % is fixed.
    %
    % This algorithm is designated 2 or 'fixed'
    % Inputs:
    %   obj     : the SigSep object this function is being called on
    %   V       : A spectrogram of the provided training data
    %   maxitr  : This function implements an interative algorithmn. maxitr deifnes the maximum number 
    %             of iterations to calculate. 
    %
    % Outputs:
    %   W       : W is the set of basis vectors representing the training data V
    %

	if nargin < 3
		maxitr = 200;
	end

	fixedW = obj.targetW;
	fixedH = obj.targetH;

	fixedK = obj.K;
    K = obj.K * 2;
    
    F = size(V, 1);
    T = size(V, 2);

    % Pt(Z)
    H = rand(K, T);
    sh = sum(H);
    H = H * diag(1 ./ sh);
    H(1 : fixedK, :) = fixedH;

    % P(f|z)    
    W = rand(F, K);
    sw = sum(W);
    W = W * diag(1 ./ sw);
    W(:, 1 : fixedK) = fixedW;

    % Pt(F | Z)
    Y = rand(F, T, K);
    
    U = ones(F, K);
    Z = ones(F, T, K);
    D = ones(K, T);
    
    fixedK = fixedK + 1;
    
    for i = 1 : maxitr
    	oldW = W;

    	% Update Pt(z|f);
    	for z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end
        Y = bsxfun(@rdivide, Z, sum(Z, 3));
        
        % Update Ps(f | z)
        for z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end
        temp =  U  * diag(1 ./ sum(U));
        W(:, fixedK : K) = temp(:, fixedK : K);

        % Update Pt(z)
        for z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        temp = D * diag( 1 ./ sum(D));
        H(fixedK : K, :) = temp(fixedK : K, :);

        if sum( sum( abs(W - oldW))) < obj.delta
        	break;
        end
    end
    %return only learned vectors
    W = W(:, fixedK : K);
end