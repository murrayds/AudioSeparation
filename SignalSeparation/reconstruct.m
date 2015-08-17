function O = reconstruct(W, M, N, V)

	%one speaker only for now
	F = size(W, 1);
	S = size(W, 3);
	T = size(V, 2);

    O = zeros(F, T, S);
    for s = 1 : S
        O(:, :, s) = squeeze(W(:, :, s)) * squeeze(N(:, s, :)) * diag(M(s, :)) ;
    end;

    O = bsxfun(@rdivide, O, sum(O, 3));

    for s = 1 : S
        O(:, :, s) = O(:, :, s) .* V;
    end;
 end