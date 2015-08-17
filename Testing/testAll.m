function OUT = testAll(OUT, count, startK, startNfft)
K = [5, 10, 20, 40];
NFFT = [1024, 2048, 4096, 8192];
iterations = 100;
tests = 5;
algorithm = 1;

if nargin < 1
    OUT = zeros(11, 5, 16)
end
if nargin < 2
    count = 1;
end
if nargin < 3
	startK = 1;
end
if nargin < 4
	startNfft = 1;
end
%load the data
interference = wavread('/u/css/murrayds/code/SigSep/example/chimes.wav');
target  = wavread('/u/css/murrayds/code/SigSep/example/voice.wav');
%normalize to zero mean and unit variance
interference = (interference - mean(interference)) / std(interference);
target = (target - mean(target)) / std(target);
mixture = SigSep.createMixture(interference, target);
features = zeros(1, 9);
try
for k = startK : length(K)
	for nfft = startNfft : length(NFFT)
		for i = 1 : tests
			fprintf('Iteration: %d\t nfft: %d\t k: %d\t test: %d\n', count, NFFT(nfft), K(k), i);
            tic;
			[SNR, SDR, SIR, SAR] = runTest(target, interference, mixture, NFFT(nfft), K(k), iterations, iterations, algorithm);
            elapsed = toc;
			features = [SNR(1), SNR(2), SDR(1), SDR(2), SIR(1), SIR(2), SAR(1), SAR(2), elapsed];
            OUT(:, i, count) = [NFFT(nfft), K(k), features];
		end
		count = count + 1;

        %save the current state of the program
        state = [count, k, nfft];
        save('state.mat', 'state');
        save('output.mat', 'OUT');
    end
end
catch err
    save('output.mat', 'OUT');
end
save('output.mat', 'OUT');
end
