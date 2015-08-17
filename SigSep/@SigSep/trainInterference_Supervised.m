function W = trainInterference_Supervised(obj, V, maxitr)
	%
    % Implements the completely supervised separation algorithm. The interference is trained
    % using a set of training data. 
    %
    % Designated as algorithm 1 or 'known'
    % 
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
		maxitr = 300;
	end

    K = obj.K;
    F = size(V, 1);
    T = size(V, 2);

    % Pt(z)
    H = rand(K, T);

    % Ps(f|z)
    W = rand(F, K);

    %Pt(z | f)
    Y = rand(F, T, K);

    %normalize initial values
    sw = sum(W);
    W = W * diag(1 ./ sw);

    sh = sum(H);
    H = H * diag(1 ./ sh);

    U = ones(F, K);
    Z = ones(F, T, K);
    D = ones(K, T);
    
    for i = 1 : maxitr
        oldW = W;
    	%determine the value of Y or Pt(z|f);
    	for z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end

        Y = bsxfun(@rdivide, Z, sum(Z, 3));

        for z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end

        W = U  * diag(1 ./ sum(U));
        
        for z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        H = D * diag( 1 ./ sum(D));
        
        if sum( sum( abs(W - oldW))) < obj.delta
        	break;
        end
    end
end