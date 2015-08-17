function plotBasisVectors(W, label)
	%
	% Author  : Dakota Murray
	% Version : 16 June 2014
	%
	% Encapsulates the logic of plotting the basis vectors creaded from 
	% latent variable decomposition of a spectrogram. 
	%
	% Inputs:
	%	W	  : A F x K matrix containing the bases vectors obtained through
	%		    latent variable decomposition. F is the number of frequency bins 
	%		    for each base and K is the number of components.
	%   Label : A label to place at the top of the graph. 
	%

	%set a default graph title if none is provided
	if nargin < 2
		label = 'Basis Vectors';
	end

	% remove any singleton dimensions
	W = squeeze(W);

	F = size(W, 1);
	K = size(W, 2);

	figure;
	% plot vectors, ensureing that there is enough space between each and that no overlap will occur
	for i = 1 : K
    	x_axis = ( i - 1) * max(max(W(:, :, 1))) * 2 + (1 - (W(:, i)));
    	plot( x_axis, 1 : F, 'LineWidth', 1);
    	hold on;
	end
	title(label);
end