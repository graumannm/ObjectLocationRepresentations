function RDM = location_timetime_2ndhalf(data,timewindow,permutations)
% use for subjects 17:29

% subsample chosen timepoints from data (if steps>1, otherwise will take all)
data = data(:,:,:,timewindow);

% define decoding parameters
bins         = 4; % how many pseudo-trials to train & test on
binsize      = round(size(data,2)/bins); % how many trials go into one bin=pseudotrial
locations    = 4;
categories   = 4;
no_clutter   = 0; % value in design matrix column
high_clutter = 2; % value in design matrix column
train_col    = 1:bins-1; % columns to index training trials
test_col     = bins; % columns to index testing trials
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) ); % label vectors for libsvm
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));    % label vectors for libsvm

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_48x3.mat');

% preallocate results RDM of dimensions:
% permutations x 4 locations x 4 locations x 4 categories x 4 categories x time x time
RDM = single(nan(permutations,locations,locations,categories,categories,length(timewindow),length(timewindow)));

% start decoding loop
for iperm = 1:permutations
    
    fprintf('Permutation #%d out of %d \n',iperm,permutations)
    
    % before each permutation, bin the data with random assignment of trials to bins
    perm_data   = data(:,randperm(size(data,2)),:,:); % randomize trial order
    binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
    binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
    
    % multivariate noise normalization and whitening
    [white_data] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    
    % now perform pairwise cross-decoding of all location pairs, across
    %  categories, backgrounds and time points
    for locationA = 1:locations
        for locationB = 1:locations
            
            for catA = 1:categories
                for catB = 1:categories % we need all for both off-diagonals
                    
                    % find condition for indexing
                    trainA = find(DM.values(:,1)== catA & DM.values(:,2)==locationA & DM.values(:,3)==no_clutter);
                    trainB = find(DM.values(:,1)== catA & DM.values(:,2)==locationB & DM.values(:,3)==no_clutter);
                    
                    testA  = find(DM.values(:,1)== catB & DM.values(:,2)==locationA & DM.values(:,3)==high_clutter);
                    testB  = find(DM.values(:,1)== catB & DM.values(:,2)==locationB & DM.values(:,3)==high_clutter);
                    
                    
                    for timeA = 1:length(timewindow)
                        
                        % extract data
                        traindataA = squeeze(white_data(trainA,train_col,:,timeA));
                        traindataB = squeeze(white_data(trainB,train_col,:,timeA));
                        
                        testdataA = squeeze(white_data(testA,:,:,:));
                        testdataB = squeeze(white_data(testB,:,:,:));
                        
                        % decode
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