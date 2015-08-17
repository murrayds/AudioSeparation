function [peaks locations] = plotPeaks(signal, fs, peak_distance, peak_height);
    %
    % DESCRIPTION:
    % a function whcih will simply find, return, and plot the peaks of a 
    % using parameters mpassed through user input.
    %
    $ OUTPUTS:
    % peaks : the y-axis values of each found in the provided signal
    % locations: the x-coordinate locations of each peak found in the signal
    %
    % INPUTS:
    % signal : the time series signal to parse 
    % fs : the sampling rate of the time series signal, used for plotting
    % peak_distrance: the minimum distance that 2 peaks should be from one another
    %				  in order to be identified as a peak
    % peak_height : the minumum height that a value should be before being 
    %				considered as a peak


    if nargin < 4 
    	peak_height = .1;
    end
    if nargin < 3
        peak_distance
    end
    if nargin < 2
    	fs = 44100;
    end

    [peaks, locations] = findpeaks(signal, 'MinPeakDistance', peak_distance, 'MinpeakHeight', .2);    X = (0 : numel(signal) - 1) / fs;
    plot( X, signal, X(locations), peaks, 'rv', 'MarkerFaceColor', 'r');
    grid on;
    xlabel('Time (in seconds)')
    ylabel('Amplitude');
    title('Audio Peaks');
    legend('Audio Signal Amplitude', 'Peaks');

end