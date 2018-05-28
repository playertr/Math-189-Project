function N = normalize(X)
% N = normalize(X) returns the vectorwise z-score of the data in X with 
% center 0 and standard deviation 1.
% normalize(X) = x - x_mean / std(X)
    N = X - mean(X) ./ std(X);
end