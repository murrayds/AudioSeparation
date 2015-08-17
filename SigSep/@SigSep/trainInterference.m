function obj = trainInterference(obj, signal, alg, maxitr)
	%
	% Author: Dakota Murray
    % Version: 26 June 2014
    %
    % This function trains a model representing the interference of a signal by using one
    % of several algorithms. The algorithms are defined as:
    % 
    %  - A supervised algorithm where by we train models for both the target and interference. The 
    %     interference will be trained by using a signal containing only the sound labeled as interference.
    %
    %   - A semi-supervised algorithm designated as "semi" where by the model for the interference is trained 
    %     direct from a mixture containing the target sound. In this case the target must have already been 
    %     trained. The already trained target models are not altered. 
    %
    %   - Another semi-supervised algorithm designated as "prior" which acts in exactly the same way as the 'semi'
    %     algorithm except that the previously trained target models will be altered. 
    %
    % Inputs:
    %   obj     : The SigSep object this function is being called on
    %   signal  : Either a time series signal or an already processed spectrogram representing
    %             either a mixture signal or training data depending on the algorithm
    %   alg     : Either a character array or an integer denoting which algorithm to use
    %               1: 'known'    - Train interference using training data
    %               2: 'fixed'    - Train interference using a mixture, target model is fixed
    %               3: 'unfixed'  - Train interference using mixture, target model may be altered (Not implemented yet)
    %   maxitr  : Training the interference uses an iterative algorithm. maxitr defines the maximum 
    %             number of iterations to be calculated
    % Oututs:
    %   obj     : A version of the SigSep object passed into the function with interference data updated  
    %
    % Email questions, comments and concerns to AetherBlossom@gmail.com
    %
    
    %default to a the semi-supervised "fixed" algorithm
    if nargin < 3
        alg = 2;
    end
    if nargin < 4
        maxitr = 300;
    end

    V = [];
	if size(signal, 2) == 2
		disp('Time Series signal must be a vector!\n Using first channel only');
		signal = signal(:, 1);
	end
	if isvector(signal)
		signal(signal == 0) = 1e-12;
		V = signal2spec(signal, obj.FFTSIZE, obj.FFTSIZE / 4);
	elseif ismatrix(signal)
		V = signal;
	else
		disp('Please enter a Time Series Signal or a Spectrogram for signal!\n');
        return;
	end

	W = [];
    alg = lower(alg);
	if alg == 1 | strcmp(alg, 'known')
		W = trainInterference_Supervised(obj, V, maxitr);
	end

	if alg == 2 | strcmp(alg, 'fixed')
        if ~obj.isTargetTrained
            disp('Must Train Target First before a non-fully supervised algorithm');
            return;
        end
		W = trainInterference_SemiSupervisedFixed(obj, V, maxitr);
	end

    if alg == 3 | strcmp(alg, 'unfixed')
        if ~obj.isTargetTrained
            disp('Must Train Target First before a non-fully supervised algorithm');
            return;
        end
        [target, W] = trainInterference_Unfixed(obj, V, maxitr);
        obj.targetW = target;
    end
    obj.interferenceW = W;
end
