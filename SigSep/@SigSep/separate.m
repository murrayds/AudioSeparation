function [target, interference, tspec, ispec, C] = separate(obj, mixture, maxitr, plot)
	%
	% Author  : Dakota Murray
	% Version : 17 June 2014
	%
	% A method belonigng to the class SigSep which will conduct the actual seperation of a novel audio
	% mixture using already learned speaker weights. The speakers in the audio mixture will be seperated
	% and the time series of each source will be reconstructed as best as is possible.
	%
	% Inputs:
	% 	obj		    : The plcs object which contains already learned weights for various speakers
	%	mixture     : A novel time series mixture to apply separation on
 	%   maxitr 		: Themaximum  number of iterations to run the separation iterative algorithm. High iteration may
 	%				  result in more accuracy and better separation but will also increase running time of calculation
 	%
 	% Outputs:
 	%	target      : A vector containing the time series signal of the "target" part of the mixture. 
 	%   Interference: A vector containing the time series signal of the "interference" part of the mixture, that is
 	%				  everything that is not the target.  
 	%
 	% Email questions, comments, and conerns to AetherBlossom@gmail.com
 	%

	if nargin < 3 | isempty(maxitr)
		maxitr = 300;
	end
	if nargin < 4
		plot = 'off';
	end

	toQuit = 0;
	if ~ obj.isTargetTrained()
		toQuit = 1;
		disp('Must train Target before separating\n');
	end
	if ~obj.isInterferenceTrained()
		toQuit = 1;
		disp('Must train Interference before separating\n');
	end

	if toQuit
		return;
	end

	V = [];
    if size(mixture, 2) == 2
        disp('Time Series mixture must be a vector!\n Using first channel only');
        mixture = mixture(:, 1);
    end
    if ~isvector(mixture)
    	disp('Must Enter a Time Series signal!\n');
    	return;
    end

	hop = obj.FFTSIZE / 4;
	delta = 1e-6;

	mixture(mixture == 0) = 1e-12;
	[V C sumV] = signal2spec(mixture, obj.FFTSIZE, hop);
	
	W = cat(3, obj.targetW, obj.interferenceW);

	F = size(V, 1);
	T = size(V, 2);
	K = size(W, 2);
	S = 2;

	%should these be normalized to begin with?
	R = rand(S, K, F, T);
	M = rand(S, T);
	N = rand(K, S, T);

	for i = 1 : maxitr
		oldM = M;

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

		if sum( sum( abs(oldM - M))) < delta
			break;
		end
	end

	%now we reconstruct the mixture
	O = zeros(F, T, S);
    for s = 1 : S
        O(:, :, s) = squeeze(W(:, :, s)) * squeeze(N(:, s, :)) * diag(M(s, :));
    end
    O = bsxfun(@rdivide, O, sum(O, 3));
   	
    for s = 1 : S
        O(:, :, s) = O(:, :, s) .* V;
    end

    X = zeros( (T-1) * hop + obj.FFTSIZE, S);
    
    if nargout > 2
    	tspec = O(:, :, 1);
    	ispec = O(:, :, 2);
    end
    
    for i = 1 : S
    	O(:, :, i) = O(:, :, i) * diag(sumV) .* exp( sqrt(-1) * C);
    	X(:, i) = stft(O(:, :, i), obj.FFTSIZE, hop, 0, 'hann');
    end

    target = X(:, 1);
    interference = X(:, 2);

    if strcmp(plot, 'on')
    	displaySpectrogram(V, 'Mixture Spectrogram');
    	displaySpectrogram(O(:, :, 1), 'Target Spectrogram');
    	displaySpectrogram(O(:, :, 2), 'Interference Spectrogram');
    end

end
