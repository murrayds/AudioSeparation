function plotOneResult_Averaged(ds, attribute);
	f = figure;
	
	NFFT = [1024, 2048, 4096, 8192];
	K = [5, 10, 20, 40];

	t_attribute = sprintf('%s_Target', attribute);
	i_attribute = sprintf('%s_Interference', attribute);

	Y = zeros(4, 4);
	Z = zeros(4, 4);
	for i = 1 : 4
		for j = 1 : 4
			Y(i, j) = X(X.NFFT == NFFT(i) & X.K == K(j), {t_attribute});
			Z(i, j) = X(X.NFFT == NFFT(i) & X.K == K(j), {i_attribute});
		end
	end

	subplot(1, 2, 1);
	bar3(Y);

	%setup graph ticks and labels for target
	set(gca, 'XTickLabel', [5, 10, 20, 40]);
	set(gca, 'YTickLabel', [1024, 2048, 4096, 8192]);
	xlabel('Bases');
	ylabel('NFFT');
	zlabel(attribute);
	title('Target');

	subplot(1, 2, 2);
	bar3(Z);
	%setup graph ticks and labels for interference
	set(gca, 'XTickLabel', [5, 10, 20, 40]);
	set(gca, 'YTickLabel', [1024, 2048, 4096, 8192]);
	xlabel('Bases');
	ylabel('NFFT');
	zlabel('attribute');
	title('Interference');


	if nargin > 4
		saveas(f, filename);
		close(f);
	end
end