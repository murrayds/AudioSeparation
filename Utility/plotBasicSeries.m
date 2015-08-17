function plotBasicSeries(signal, fs)
    %
    % DESCRIPTION:
    % A simple helper function used to plot the time series and frequency
    % domain of a signal
    %
    % OUTPUTS: None
    %
    % INPUTS:
    % signal:   the time series to be plotted
    % fs:       the sampling rate of the time series signal 

    %plot the time series of the signal   
    ax(1) = subplot(211);
    plotTimeSeries(signal, fs);

    %plot frequency domain
    ax(2) = subplot(212);
    plotFrequencyDomain(signal, fs);

end