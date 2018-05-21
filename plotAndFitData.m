
%% Produce Training Set 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% DO NOT RUN--WE HAVE FINALIZED OUR TEST AND TRAIN SET %%%%%%%%%%%
%%%%%%%%%%%%%%% It is in final_test_and_train.mat %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%normalize X
%X_norm = normalize(X_input); %center data and divide by std. dev
%X_norm = X_input - mean(X_input); %only center data
X_norm = X_input; %use raw input

%randomly shuffle rows of X
rng 'default';
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
%save('22featuresTestAndTrain', 'X_train', 'y_train', 'X_test', 'y_test')
%% PCA

[coeff, score, latent] = pca(X_train); %do PCA

%% Multinomial Regression
[B,dev,stats] = mnrfit(X_train, y_train);

predictions = mnrval(B, X_test); %an mx3 array of probabilities
[probs, predCat] = max(predictions, [], 2); 
%the maximum probability and index (category) for each prediction

y_test_d = double(y_test); % test set y categories as numbers
total_success = sum( predCat == y_test_d );

success_rate = total_success / size(y_test, 1) 
%58 percent
%59.3 percent with final data


%% Gaussian Discriminant Analysis
rng 'default'
Mdl = fitcdiscr(X_train,y_train, 'ScoreTransform','logit',...
    'OptimizeHyperparameters', 'auto',...
    'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName','expected-improvement-plus')); 

pred_label = predict(Mdl, X_test);
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1) 
%62 percent without the gyro and mag features and with std. dev norm
% 62.2 percent with gyro and mag features and with std. dev norm
%64.4 percent with the gyro and mag features but without std. dev norm
%67.3 percent without centering or std. dev norm

%% GDA with PCA
rng 'default'
PCAdim = 6;
Mdl = fitcdiscr(score(:, 1:PCAdim),y_train, 'ScoreTransform','logit',...
    'OptimizeHyperparameters', 'auto',...
    'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName','expected-improvement-plus')); 

pred_label = predict(Mdl, X_test*coeff(:,1:PCAdim));
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1) 
% 61.7 percent with 22 features, unit norm, 6 dimensional PCA reduction

%% KNN classifier
mdl = fitcknn(X_train, y_train, 'OptimizeHyperparameters','auto');

pred_label = predict(mdl, X_test);
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1)

%84.23 percent with 22 features, raw input, no optimize hyperparameters
%91.15 percent with 22 featuers, raw input, optimized hyperparameters
%85.69 percent with final test and train, raw input, optimized
%% Multiclass support vector machine model
mdl = fitcecoc(X_train,y_train);


pred_label = predict(mdl, X_test);
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1)
% 62.5 percent with 22 features, raw input

%% Classification tree
mdl = fitctree(X_train,y_train, 'OptimizeHyperparameters','auto');


pred_label = predict(mdl, X_test);
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1)

%85.19 percent with 22 features, raw input, no hyperparameter opt
%85.19 percent with 22 features, raw input, hyperparameters auto
%79.03 percent with final dataset, raw input, hyperparameters auto

%% Naive Bayes
mdl = fitcnb(X_train,y_train);


pred_label = predict(mdl, X_test);
total_success = sum( pred_label == y_test );
success_rate = total_success / size(y_test, 1)

%60.00 percent with 22 features, raw input, no hyperparameter opt

%% Plotting data
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



