function [R, M, N] = seperate(W, V)

	iterations = 100;

	F = size(V, 1);
	T = size(V, 2);
	K = size(W, 2);
	S = size(W, 3);


	%should these be normalized to begin with?
	R = rand(S, K, F, T);
	M = rand(S, T);
	N = rand(K, S, T);
	lastN = N;

	for i = 1 : iterations
		lastN = N;

		% calculate Pt(s, z | f)
		Rt = R;
		for s = 1 : S
			parfor k = 1 : K
				Rt(s, k, :, :) = ( squeeze(W(:, k, s)) * squeeze(N(k, s, :))' ) * diag(M(s, :));
			end
		end
	
		%Normalize each speaker/component spectrogram so that the sum of each index ij across
		%all speaker and components will sum to 1. 
		R = bsxfun(@rdivide, Rt, ((sum(sum(Rt, 2), 1))));

		%Now time to calculate Pt(s)
		Nt = N;
		for s = 1 : S
			parfor k = 1 : K
    			Nt(k, s, :) = sum( squeeze(R(s, k, :, :)) .* V, 1);
			end
		end
		N = bsxfun(@rdivide, Nt, sum(Nt, 1));

		Mt = M;
		parfor s = 1 : S
			Mt(s, :) =  sum(V .* squeeze(sum( squeeze(R(s, :, :, :)), 1)), 1);
		end
		M = bsxfun(@rdivide, Mt, sum(Mt, 1));
		
	end
end
