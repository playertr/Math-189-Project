%% Extract data for each user and store in cell array
%first, load user_ident_preprocessed
%which contains X_input and y_results
users = unique(y_train);
data_by_user = {};
for  i = 1:length(users)
    u = users(i)
    user_data = X_train(y_train == u, :);
    userID = y_train(y_train == u);
    thisUsersSessions = session(y_train == u);
    
    data_by_user{i} = {user_data, userID, thisUsersSessions};
end

%save as data_by_user

%% Divide data by users into test and train sets
%first, load data_by_user

%for each user, put 80% of their sessions in test and 20%
%of their sessions in train.
test_X = [];
test_y = [];

train_X = [];
train_y = [];

for i = 1:size(data_by_user, 1)
    %Get this users data
    %{user_data, userID, thisUsersSessions}
    thisUsersData       = data_by_user{i}{1};
    thisUsersID         = data_by_user{i}{2};
    thisUsersSessions   = data_by_user{i}{3};
    
    uniqueSessions      = unique(thisUsersSessions);
    testTrainIndex      = floor(0.8 * size(uniqueSessions, 1));
    trainSessions       = thisUsersSessions(1:testTrainIndex);
    testSessions        = thisUsersSessions(testTrainIndex + 1:end);
    
    rowsInTrain         = ismember(thisUsersSessions, trainSessions);
    rowsInTest          = ismember(thisUsersSessions, testSessions);
    
    train_X = [train_X; thisUsersData(rowsInTrain, :)];
    train_y = [train_y; thisUsersID(rowsInTrain, :)];
    
    test_X  = [test_X; thisUsersData(rowsInTest, :)];
    test_y  = [test_y; thisUsersID(rowsInTest, :)];
    
end

usersInTrainingSet = unique(train_y);

%save as test_and_train_by_user
%save('test_and_train_by_user_v3', 'train_X', 'train_y', ...
%   'test_X', 'test_y', 'usersInTrainingSet');

%% Fit data
% First, load test_and_train_by_user,
% which includes test_X, test_y, train_X, train_y, and usersInTrainingSet
rng(1);
type1 = [];
type2 = [];
num_training_users = size(usersInTrainingSet, 1);

%create array of never-before-seen user data by concatenating 
%input matrices from testing_data

for j = 1:num_testing_users
    other_user_test_data = [other_user_test_data ;testing_data{j}{1}];
end

for i = 1:num_training_users
    
    this_users_data = training_data{i}{1};
    n = size(this_users_data, 1);
    
    
    %Build training data set for this user
    this_users_train_data = this_users_data(1:floor(0.8 * n), :);
    
    other_user_train_data = [];
    rowNum = 1;
    for j = 1:num_training_users
        if j ~= i
            other_user_train_data = [other_user_train_data;...
                training_data{j}{1}];
            rowNum = rowNum + 1;
        end
    end
    
    train_data_X = [this_users_train_data; other_user_train_data];
    train_data_y = [ ones(size(this_users_train_data, 1), 1); ...
        zeros(size(other_user_train_data,1), 1)];
    train_data_y = categorical(train_data_y);
    
    %Build testing data set for this user
    this_users_test_data = this_users_data(floor(0.8 * n):end, :);
    test_data_X = [this_users_test_data; other_user_test_data];
    test_data_y = [ ones(size(this_users_test_data, 1), 1); ...
        zeros(size(other_user_test_data,1), 1)];
    test_data_y = categorical(test_data_y);

    %Fit data
    %{
    mdl = fitcknn(train_data_X, train_data_y,...
        'NumNeighbors',1, ...
        'Distance', 'seuclidean', ...
        'Standardize', 1 );
    %}
    
    %{ 
    %PCA
    [coeff, score, latent] = pca(train_data_X); %do PCA
    PCAdim = 6;
    numRows = 30000;
    
    train_data_X = score(1:numRows, 1:PCAdim);
    test_data_X = test_data_X * coeff;
    test_data_X = test_data_X(1:numRows, 1:PCAdim);
    
    mdl = fitcsvm(train_data_X_pca(1:numRows, 1:PCAdim), train_data_y(1:numRows, :) ...
        );
    
    %Assess fit
    test_data_X_pca = test_data_X * coeff;
    [label, score] = predict(mdl, test_data_X_pca(:, 1:PCAdim));
    %}
    
    %{
    %knn
    mdl = fitcknn(train_data_X, train_data_y,...
        'Distance', 'mahalanobis',...
        'NumNeighbors', 1,...
        'Standardize', 1);
    %}
    
    mdl = fitcmnr(train_data_X, train_data_y);
    %knn: 0.0037 type 1, 0.4247 type 2
    %knn, seuclidean, 1 neighbor, standarized: 0.2062 type2
    %knn, mahalanobis, 1 neighbor, standardized: 0.1505 type2
    %discr: 0 type 1, 0.9711 type 2
    %tree: 0 type 1, 0.3320 type 2
    
    
    
    [label, score] = predict(mdl, test_data_X);
    pred_label = label;
    %{
    minscore = 0;
    for k = 1:size(label, 1)
        if score(k, 2) > minscore
            pred_label(k) = categorical(1);
        end
    end
    %}
    
    total_success = sum( pred_label == test_data_y);
    
    numTests = size(test_data_X, 1);
    numisActuallyUser = sum(test_data_y == categorical(1));
    numisActuallyNotUser = sum(test_data_y == categorical(0));
    
    type1_error = sum(pred_label ~= test_data_y &...
        categorical(0) == test_data_y) / numisActuallyNotUser
    
    type2_error = sum(pred_label ~= test_data_y & ...
        categorical(1) == test_data_y) / numisActuallyUser
    
    success_rate = total_success / numTests
    
    type1(i) = type1_error;
    type2(i) = type2_error;
    
        
    disp("paused")
    
    pause
    
end