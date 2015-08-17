function plotOneResult_Iterations(ds, numTrainItr, numSepItr, attribute, filename)
	f = figure;
	X = ds(ds.Training_Iterations == numTrainItr & ds.Separation_Iterations == numSepItr, :);
	
	Y = zeros(4, 4);
	Z = zeros(4, 4);

	t_attribute = sprintf('%s_Target', attribute);
	i_attribute = sprintf('%s_Interference', attribute);

	Y(:, 1) = X(X.K == 5,  {t_attribute});
	Y(:, 2) = X(X.K == 10, {t_attribute});
	Y(:, 3) = X(X.K == 20, {t_attribute});
	Y(:, 4) = X(X.K == 40, {t_attribute});
	
	Z(:, 1) = X(X.K == 5,  {i_attribute});
	Z(:, 2) = X(X.K == 10, {i_attribute});
	Z(:, 3) = X(X.K == 20, {i_attribute});
	Z(:, 4) = X(X.K == 40, {i_attribute});

	subplot(1, 2, 1);
	bar3(Y);

	%setup graph ticks and labels for target
	set(gca, 'XTickLabel', [5, 10, 20, 40]);
	set(gca, 'YTickLabel', [1024, 2048, 4096, 8192]);
	xlabel('Bases');
	ylabel('NFFT');
	zlabel('SNR');
	title('Target');

	subplot(1, 2, 2);
	bar3(Z);
	%setup graph ticks and labels for interference
	set(gca, 'XTickLabel', [5, 10, 20, 40]);
	set(gca, 'YTickLabel', [1024, 2048, 4096, 8192]);
	xlabel('Bases');
	ylabel('NFFT');
	zlabel('SNR');
	title('Interference');

	overall = sprintf('%d Training Iterations and %d Separation Iterations', numTrainItr, numSepItr);
	mtit(f, overall);

	if nargin > 4
		saveas(f, filename);
		close(f);
	end
end