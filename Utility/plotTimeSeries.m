function plotTimeSeries(signal, fs)
    %
    % DESCRIPTION:
    % A simple function to encapsulate the logic of plotting a time plotTimeSeries
    %
    % OUTPUTS: None
    %
    % INPUTS:
    % signal: the time series signal to plot
    % fs: the sampling rate of the provided time series signal


    plot( (0 : numel(signal) - 1) / fs, signal);
    xlabel('Time (seconds)'); ylabel('amplitude'); grid on;
    ylim([-1 1]);

end