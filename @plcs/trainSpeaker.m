function trainSpeaker(obj, tseries, hop, iterations)
	%if all(obj.W(:, :, speaker) == 1)
	if nargin < 3
		hop = obj.nfft / 4;
	end
	if nargin < 4
		iterations = 300;
	end

	V = signal2spec(tseries, obj.nfft, hop);

	F = size(V, 1);
    T = size(V, 2);
   	K = obj.K;

    H = rand(K, T);
    W = rand(F, K);
    Y = rand(F, T, K);

    %normalize all randomly instantiated matrices to a "correct" solution ie: 
    %normalize them so that the sum of each will == 1
    sw = sum(W);
    W = W * diag(1 ./ sw);

    sh = sum(H);
    H = H * diag(1 ./ sh);

    %end initial normalization

    U = ones(F, K);
    Z = ones(F, T, K);
    D = ones(K, T);
    
    %iterate 
    for i = 1 : iterations
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
    end
    obj.S = obj.S + 1;
    obj.W = cat(3, obj.W, W);
end
