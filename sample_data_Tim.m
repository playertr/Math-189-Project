clear all, close all, clc

num_features = 10; %We collect mean Ax, Ay, Az, and std Ax, Ay, Az data 
% and the mean touch duration, std touch duration, mean orientation,
% std orientation

% Define source file
%file = '/Users/kevinjcotton/Downloads/public_dataset'; %Kevin
file = './HMOG_public_dataset/unzipped'; % Tim

users = get_directory_names(file);
num_users = length(users);

% Each user has ~12 sitting sessions with ~10 minutes of data. We are collecting
% features corresponding to average values over 10 seconds, thus we expect
% [num_users * 12 * 10 * 60 / 10] = [1080 * num_users] discrete
% observations.
% To prevent memory fragmentation, we will preallocate that amount then
% trim the resulting rows of zeros.
expected_rows = 1080 * num_users;
%y_results: a categorical vector of cells e.g. {'Reading'}
y_results = cell(expected_rows, 1);

% DEPRECATED y_results: a one hot vector [Reading Writing Map]

% X_input: the N x d design matrix
X_input = zeros(1080 * num_users, num_features);

row_num = 1; %row to add input and output to
for i = 1:num_users
    u = users{i};
    sessions = get_directory_names(strcat(file, '/', u));
    num_sessions = length(sessions);
    
    for j = 1:num_sessions
        s = sessions{j};
        
        folder = strcat(file, '/', u, '/', s);
        
        %Read the single number from Activity.csv
        %that corresponds to the activity
        activity_file = strcat(folder, '/', 'Activity.csv');
        
        %That number is in the first row, 9th column (0,8)
        activity = csvread(activity_file, 0, 8, [0 8 0 8]);
        
        %The number has the following possible meanings
        switch activity
            case {1, 7, 3, 19}
                activity = {'Reading'}; %and sitting
            case {3, 9, 15, 21}
                activity = {'Writing'}; %and sitting
            case {5, 11, 17, 23}
                activity = {'Map'}; %and sitting
            otherwise %Not sitting ==> ignore
                continue; %try next session
        end
        
        %Get acceleration and orientation, and time data
        %Read in the accelerations file
        accel_file =  strcat(folder, '/', 'Accelerometer.csv');

        accelerationFile = csvread(accel_file);
        
        
        accel_time = accelerationFile(:, 1); %the first column is the absolute timestamps
        
        %Generate window intervals for collecting descriptive time-series
        %statistics
        windows = getIntervals(accel_time, 20); %ten second windows
        
        orientation = accelerationFile(:, 7);
        acceleration = accelerationFile(:, (4:6));
                

        %collect acceleration features
        meanAccel = getAvg(acceleration, accel_time, windows);
        stdAccel = getStd(acceleration, accel_time, windows);
        
        %collect orientation features
        meanOrientation = getAvg(orientation, accel_time, windows);
        stdOrientation = getStd(orientation, accel_time, windows);
        
        %Get TouchEvent data
        touch_file =  strcat(folder, '/', 'TouchEvent.csv');
        touch = csvread(touch_file);
        touch_time = touch(:, 1);
        actions = touch(:, 6);
        
        %collect touch features
        [meanTouchDuration, stdTouchDuration] = ...
            getMeanTouchDuration(actions, touch_time, windows);
        
        %Get gyroscope data
        gyro_rile =  strcat(folder, '/', 'TouchEvent.csv');

        
        addToX = [meanAccel, stdAccel, meanTouchDuration,stdTouchDuration,...
            meanOrientation, ...
            stdOrientation];

        n = size(addToX, 1);
        
        % Add this block of input to X_input
        X_input(row_num:row_num + n - 1, :) = addToX;
        
        % Add this result to y_results the same number of times
        y_results(row_num:row_num + n - 1) = repmat(activity, [n 1]);
        
        row_num = row_num + n;
        
    end
end
%trim zeros from end of data
isZeros = ~any(X_input, 2);
X_input(isZeros, :) = [];
y_results(isZeros, :) = [];

%specify that y_results is categorical
y_results = categorical(y_results);

%save('a_mn,a_std,t_dur_mn,t_dur_std,o_mn,o_std', 'X_input', 'y_results')



