function ratio = snr(S, N)
	Ps = var(S(:));
	Pn = var(N(:));
	ratio = 10 * log10(Ps / Pn);
end