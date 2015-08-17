function [V, C] = signal2spec(data, sz, hop, pad)
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
	%

	%Take the stft of the time signal using a hanning window
	V = stft(data, sz, hop, pad, 'hann');
	





 	V = abs(data);
    %V = abs(data) .^ 2;
    V = V .* repmat( linspace( 1, 10, size( V, 1))', 1, size( V, 2));
    s = sum(V);
    V = V * diag(1 ./ s );
    %displaySpectrogram(V, 44100, 2048, 2048/4);
end