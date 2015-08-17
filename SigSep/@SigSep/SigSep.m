classdef SigSep < handle
	%
	% Author : Dakota Murray
	% Version: 26 June 2014
	%
	% SigSep(K, FFTSIZE) 
	%
	% SigSep stands for SignalSeparater. This class implements algorithms detailed by Paris Smaragdis in
	% order to separate mixtures into two signals: One being the "Target" and the other being the "Interference".
	% In order to do this one may train a model for both the target and the interference of a signal and use these
	% two known models as criteria to separate a novel mixture. One may also only train only the "Target" and then
	% have the interference be representative of everything else. 
	%
	% To use this class one must first train the model representing the target and the interference. Simply call
	% the method "trainTarget()" and pass in the appropriate information to train a model for the target. There 
	% are two current methods to train the interference. If the method being used is classified as semi-supervised
	% or unsupervised then the target Must have already been trained first. 
	%
	% After the target and interference models have been trained, simply call the method "separate" in order to 
	% separate a mixture.
	%
	% An example of workflow using this class is as follows:
	%
	%  >> S = SigSep(10, 2048);     			%instantiate the class
	%  >> [t1 fs] = wavread('sound1.wav')		%load first sound
	%  >> t2 = wavread('sound2.wav')			%load second sound
	%  >> mixutre = S.createMixture(t1, t2) 	%create a mixture from the two sound files
	%  >> S = S.trainTarget(t1)					%train target with default number of max iterations
	%  >> S = S.trainInterference(t2, 'known') 	%train the interference using a completely supervised algorithm
	%  >> [s1 s2] = S.separate(mixture, 200, 'on') %separate the mixture with plotting of results on
	%  >> sound(s1, fs)							%listen to resulting time series to ensure it worked.
	%
	% It is also worth noting that "target" and "Intergerence" are relative terms. Target may also be trained using
	% the background noise of a signal/ For example: If given a recording of a woman talking with birds in the background,
	% the target may be trained on either the birds or the voice, and the interference can be trained on the mixture. 
	% It is perhaps easier to think of our Target as what we know, ie: what we have training data for.
    %
	% In order for the class to function correctly, ensure that the sampling rate on each provided signal is
	% identical. It is also worth noting that the more training data provided and components specified, the 
	% more accurate the results are likely to be. The drawback is computational time.  
	%
	% email questions, comments, and concerns to AetherBlossom@gmail.com
	%

	properties
		targetW				% Model representing the target of the separation: "What we want"
		targetH				% Weights obtained from training the target. used for semi-supervised or unsupervised separation
		interferenceW		% Model representing the interference of the separation: "Everything else";
		K 					% The number of components used to construct the models
		FFTSIZE				% The number of frequency bins to be present in spectrograms. F = FFTSIZE / 2 + 1
	end

	properties (Constant)
		delta = 1e-3;		% The amount of change in iterative algorithms before convergence is assumes
	end

	methods
	
	    %Basic constructor which sets proper defaults
		function obj = SigSep(K, FFTSIZE)
			if nargin < 2
				FFTSIZE = 2048;
			end
			if nargin < 1
				K = 10;
			end
			obj.K = K;
			obj.FFTSIZE = FFTSIZE;
		end

		function clear(obj)
			obj.targetW = [];
			obj.targetH = [];
			obj.interferenceW = [];
		end

		% Removes the training data of the target
		function obj = clearTarget(obj)
			obj.targetW = [];
			obj.targetH = [];
		end

		% Removed the training data of the interference
		function obj = clearInterference(obj)
			obj.interferenceW = [];
		end

		% Returns true if the target model is trained, false otherwise
		function val = isTargetTrained(obj)
			val = ~isempty(obj.targetW);
		end

		% Returns true if the interference model is trained, false otherwise
		function val = isInterferenceTrained(obj)
			val = ~isempty(obj.interferenceW);
		end
	
		% These methods kept inside external files	
		obj = trainTarget(obj, signal, maxitr)
		obj = trainInterference(obj, signal, alg, maxitr)
		[target, interference, tspec, ispec, C] = separate(obj, mixture, maxitr, plot)

	end

	methods (Static)

		% A static method encapsulating the logic needed to create a mixture from
		% two time series signals
		function mixture = createMixture(signal1, signal2)
			[minLen pos] = min([length(signal1) length(signal2)]);
			signal1 = signal1(1 : minLen, 1);
			signal2 = signal2(1 : minLen, 1);
			mixture = signal1 + signal2;
		end
	end
end
