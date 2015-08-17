function X = separate(obj, tseries, hop, iterations)
	%
	% Author  : Dakota Murray
	% Version : 17 June 2014
	%
	% A method belonigng to the class plcs which will conduct the actual seperation of a novel audio
	% signal using already learned speaker weights. The speakers in the audio signal will be seperated
	% and the time series of each source will be reconstructed as best as is possible.
	%
	% Inputs:
	% 	obj		    : The plcs object which contains already learned weights for various speakers
	%	tseries     : A novel time series signal to apply separation on
 	%   hop		    : The hopsize to use when reconstructing a time series signal at the end of the algorithm. 
 	%				  Should be the same as the hopsize used to train the weights of the speaker basis vectors.
 	%				  Otherwise results may be erroneous.
 	%   iterations 	: The number of iterations to run the separation iterative algorithm. High iteration may
 	%				  result in more accuracy and better separation but will also increase running time of calculation
 	%
 	% Outputs:
 	%	X			: A matrix where each vector is a time series signal resulting from reconstruction of the separated
 	%				  spectrograms. 
 	%
	if nargin < 3
		hop = obj.nfft / 4;
	end
	if nargin < 4
		iterations = 400;
	end

	[V C sumV] = signal2spec(tseries, obj.nfft, hop);
	
	W = obj.W;

	F = size(V, 1);
	T = size(V, 2);
	K = size(W, 2);
	S = size(W, 3);

	%should these be normalized to begin with?
	R = rand(S, K, F, T);
	M = rand(S, T);
	N = rand(K, S, T);

	for i = 1 : iterations
		% calculate Pt(s, z | f)
		Rt = R;
		for s = 1 : S
			for k = 1 : K
				Rt(s, k, :, :) = ( squeeze(W(:, k, s)) * squeeze(N(k, s, :))' ) * diag(M(s, :));
			end
		end
		Rs = ((sum(sum(Rt, 2), 1)));
		R = bsxfun(@rdivide, Rt, Rs);
		
		%Now time to calculate Pt(s)
		Nt = N;
		for s = 1 : S
			for k = 1 : K
    			Nt(k, s, :) = sum( squeeze(R(s, k, :, :)) .* V, 1);
			end
		end
		N = bsxfun(@rdivide, Nt, sum(Nt, 1));

		Mt = M;
		for s = 1 : S
			Mt(s, :) =  sum(V .* squeeze(sum( squeeze(R(s, :, :, :)), 1)), 1);
		end
		Ms = sum(Mt, 1);
		M = bsxfun(@rdivide, Mt, Ms);
	end

	%now we reconstruct the signal
	O = zeros(F, T, S);
    for s = 1 : S
        O(:, :, s) = squeeze(W(:, :, s)) * squeeze(N(:, s, :)) * diag(M(s, :)) ;
    end
    O = bsxfun(@rdivide, O, sum(O, 3));
   	
    for s = 1 : S
        O(:, :, s) = O(:, :, s) .* V;
    end;

    X = zeros( (T-1) * hop + obj.nfft, S);
    displaySpectrogram(V, 'combined signal');
    
    for i = 1 : S
    	O(:, :, i) = O(:, :, i) * diag(sumV) .* exp( sqrt(-1) * C);
    	X(:, i) = stft(O(:, :, i), obj.nfft, hop, 0, 'hann');
    end
    displaySpectrogram(O(:, :, 1), 'Seperated Signal 1');

end
