function obj = trainInterference(obj, signal, alg)
	%
	%
	%

	V = [];
	if size(signal, 1) == 1
		signal(signal == 0) = 1e-12;
		V = signal2spec(signal, obj.FFTSIZE, obj.FFTSIZE / 4)
	elseif size(signal, 2) == 2
		disp('Time Series signal must be a vector!\n');
		return;
	else
		V = signal;
	end	

	W = [];
	if alg == 1 or strcmp(alg, 'known') == 1
		W = trainInterference_Supervised(obj, V, 300);
	end

	if alg == 2 or strcmp(alg, 'semi') == 1
		W = trainInterference_SemiSupervised(obj, V, 300);
	end

	obj.interferenceW = W;

end


function W = trainInterference_Supervised(obj, V, maxitr)
	
	if nargin < 3
		maxitr = 300;
	end

    delta = 1e-6;

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
    	parfor z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end

        Y = bsxfun(@rdivide, Z, sum(Z, 3));

        parfor z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end

        W = U  * diag(1 ./ sum(U));
        
        parfor z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        H = D * diag( 1 ./ sum(D));
        
        if sum( sum( abs(W - oldW))) < delta
        	i
        	break;
        end
    end

end


function W = trainInterference_SemiSupervised(obj, V, maxitr)

	if nargin < 3
		maxitr = 300;
	end
	fixedW = obj.targetW;
	fixedH = obj.targetH;

	fixedK = size(fixedW, 2);
    K = fixedK * 2;
    
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
    	parfor z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end
        Y = bsxfun(@rdivide, Z, sum(Z, 3));
        
        % Update Ps(f | z)
        parfor z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end
        temp =  U  * diag(1 ./ sum(U));
        W(:, fixedK : K) = temp(:, fixedK : K);

        % Update Pt(z)
        parfor z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        temp = D * diag( 1 ./ sum(D));
        H(fixedK : K, :) = temp(fixedK : K, :);

        if sum( sum( abs(W - oldW))) < delta
        	i
        	break;
        end
    end
    %return only learned vectors
    W = W(:, fixedK : K);
end