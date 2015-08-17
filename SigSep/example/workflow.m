% Author : Dakota Murray
% Version: 26 June 2014
% 
% A simple example of workflow sing the SigSep class

close all;
clear all;

p = strcat(pwd, '\..');
addpath(p);

%initialize a new SigSep object with 10 components and fft size of 2048
SS = SigSep(10, 2048);

%load audio files
chimes = wavread('chimes.wav');
voice  = wavread('voice.wav');

mixture = SS.createMixture(chimes, voice);

%train target 
SS.trainTarget(voice);

%train interference using a semi supervised algorithm.
SS.trainInterference(mixture, 'fixed');

plotBasisVectors(SS.targetW, 'Target Basis Vectors');
plotBasisVectors(SS.interferenceW, 'Interference Basis Vectors');

% separate the mixture, plot results
[target, interference, tspec, ispec] = SS.separate(mixture, 300, 'on');

cd ../utility
displaySpectrogram(tspec, 'Separated Target', 'Images/sep_target');
displaySpectrogram(ispec, 'Separated Interference', 'Images/sep_interference');

OT = signal2spec(target, 2048, 2048 / 4, 1);
OI = signal2spec(interference, 2048, 2048 / 4, 1);

displaySpectrogram(OT, 'Original Target', 'Images/orig_target');
displaySpectrogram(OI, 'Original Interference', 'Images/orig_interference');

M = signal2spec(mixture, 2048, 2048 / 4, 1);
displaySpectrogram(M, 'Mixture', 'Images/mixture');
