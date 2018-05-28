clear all, close all, clc

% Define source file
file = '/Users/kevinjcotton/Downloads/public_dataset';
% number of samples
samples = 1;

% Data parameters

% Define source file
%file = '/Users/kevinjcotton/Downloads/public_dataset'; %Kevin
file = './HMOG_public_dataset/unzipped'; % Tim

% folders contains all the sessions for every user
folders = strsplit(ls(strcat(file,'/*')));

num_folders = size(folders,2);

% Randomly Sample
for i = 1:samples
    %select random folder
    x = max(round(rand*num_folders),1);
    random_folder = folders(x);
    random_folder = random_folder{1};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Acceleration Features %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    random_folder_full = strcat(file,'/*/',random_folder,'/Accelerometer.csv');
    
    
    % resolve wildcard in path
    random_csv = strsplit(ls(random_folder_full));
    random_csv = random_csv{1};
    A = csvread(random_csv);
    
    X = A(:,4);
    Y = A(:,5);
    Z = A(:,6);
    
    % Calculate data features
    

end



