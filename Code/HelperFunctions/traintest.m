function [time_vec] = traintest(trainA,trainB,testA,testB,timewindow,labels_train,labels_test,train_col)
% cross decode between condtions. Only within time.

time_vec  = nan(1,length(timewindow));

for iTime = 1:length(timewindow) % size of data
    
    % train
    train_data   = [squeeze(trainA(train_col,:,iTime)); squeeze(trainB(train_col,:,iTime))]; % training data already selected in previous function
    model        = libsvmtrain(labels_train, train_data,'-s 0 -t 0 -q');
    
    % test
    test_data = [squeeze(testA(end,:,iTime)) ; squeeze(testB(end,:,iTime)) ];
    [predicted_label, l_accuracy, decision_values] = libsvmpredict(labels_test, test_data, model); 
    time_vec(iTime) = [l_accuracy(1)];
    
end



