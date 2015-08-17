function W = trainInterference_SemiSupervised(V, fixedW, fixedH)
    %
    % Author: Dakota Murray
    % Versio: 19 June 2014
    %
    % Trains a set of basis vectors to represent the pieces of a signal not associated 
    % with the given fixed basis vectors. The provided W and H matrixes are fixed and represent
    % the target of the source separation. Vectors representing the rest of the signal will
    % be trained.
    %
    % Inputs:
    %   V       : A spectrogram of a mixture
    %   fixedW  : A set of basis vectors already learned parfor the "target" source in the mixture
    %   fixedH  : A set of weights learned from the "target" of the mixture
    %
    % Outputs:
    %   W       : A new set of basis vectors representing the interference from the mixture with 
    %             size F x K where K is the number of components present in fixedW.
    %

	% The alrogithm assumes that that 2 * K components are being learned.
    % Only the last K components will be returned. 
    fixedK = size(fixedW, 2);
    K = fixedK * 2;

    iterations = 300;
    
    F = size(V, 1);
    T = size(V, 2);

    % Inintialize Necessary Values.

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
    %iterate until convergence or max iterations is reached
    for i = 1 : iterations

    	%determine the value of Pt(z|f);
    	parfor z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end
        Y = bsxfun(@rdivide, Z, sum(Z, 3));
        
        % Update value of Ps(f | z)
        parfor z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end
        temp =  U  * diag(1 ./ sum(U));
        W(:, fixedK : K) = temp(:, fixedK : K);
        

        parfor z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        temp = D * diag( 1 ./ sum(D));
        H(fixedK : K, :) = temp(fixedK : K, :);
    end

    %return only learned vectors
    W = W(:, fixedK : K);
    H = H(fixedK : K, :);
end