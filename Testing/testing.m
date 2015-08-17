close all;
clear all;
K = 10;
nfft = 4096;
iterations = 200;

S = SigSep(K, nfft);
tic
disp('Reading Audio Files');
traffic = wavread('traffic.wav');
traffic = traffic(:, 1);
bees = wavread('bees.wav');

traffic(abs(traffic) < 1e-12) = 1e-12;
bees(abs(bees) < 1e-12) = 1e-12;
fs = 44100;

disp('Creating Mixtures');
mixture = wavread('mixture.wav');
mixture = mixture(:, 1);

test = mixture(1 : fs * 10);

targetTraining = traffic(fs * 10 + 1 : end);
interferenceTraining = mixture(fs * 10 + 1 : end);

disp('Training Target');
S.trainTarget(targetTraining, iterations);

disp('Training Interference');
S.trainInterference(interferenceTraining, 2, iterations);

disp('Beginning Separation');
[target, interference, tspec, ispec, C] = S.separate(test, iterations);

toc
len = min([length(target) length(interference) length(traffic) length(bees) length(mixture)]);


origIspec = signal2spec(bees(1 : len), nfft, nfft / 4);

disp('------------------------------------');
M = ispec - origIspec;
ratio = snr(origIspec, M);
fprintf('SNR (basic) Interference: %0.4fdB\n', ratio);

ratio2 = snr2(origIspec, ispec, C);
fprintf('SNR (advanced) Interference: %0.4fdB\n', ratio2);

se = [target(1 : len), interference(1 : len)];
s = [traffic(1 : len), bees(1 : len)];
printResults(se', s');
