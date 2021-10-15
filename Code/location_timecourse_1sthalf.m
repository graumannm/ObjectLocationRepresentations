function [RDM] = location_timecourse_1sthalf(data,timewindow,permutations)
% use for subjects 1:16

% subsample those timepoints from data (if steps>1, otherwise will take all)
data{1} = data{1}(:,:,:,timewindow);
data{2} = data{2}(:,:,:,timewindow);

% define decoding parameters
bins         = 4; % how many pseudo-trials to train & test on
binsize      = round(size(data{1},2)/bins); % how many trials go into one bin=pseudotrial
locations    = 4;
categories   = 4;
clutter      = 2; % clutter low/high; conditions were 1/2 no, 1/4 low and 1/4 high clutter
bg           = 2; % background yes/no
train_col    = 1:bins-1; % columns to index training trials
test_col     = bins; % columns to index testing trials
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) ); % label vectors for libsvm
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));    % label vectors for libsvm

% load design matrix for 1st half of EEG experiment
load('DesignMatrix_32x3.mat');

% preallocate results RDM of dimensions:
% permutations x 3 backgrounds x 4 locations x 4 locations x 4 categories x 4 categories x time
wholeRDM      = single(nan(permutations,clutter,bg,locations,locations,categories,categories,length(timewindow)));

% start decoding loop
for iperm = 1:permutations
    
    fprintf('Permutation #%d out of %d \n',iperm,permutations)
    
    for iClutter = 1:clutter
        % bin the data
        perm_data   = data{iClutter}(:,randperm(size(data{iClutter},2)),:,:); % randomize trial order
        binned_data = reshape(perm_data, [size(perm_data,1) binsize bins size(perm_data,3) size(perm_data,4)] ); clear perm_data
        binned_data = squeeze(nanmean(binned_data,2)); % average trials in bins to get new pseudo-trials
        
        % multivariate noise normalization and whitening
        [white_data{iClutter}] = mvnn_whitening(binned_data,1:bins-1); clear binned_data
    end
    clear iClutter
    
    % now perform pairwise cross-decoding of all location pairs, across all
    % combinations of categories and within each background condition
    for iClutter = 1:clutter
        for iBG = 1:bg
            
            for locationA = 1:locations
                for locationB = 1:locations
                    
                    for catA = 1:categories
                        for catB = 1:categories
                            
                            trainA = find(DM(:,1)== catA & DM(:,2)==locationA & DM(:,3)==iBG-1);
                            trainB = find(DM(:,1)== catA & DM(:,2)==locationB & DM(:,3)==iBG-1);
                            
                            testA  = find(DM(:,1)== catB & DM(:,2)==locationA & DM(:,3)==iBG-1);
                            testB  = find(DM(:,1)== catB & DM(:,2)==locationB & DM(:,3)==iBG-1);
                            
                            traindataA = squeeze(white_data{iClutter}(trainA,:,:,:));
                            traindataB = squeeze(white_data{iClutter}(trainB,:,:,:));
                            
                            testdataA = squeeze(white_data{iClutter}(testA,:,:,:));
                            testdataB = squeeze(white_data{iClutter}(testB,:,:,:));
                            
                            % for current location pair, cross-decode at all timepoints
                            [wholeRDM(iperm,iClutter,iBG,locationA,locationB,catA,catB,:)] = ...
                                traintest(traindataA,traindataB,testdataA,testdataB,timewindow,labels_train,labels_test,train_col);
                        end
                    end
                end
            end
        end
    end
end

% average RDM across permutations
wholeRDM      = squeeze(nanmean(wholeRDM,1));

% bring into same dimensions as 2nd half of experiment by extracting decoding within no,
% low and high clutter
% RDM
RDM  = single(nan(3,locations,locations,categories,categories,length(timewindow)));% adjusted RDM
RDM(1,:,:,:,:,:) = squeeze(wholeRDM(1,1,:,:,:,:,:)); % use only half of no clutter so number is equal across clutter conditions
RDM(2,:,:,:,:,:) = squeeze(wholeRDM(1,2,:,:,:,:,:)); % clutter low=1; background yes=2
RDM(3,:,:,:,:,:) = squeeze(wholeRDM(2,2,:,:,:,:,:)); % clutter high=2; background yes=2