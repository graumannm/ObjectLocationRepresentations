function [RDM] = location_timecourse_2ndhalf(data,timewindow,permutations)
% use for subjects 17:29

% subsample those timepoints from data (if steps>1, otherwise will take all)
data = data(:,:,:,timewindow);

% define decoding parameters
bins       = 4; % how many pseudo-trials to train & test on
binsize    = round(size(data,2)/bins); % how many trials go into one bin=pseudotrial
locations  = 4;
categories = 4;
bg         = 3; % background conditions
train_col    = 1:bins-1; % columns to index training trials
test_col     = bins; % columns to index testing trials
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) ); % label vectors for libsvm
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));    % label vectors for libsvm

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_48x3.mat');

% preallocate results RDM of dimensions: 
% permutations x 3 backgrounds x 4 locations x 4 locations x 4 categories x 4 categories x time
RDM      = single(nan(permutations,bg,locations,locations,categories,categories,length(timewindow)));

% start decoding loop 
for iperm = 1:permutations
    
    fprintf('Permutation #%d out of %d \n',iperm,permutations)
    
    % before each permutation, bin the data with random assignment of trials to bins
    perm_data   = data(:,randperm(size(data,2)),:,:); % randomize trial order
    binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
    binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
    
    % multivariate noise normalization and whitening
    [white_data] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    
    % now perform pairwise cross-decoding of all location pairs, across all
    % combinations of categories and within each background condition
    
    for iBG = 1:bg
            
            for locationA = 1:locations
                for locationB = 1:locations
                    
                    for catA = 1:categories
                        for catB = 1:categories
                            
                            trainA = find(DM.values(:,1)==catA & DM.values(:,2)==locationA & DM.values(:,3)==iBG-1);
                            trainB = find(DM.values(:,1)==catA & DM.values(:,2)==locationB & DM.values(:,3)==iBG-1);
                            
                            testA  = find(DM.values(:,1)==catB & DM.values(:,2)==locationA & DM.values(:,3)==iBG-1);
                            testB  = find(DM.values(:,1)==catB & DM.values(:,2)==locationB & DM.values(:,3)==iBG-1);
                            
                            traindataA = squeeze(white_data(trainA,:,:,:));
                            traindataB = squeeze(white_data(trainB,:,:,:));
                            
                            testdataA = squeeze(white_data(testA,:,:,:));
                            testdataB = squeeze(white_data(testB,:,:,:));
                            
                            % for current location pair, cross-decode at all timepoints
                            [RDM(iperm,iBG,locationA,locationB,catA,catB,:)] = ...
                             traintest(traindataA,traindataB,testdataA,testdataB,timewindow,labels_train,labels_test,train_col);
                        end
                    end
                end
            end
    end
end

% average RDM across permutations
RDM      = squeeze(nanmean(RDM,1));