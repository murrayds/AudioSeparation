function printResults(se, s)
	[SDR, SIR, SAR, perm] = bss_eval_sources(se,s);
%	fprintf('SDR target: %0.4fdB\n', SDR(1));
	fprintf('SDR Interference: %0.4fdB\n', SDR(2));
%	fprintf('SIR Target: %0.4fdB\n', SIR(1));
	fprintf('SIR Interference: %0.4fdB\n', SIR(2));
%	fprintf('SAR Target: %0.4fdB\n', SAR(1));
	fprintf('SAR Interference: %0.4fdB\n', SAR(2));
end