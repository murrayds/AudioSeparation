function [W, H] = latentVariableDecomposition(tseries, K)
    close all;
    %as of now these are constants
    if nargin < 2
        K = 2;
    end
    if nargin < 1
        %load defaul files
        [tseries1, fs1] = wavread('chimes.wav');
        [tseries2, fs2] = wavread('voice.wav');
        
        %make each signal the same size
        minLen = min( [length(tseries1) length(tseries2)]);
        tseries1 = tseries1(1:minLen);
        tseries2 = tseries2(1:minLen);

        fs = 44100;
        window = 2048;
        FFTSIZE = window;
        HOPSIZE = window / 4;

        bases = zeros(FFTSIZE / 2 + 1, K, 2);
   
        V = stft(tseries1, FFTSIZE, HOPSIZE, 0, 'hann');
        W = trainBasisVectors(V, K);
        bases(:, :, 1) = W;

        V = stft(tseries2, FFTSIZE, HOPSIZE, 0, 'hann');
        W = trainBasisVectors(V, K);
        bases(:, :, 1) = W;

        return
    end

    fs = 44100;
    window = 2048;
    FFTSIZE = window;
    HOPSIZE = window / 4;

    %Using Paris Smaragdis's version of the stft as it seems to be very well
    %written and ensures that I can also use his istft function which is means to
    %work along side this. I slightly modified it to work in this context
    V = stft(tseries, FFTSIZE, HOPSIZE, 0, 'hann');

    %get phase information
    C = conj(V);

    %displaySpectrogram(V, fs, FFTSIZE, HOPSIZE);
   
    W = trainBasisVectors(V, K, 1);

    %generate a row vector of FFTSIZE/2 + 1 points between 0 and fs / 2
    %not being used as of right now
    frequencies = linspace(0, fs/2, FFTSIZE/2 + 1); 

    %the x-axis gives enough room to plot all components of K
    %Wg = log(W);
    figure;
    for i = 1 : K
        x_axis = ( i - 1) * max(max(W)) * 2 + (1 - (W(:, i)));
        plot( x_axis, 1 : FFTSIZE / 2 + 1, 'LineWidth', 1);
        hold on;
    end

    %axis tight;
    xlabel('Components');
    ylabel('Frequencies');
end