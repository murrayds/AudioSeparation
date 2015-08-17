function plotAllGraphs(data)
    attribute = {'SNR', 'SNRI', 'SDR', 'SIR', 'SAR'};
    NFFT = [1024, 2048, 4096, 8192];
    K = [5, 10, 20, 40];

    for t = 1 : length(NFFT)
    	for s = 1 : length(K)
    		for a = 1 : length(attribute)
    			filename = sprintf('graphs_testing_iterations/graph_%unfft_%uk_%s.jpg', NFFT(t), K(s), char(attribute(a)));
    			plotOneResult_Parameters(data, K(s), NFFT(t), char(attribute(a)), filename);
    		end
    	end
    end
end