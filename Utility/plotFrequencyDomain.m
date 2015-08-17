function [frequencies] = plotFrequencyDomain(signal, fs)
    %
    % DESCRIPTION:
    % calculates and plots the frequency domain of a provided time series and
    % returns the calculated set of frequency amplitudes. 
    %
    % OUTPUTS:
    % frequencies: a matrix containing the amplitude of each frequency in the signal. The position
    % 			   in the matrix corresponds to the frequency and the value held within corresponds
    %			   to the amplitude of that frequency
    %
    % INPUTS:
    % signal: 	   the time series which will be used to calculate the frequency domain. 
    % fs:		   the sampling rate of the provided signal


    % Next power of 2 from length of y
    NFFT = 2^nextpow2( length(signal) ); 
    frequencies = fft(signal,NFFT) / length(signal);
    f = fs/2*linspace(0,1,NFFT/2+1);

    plot( f , 2*abs( frequencies(1:NFFT/2+1)), 'r') 
    title('Frequency Domain')
    xlabel('Frequency (Hz)'); ylabel('|Y(f)|'); grid on;

end