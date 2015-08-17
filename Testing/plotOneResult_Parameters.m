function plotOneResult_Parameters(ds, numK, numNFFT, attribute, filename)
	f = figure;
	X = ds(ds.K == numK & ds.NFFT == numNFFT, :);

	t_attribute = sprintf('%s_Target', attribute);
	i_attribute = sprintf('%s_Interference', attribute);
	
	iterations = [50, 100, 200, 300];

	Y = zeros(4, 4);
	Z = zeros(4, 4);
	for i = 1 : 4
		for j = 1 : 4
			Y(i, j) = X(X.Training_Iterations == iterations(i) & X.Separation_Iterations == iterations(j), {t_attribute});
			Z(i, j) = X(X.Training_Iterations == iterations(i) & X.Separation_Iterations == iterations(j), {i_attribute});
		end
	end

	subplot(1, 2, 1);
	bar3(Y);

	%setup graph ticks and labels for target
	set(gca, 'XTickLabel', [50, 100, 200, 300]);
	set(gca, 'YTickLabel', [50, 100, 200, 300]);
	xlabel('Separation Iterations');
	ylabel('Training Iterations');
	zlabel('SNR');
	title('Target');

	subplot(1, 2, 2);
	bar3(Z);
	%setup graph ticks and labels for interference
	set(gca, 'XTickLabel', [50, 100, 200, 300]);
	set(gca, 'YTickLabel', [50, 100, 200, 300]);
	xlabel('Separation Iterations');
	ylabel('Training Iterations');
	zlabel('SNR')
	title('Interference');

	overall = sprintf('%d Components and %d Frequency Bins', numK, numNFFT);
	mtit(f, overall);

	if nargin > 4
		saveas(f, filename);
		close(f);
	end
end