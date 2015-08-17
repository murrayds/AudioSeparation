function displaySpectrogram(X, label)
    % 
    % Author  : Dakota Murray (with some insight and code borrowed from Paris Smaragdis)
    % Version : 16 June 2014
    %
    % Contains all logic for displaying a spectrogram in the form used by Paris Smaragdis.
    % Assumes that the input spectrogram is normalized so that each column is a multinomial
    % distribution in which all values sum to one.
    %
    % Inputs:
    %   X      : A magnitude spectrogram. Assumed to be normalized so that each column sums to one
    %   label  : The title to place on the spectrogram graph. 
    
    %

    if nargin < 2
      label = 'Spectrogram';
    end
    X = abs(X);
    t = 1 : size(X, 2);
    f = 1 : size(X, 1);
    Xdb = 20*log10(abs(X));
  	Xmax = max(max(Xdb));
 	  
  % Clip lower limit to -dbdown dB so nulls don't dominate:
  	dbdown = Xmax - min(min(Xdb));
  	clipvals = [Xmax-60, Xmax];

  	figure;
  	imagesc(t,f,Xdb, clipvals);
  	% grid;
  	axis('xy');
  	colormap(hot);
  	xlabel('Time frames');
  	ylabel('Frequency Bins');
    title(label);
end