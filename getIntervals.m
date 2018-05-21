function [ windows ] = getIntervals(time, interval)
%function getIntervals: this takes in an mx1 column vector of absolute
%timestamps in milliseconds. It then divides the vector into sections
%corresponding to "interval"-second windows. E.g., if interval is 10, the
%function retrieves sets of nonoverlapping 10-second windows, in the format
%[t1; t2; t3]

msInt = interval * 1000; %convert interval to milliseconds
endT = time(end);
startT = time(1);

windows =  (startT : msInt : endT)';

end