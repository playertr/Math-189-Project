
%% Multinomial (softmax) Regression
%clear all, close all, clc
%load('accel-y_data.mat')

%Compute fit

%normalize X
X_norm = normalize(X_input);
%X_norm becomes the columnwise z-score of X_input


%randomly shuffle rows of X
shufflingOrder = randperm(size(X_norm,1));
shuffledX = X_norm(shufflingOrder,:);
shuffledy = y_results(shufflingOrder);


m = size(shuffledX, 1);

%select training data
X_train = shuffledX(1:floor(m * 0.8),:);
y_train = shuffledy(1:floor(m * 0.8));

%the remainder is testing data
X_test = shuffledX(floor(m * 0.8) + 1: end, :);
y_test = shuffledy(floor(m * 0.8) + 1: end);

clear shuffledX;

%% Multinomial Regression
[B,dev,stats] = mnrfit(X_train, y_train);

predictions = mnrval(B, X_test); %an mx3 array of probabilities
[probs, predCat] = max(predictions, [], 2); 
%the maximum probability and index (category) for each prediction

y_test_d = double(y_test); % test set y categories as numbers
total_success = sum( predCat == y_test_d );

success_rate = total_success / size(y_test, 1) %58 percent

%% Gaussian Discriminant Analysis
rng(1)
Mdl = fitcdiscr(X_train,y_train, 'ScoreTransform','logit',...
    'OptimizeHyperparameters', 'auto');...
    %'Optimize'); %not done
total_success = sum( label == y_test );
success_rate = total_success / size(y_test, 1) %62 percent


%% Ploting data
map_data = X_norm(y_results == 'Map', :);
reading_data = X_norm(y_results == 'Reading', :);
writing_data = X_norm(y_results == 'Writing', :);




figure()
hold on;
% plot std(Ax, Ay, Az)
plot3(map_data(:,4), map_data(:,5), map_data(:,6), 'go')
plot3(reading_data(:,4), reading_data(:,5), reading_data(:,6), 'bo')
plot3(writing_data(:,4), writing_data(:,5), writing_data(:,6), 'ro')
title('std(Ax, Ay, Az)');
xlabel('Std Ax')
ylabel('Std Ay')
zlabel('Std Az')

figure()
hold on;
% plot mean(Ax, Ay, Az)
plot3(map_data(:,1), map_data(:,2), map_data(:,3), 'go')
plot3(reading_data(:,1), reading_data(:,2), reading_data(:,3), 'bo')
plot3(writing_data(:,1), writing_data(:,2), writing_data(:,3), 'ro')
title('mean(Ax, Ay, Az)')
xlabel('Mean Ax')
ylabel('Mean Ay')
zlabel('Mean Az')

figure()
hold on;
% plot mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration
m_map = mean(map_data(:, 3:6),2);
m_reading = mean(reading_data(:, 3:6),2);
m_writing = mean(writing_data(:, 3:6),2);

plot(m_map, map_data(:,7), 'go');
plot(m_reading, reading_data(:,7), 'bo');
plot(m_writing, writing_data(:,7), 'ro');
title('Mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration');
xlabel('Mean(stdDev(Ax,Ay,Az)')
ylabel('meanTouchDuration')

%%
figure()
hold on;
% plot mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration vs. stdOrientation
m_map = mean(map_data(:, 3:6),2);
m_reading = mean(reading_data(:, 3:6),2);
m_writing = mean(writing_data(:, 3:6),2);

plot3(m_map, map_data(:,7), map_data(:,10), 'go');
plot3(m_reading, reading_data(:,7), reading_data(:,10), 'bo');
plot3(m_writing, writing_data(:,7), writing_data(:,10),'ro');
title('Mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration vs. meanOrienation');
xlabel('Mean(stdDev(Ax,Ay,Az)')
ylabel('meanTouchDuration')
zlabel('stdOrientation')


figure()
hold on;

% plot mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration vs. stdTouchDuration
m_map = mean(map_data(:, 3:6),2);
m_reading = mean(reading_data(:, 3:6),2);
m_writing = mean(writing_data(:, 3:6),2);

plot3(m_map, map_data(:,7), map_data(:,8), 'go');
plot3(m_reading, reading_data(:,7), reading_data(:,8), 'bo');
plot3(m_writing, writing_data(:,7), writing_data(:,8),'ro');
title('Mean(stdDev(Ax,Ay,Az)) vs. meanTouchDuration vs. stdTouchDuration');
xlabel('Mean(stdDev(Ax,Ay,Az)')
ylabel('meanTouchDuration')
zlabel('stdTouchDuration')



