close all;
clear all;
K = 20;
nfft = 1024;
trainingIterations = 50;
sepIterations = 50;
fs = 44100;

fprintf('Statistics\n')
disp('------------------------------------');
fprintf('NFFT: %d\n', nfft);
fprintf('K: %d\n', K);
fprintf('Training Iterations: %d\n', trainingIterations);
fprintf('Separation Iterations: %d\b', sepIterations);
fprintf('Sampling Rate: %d\n', fs);


disp('------------------------------------');
S = SigSep(K, nfft);
disp('loading data');
chimes = wavread('chimes.wav');
voice  = wavread('voice.wav');

%normalize to zero mean and unit variance
chimes = (chimes - mean(chimes)) / std(chimes);
voice = (voice - mean(voice)) / std(voice);

tic
disp('Training Target');
S.trainTarget(voice, trainingIterations);
disp('Training Mixture');
S.trainInterference(chimes, 1, trainingIterations);

mixture = S.createMixture(chimes, voice);

disp('Performing Separation');
[target, interference, tspec, ispec, C] = S.separate(mixture, sepIterations);
disp('------------------------------------');
toc

len = length(voice);
se = [target(1 : len) interference(1: len)];
s = [voice(1 : len) chimes(1 : len)];

origIspec = signal2spec(chimes(1 : len), nfft, nfft / 4);
mspec = signal2spec(mixture(1 : len), nfft, nfft / 4);

sumI = sum(ispec);
sumM = sum(mspec);
mspec = mspec * diag( 1 ./ sumM);
ispec = ispec * diag( 1 ./ sumI);

M = ispec - origIspec;
ratio = snr(origIspec, M);
fprintf('SNR (basic) Interference: %0.4fdB\n', ratio);

ratio3 = snr3(origIspec, ispec, C) - snr3(origIspec, mspec, C);
fprintf('SNR Improvement: %0.4fdB\n', ratio3);

printResults(se', s');
