function [SNR, SDR, SIR, SAR] = runTest(origTarget, origInterference, mixture, nfft, k, trainItr, sepItr, algorithm)
	S = SigSep(k, nfft);
	S.trainTarget(origTarget, trainItr);
	S.trainInterference(origInterference, algorithm, trainItr);
	[target, interference, tspec, ispec, C] = S.separate(mixture, sepItr);

	%setup values for testing purposes
	len = min([length(origTarget), length(origInterference), length(mixture)]);
	se = [target(1 : len) interference(1: len)];
	s = [origTarget(1 : len) origInterference(1 : len)];

	origTspec = signal2spec(origTarget(1 : len), nfft, nfft / 4);
	origIspec = signal2spec(origInterference(1 : len), nfft, nfft / 4);
	mspec = signal2spec(mixture(1 : len), nfft, nfft / 4);

	ispec = ispec * diag( 1 ./ sum(ispec));
	tspec = tspec * diag( 1 ./ sum(tspec));

	Mt = tspec - origTspec;
	Mi = ispec - origIspec;

	%run tests
	SNR = [snr(origTspec, tspec - origTspec), snr(origIspec, ispec - origIspec)];
	%SNRI = [snr3(origTspec, tspec, C) - snr3(origTspec, mspec, C), snr3(origIspec, ispec, C) - snr3(origIspec, mspec, C)];
	[SDR, SIR, SAR, perm] = bss_eval_sources(se',s');
end
