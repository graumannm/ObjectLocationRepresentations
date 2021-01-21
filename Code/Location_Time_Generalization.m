function Location_Time_Generalization(steps,permutations,sbj)
% Time-generalization analysis of object location across categories, background and time.
% Additionally to cross-decoding across categories, we train on
% all timepoints in the no clutter and test on all timepoints in the high
% clutter condition.
% Saves single subject's time-time RDM.
% Requirement: libsvm toolbox has to be in the path.

% Duration:
% 5 permutations downsampled to 10 ms resolution takes ~4 minutes
% 100 permutations take downsampled to 10 ms take ~85 minutes

% Input:
%       steps: time steps to analyze, integer. 1= 1 ms resolution. Use steps=10 to
%       downsample to 10 ms resolution to make script run faster
%       permutations: how many permutations, integer
%       sbj: subject's number, integer

tic
addpath('./HelperFunctions')
savepath = '../Results/EEG/';
filename = 'Location_TimeGeneralization';

% load data
load(sprintf('../Data/EEG/s%.2d_EEG.mat',sbj));

% define which time points to analyze
time_end   = find(timepoints==600); % like in paper, we analyze up until 600 ms post-stimulus to save time and memory
timewindow = 1:steps:time_end;

% then subsample those timepoints from data (if steps>1, otherwise will take all)
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
% permutations x 3 backgrounds x 4 locations x 4 locations x 4 categories x 4 categories x time
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
                for catB = 1:categories % we need all for diagonal
                    
                    trainA = find(DM.values(:,1)== catA & DM.values(:,2)==locationA & DM.values(:,3)==no_clutter);
                    trainB = find(DM.values(:,1)== catA & DM.values(:,2)==locationB & DM.values(:,3)==no_clutter);
                    
                    testA  = find(DM.values(:,1)== catB & DM.values(:,2)==locationA & DM.values(:,3)==high_clutter);
                    testB  = find(DM.values(:,1)== catB & DM.values(:,2)==locationB & DM.values(:,3)==high_clutter);
                    
                    
                    for timeA = 1:length(timewindow)
                        
                        traindataA = squeeze(white_data(trainA,train_col,:,timeA));
                        traindataB = squeeze(white_data(trainB,train_col,:,timeA));
                        
                        testdataA = squeeze(white_data(testA,:,:,:));
                        testdataB = squeeze(white_data(testB,:,:,:));
                        
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

duration = toc;

% save result
save([savepath 's' sprintf('%.2d',sbj) '_' filename '.mat' ],'RDM','timepoints','timewindow','duration','-v7.3');
