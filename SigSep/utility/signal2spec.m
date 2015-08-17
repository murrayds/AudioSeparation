function [V, C, s] = signal2spec(data, sz, hop, normalize, pad )
	%
	% Author  : Dakota Murray
	% Version : June 16th 2014
	%
	% A function encapsulating the logic converting a time series to a spectrogram
	% and extracting all relavent information. The resulting spectrogram is normalized
	% so that each column will sum to one.  
	%
	% Inputs: 
	%	data   : A time series used to take the spectrogram of.
	%	sz     : The size of the spectrogam. Number of frequency bins resulting from the fft
	%	hop    : The hop size for the stft in the form of number of samples.
	%   pad    : The pad size in number of samples between windows. Used for the stft
	%
	% Outputs:
	%	V      : The processed and normalized spectrogram created from the input time series signal
	%	C      : The phase/complex components of the spectrogram V
	%	s      : The sum of V before normalization, used to convert calculated signals back to a time series

	% If no fft size provides, default is 1024 samples
	if nargin < 2
		sz = 1024;
	end
	% If none provided, hopsize is set to 1/4 of the fftsize
	if nargin < 3
		hop = sz / 4;
	end
	if nargin < 4
	    normalize = 0;
	end
	% If no padding value provided, then padding is set to zero
	if nargin < 5
		pad = 0;
	end

	%Take the stft of the time signal using a hanning window
	V = stft(data, sz, hop, pad, 'hann');
	sum(V);
	%obtain the phase/complex components of the spectrogram
	if nargout >= 2
		C = angle(V);
	end

	%Turn the complex spectrogram into a magnitude spectrogram
 	V = abs(V);
 	%Make it so higher frequencies are slightly more prominent
    V = V .* repmat( linspace( 1, 10, size( V, 1))', 1, size( V, 2));
    %normalize so all columns sum to one
    if (normalize ~= 1)
    	normalize;
    	s = sum(V);
    	V = V * diag(1 ./ s );
    end
end
