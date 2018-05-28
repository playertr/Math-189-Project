function [ newA] = getAvg(input_matrix, time, windows)
%function getAvg: this takes in an mxn matrix (where m is ~70000
%entrieslong)corresponding to ~11 minutes of data
% (collected with f = 100 Hz) 
%
% and an mx1 vector of the corresponding
% absolute timestamps 
%
% and a column vector of windows over which the
% mean values should be collected
% [startTime1; startTime2; ... ; endTime]
%
% and returns a matrix that is the result of taking the 
% mean value of the input matrxi over the nonoverlapping windows.

newA_length = length(windows) - 1;

newA = zeros(newA_length, size(input_matrix,2)); %preallocate for speed

for i = 1:newA_length % for every row in the new matrix
    
    %find the start and end time of this window
    startTime = windows(i); 
    endTime = windows(i+1);
    
    %find the corresponding indeces of the input matrix
    startIndex = find( time >= startTime, 1);
    endIndex = find(time >= endTime, 1) - 1;
    
    %this row becomes the mean of those rows of accel_matrix
    newA(i, :) = mean( abs(input_matrix(startIndex :endIndex, :)) );
end

end