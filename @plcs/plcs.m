classdef plcs < handle
	%
	%Probabilistic Latent Component Seperation Class
	%
	% Author: Dakota Murray
	% Version: 17 June 2014
	%
	% This class contains all necessary methods used for taining bases vectors representing
	% the principal components of audio signals, as well as seperating sources based on those
	% trained vectors out of a novel mixture.
	%

	properties
		K		%number of components
		S       %number of speakers
		W		%Set of basic vectors calculated for each speaker
		nfft    %The number of frequency bins used to represent the signal
	end 

	methods
		function obj = plcs(K, nfft)
			if nargin < 1
				K = 10;
			end
			if nargin < 2
				nfft = 2048;
			end
			obj.K = K;
			obj.S = 0;
			obj.nfft = nfft;
		end

		function obj = clearTrainingData(obj, speaker)
			if nargin == 1
				obj.W = [];
				obj.S = 0;
				return;
			end
			if speaker > obj.S or speaker < 1
				disp('Please enter a valid value for the speaker. Must be greater than zero and less than S\n');
			    return;
			end
			obj.W(:, :, speaker) = [];
			obj.S = obj.S - 1;
		end

		obj = trainSpeaker(obj, speaker, tseries, hop, iterations)
		[obj X] = seperate(obj, tseries, hop, iterations)

	end
end