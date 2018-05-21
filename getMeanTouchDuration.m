function [m, s] = getMeanTouchDuration(actions, touch_time, windows)
%function getMeanTouches
%
% in an mx1 vector of touch actions.
%   0 or 5: DOWN
%   1 or 6: UP
%   2: MOVE
%
% and an mx1 vector of the corresponding
% absolute timestamps 
%
% and a column vector of windows over which the
% mean values should be collected
% [startTime1; startTime2; ... ; endTime]
%
% and returns a vector m that is the mean time between DOWN and UP actions
% over the nonoverlapping windows.
%
% and a vector s that is the std deviation of time between DOWN and UP actions
% over the nonoverlapping windows.

v_length = length(windows) - 1;

m = zeros(v_length, 1); %preallocate for speed
s = zeros(v_length, 1);

for i = 1:v_length % for every window
    
    %find the start and end time of this window
    startTime = windows(i); 
    endTime = windows(i+1);
    
    %find the corresponding indeces of the input matrix
    startIndex = find( touch_time >= startTime, 1);
    endIndex = find(touch_time >= endTime, 1) - 1;
    
    %extract the portions of the time vector and actions vector
    %corresponding to the window
    value_range = actions(startIndex :endIndex, :);
    time_range = touch_time(startIndex :endIndex, :);
    
    %sometimes, a touch event will not have been registed in this window
    %that should yield a duration of 0.
    if isempty(time_range)
        m(i) = 0;
        continue;
    end
    
    pressTimes = [];
    totalPresses = 0;
    
    %while there are still up events in the set of values
    while ismember(1, value_range) || ismember(6, value_range)
        
        %if the first member of value_range is a not a down press
        if value_range(1) ~= 0 && value_range(1) ~= 5
            % move one row down
            value_range = value_range(2:end);
            time_range = time_range(2:end);
            continue
            
        else
            
            %record the time of the down press
            down_time = time_range(1);
            
            %find  the index of the up release
            up_index = find(value_range == 1 | value_range == 6, 1);
            
            %find the corresponding time of the up release
            up_time = time_range(up_index); 
            
            %find elapsed press time
            pressTime = up_time - down_time;
           
            %add the elapsed press time to the total and increment counter
            pressTimes(totalPresses + 1) = pressTime;
            totalPresses = totalPresses + 1;
            
            % move to the end of this press event
            value_range = value_range(up_index +1:end);
            time_range = time_range(up_index + 1:end);
            
        end
        
        
    end
    avgPressTime = mean(pressTimes);
    stdPressTime = std(pressTimes);
    
    if isnan(avgPressTime) % 0 / 0
        avgPressTime = 0;
    end
    
    if isnan(stdPressTime) % 0 / 0
        stdPressTime = 0;
    end
    
    
    m(i) = avgPressTime;
    s(i) = stdPressTime;
    
            
        
end

end