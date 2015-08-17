close all;
clear;
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

K = 10;

W = zeros(FFTSIZE / 2 + 1, K, 2);
   
V1 = signal2spec(tseries1, FFTSIZE, HOPSIZE);
W(:, :, 1) = trainBasisVectors(V1, K);

V2 = signal2spec(tseries2, FFTSIZE, HOPSIZE);
W(:, :, 2) = trainBasisVectors(V2, K);

plotBasisVectors(W(:, :, 1), 'First Set of Basis Vectors');
plotBasisVectors(W(:, :, 2), 'Second Set of Basis Vectors');

%create a new time series signal out of the 2 starting ones
newTseries = tseries1 + tseries2;

[V C s] = signal2spec(newTseries, FFTSIZE, HOPSIZE);
displaySpectrogram(V,'Combined Spectrogram');

[R, M, N] = seperate(W, V);

O = reconstruct(W, M, N, V);
O(:, :, 1) = O(:, :, 1) * diag(s);
O(:, :, 2) = O(:, :, 2) * diag(s);

displaySpectrogram(O(:, :, 1), 'Seperated Signal 1');
displaySpectrogram(O(:, :, 2), 'Seperated Signal 2');

S1 = O(:, :, 1) .* exp( sqrt(-1) * C);
S2 = O(:, :, 2) .* exp( sqrt(-1) * C);

Final1 = stft(S1, FFTSIZE, HOPSIZE, 0, 'hann');
Final2 = stft(S2, FFTSIZE, HOPSIZE, 0, 'hann');