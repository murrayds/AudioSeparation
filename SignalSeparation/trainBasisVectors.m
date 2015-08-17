function [W, H] = trainBasisVectors(V, K)


    iterations = 300;
    %deltaThreshold = 1e-6;
    % V is our data spectrogram. Each colomn represents the results of a fft (the frequency distribution)
    % and each row represents the value of a certain frequency band over the course of each training sample
    F = size(V, 1);
    T = size(V, 2);

    % 2 dimensional vector H holds the weights of each component across time
    % Pt(Z)   probability of a component given a time
    H = rand(K, T);

    % three dimensional vector F x K x Speaker
    % Frequency x Component by Speaker
    % Holds the frequency values of our basis vectors for each component and each speaker
    % Ps(f|z) the probability of each frequency appearing form a certain speaker and component
    %ignoring speaker for now. If speaker is included then it becomes a three dinemsional matrix
    W = rand(F, K);

    % The multiplication W * H will result in our best estimate model

    %This vairable is discarded after iteration of the EM algorithms
    %Represents our model given our basic vectors and weights
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
    
    %iterate until convergence or max iterations is reached
    for i = 1 : iterations
    %    oldW = W;
    	%determine the value of Y or Pt(z|f);
    	
    	%iterate through all components
    	parfor z = 1 : K
    		Z(:, :, z) = W(:, z) * H(z, :);
    	end
    	
        %normalize the value of Z and put it in Y
        % could be replaced with sum(Z, 3) if we are right, TEST IT!!!!!!!
        Y = bsxfun(@rdivide, Z, sum(Z, 3));
    	%Y = bsxfun(@rdivide, Z, W * H);

    	%end determining value of Y
        
        %Now let us update our value of W.
        parfor z = 1 : K
            U(:, z) = sum( Y(:, :, z) .* V, 2);
        end

        W = U  * diag(1 ./ sum(U));
        
        parfor z = 1 : K
         	D(z, :) = sum(Y(:, :, z) .* V, 1);
        end
        H = D * diag( 1 ./ sum(D));
        
    end
end
