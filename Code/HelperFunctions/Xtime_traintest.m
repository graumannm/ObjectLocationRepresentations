function [time_matrix] = Xtime_traintest(trainA,trainB,testA,testB,timewindow,labels_train,labels_test)
% cross decode between condtions and across time.
% train on timepoint t and test on all other timepoints

% train
 time_matrix  = nan(1,length(timewindow));
 train_data   = [squeeze(trainA); squeeze(trainB)];
 model        = libsvmtrain(labels_train, train_data,'-s 0 -t 0 -q');
 
 % test
 for iTime = 1:length(timewindow) % size of data
     
     test_data = [squeeze(testA(end,:,iTime)) ; squeeze(testB(end,:,iTime)) ];
     [predicted_label, l_accuracy, decision_values] = libsvmpredict(labels_test, test_data, model); clear predicted_label decision_values
     time_matrix(iTime) = [l_accuracy(1)];
     
 end
    
    

