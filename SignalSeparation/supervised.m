close all;
clear all;


[tseries1 fs1] = wavread('voice.wav');
[tseries2, fs2] = wavread('chimes.wav');

tseries1(tseries1 == 0) = 1e-12;

tseries2(tseries2 == 0) = 1e-12;

%make each signal the same size
minLen = min( [length(tseries1) length(tseries2)]);
tseries1 = tseries1(1:minLen);
tseries2 = tseries2(1:minLen);

mixture = tseries1 + tseries2;

fs = 44100;
window = 2048;
FFTSIZE = window;
HOPSIZE = window / 4;

K = 10;
disp('Training Dictionary for Target');
targetV = signal2spec(tseries1, FFTSIZE, HOPSIZE);
[targetW, targetH] = trainBasisVectors(targetV, K);

plotBasisVectors(targetW, 'Known Basis Vectors');

V = signal2spec(tseries2, FFTSIZE, HOPSIZE);
displaySpectrogram(V, 'Second Time Series');

disp('Learning Dictionary for Interference');
interferenceW = trainInterference_SemiSupervised(V, targetW, targetH);
plotBasisVectors(interferenceW, 'Learned Basis Vectors');

W = cat(3, targetW, interferenceW);
[V C s] = signal2spec(mixture, FFTSIZE, HOPSIZE);

disp('Beginning Separation');
[R, M, N] = seperate(W, V);

disp('Beginning Reconstruction');
O = reconstruct(W, M, N, V);
O(:, :, 1) = O(:, :, 1) * diag(s);
O(:, :, 2) = O(:, :, 2) * diag(s);

displaySpectrogram(O(:, :, 1), 'Seperated Signal 1');
displaySpectrogram(O(:, :, 2), 'Seperated Signal 2');

S1 = O(:, :, 1) .* exp( sqrt(-1) * C);
S2 = O(:, :, 2) .* exp( sqrt(-1) * C);

Final1 = stft(S1, FFTSIZE, HOPSIZE, 0, 'hann');
Final2 = stft(S2, FFTSIZE, HOPSIZE, 0, 'hann');
disp('All Finished');