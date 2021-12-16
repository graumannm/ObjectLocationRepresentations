function [RDM] = category_timetime_1sthalf(data,timewindow,permutations)
% use for subjects 1:16

% subsample chosen timepoints from data (if steps>1, otherwise will take all)
data{1} = data{1}(:,:,:,timewindow);
data{2} = data{2}(:,:,:,timewindow);

% define decoding parameters
bins         = 4; % how many pseudo-trials to train & test on
binsize      = round(size(data{1},2)/bins); % how many trials go into one bin=pseudotrial
locations    = 4;
categories   = 4;
no_clutter   = 1; % value in design matrix column
high_clutter = 2; % value in design matrix column
train_col    = 1:bins-1; % columns to index training trials
test_col     = bins; % columns to index testing trials
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) ); % label vectors for libsvm
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));    % label vectors for libsvm

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_32x3.mat');

% preallocate results RDM of dimensions:
% permutations x 4 locations x 4 locations x 4 categories x 4 categories x time x time
RDM = single(nan(permutations,locations,locations,categories,categories,length(timewindow),length(timewindow)));

% start decoding loop
for iperm = 1:permutations
    
    fprintf('Permutation #%d out of %d \n',iperm,permutations)
    
    for iClutter = 1:high_clutter
        
        % bin the data
        perm_data   = data{iClutter}(:,randperm(size(data{iClutter},2)),:,:); % randomize trial order
        binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
        binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
        
        % multivariate noise normalization and whitening
        [white_data{iClutter}] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    end
    clear iClutter
    
    % now perform pairwise cross-decoding of all location pairs, across
    %  categories, backgrounds and time points
    
    for locationA = 1:locations
        for locationB = 1:locations
            
            for catA = 1:categories
                for catB = 1:categories % we need all for both off-diagonals
                    
                    % find condition for indexing
                    trainA = find(DM(:,1)== catA & DM(:,2)==locationA & DM(:,3)==no_clutter-1);
                    trainB = find(DM(:,1)== catB & DM(:,2)==locationA & DM(:,3)==no_clutter-1);
                    
                    testA  = find(DM(:,1)== catA & DM(:,2)==locationB & DM(:,3)==high_clutter-1);
                    testB  = find(DM(:,1)== catB & DM(:,2)==locationB & DM(:,3)==high_clutter-1);
                    
                    
                    for timeA = 1:length(timewindow)
                        
                        traindataA = squeeze(white_data{no_clutter}(trainA,train_col,:,timeA));
                        traindataB = squeeze(white_data{no_clutter}(trainB,train_col,:,timeA));
                        
                        testdataA = squeeze(white_data{high_clutter}(testA,:,:,:));
                        testdataB = squeeze(white_data{high_clutter}(testB,:,:,:));
                        
                        [RDM(iperm,locationA,locationB,catA,catB,timeA,:)] = ...
                        Xtime_traintest(traindataA,traindataB,testdataA,testdataB,timewindow,labels_train,labels_test);
                        
                    end
                    
                end
            end
            
        end
    end
    
end

% average RDM across permutations
RDM = squeeze(nanmean(RDM,1));
