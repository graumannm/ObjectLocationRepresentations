function Location_DNN(permutations,ilayer)
% Analysis corresponding to Fig. 3d.
% Classification of object location across categories in each background
% condition separately and in one layer of CORnet-S.

% Duration with 5 permutations: IT: between 5 (V1) and 10 (IT) minutes

% Input:
%       permutations: how many permutations, integer
%       ilayer: which layer, integer. 1=V1,2=V2,3=V4,4=IT

% prepare paths & filenames
tic
addpath('Code/HelperFunctions');
addpath('Code/LibsvmFunctions'); % libsvm 3.1.1.
name     = 'CORnet-S';
savepath = ['./Results/' name filesep];
if ~isdir(savepath); mkdir(savepath); end
layers   = {'V1' 'V2' 'V4' 'IT'};
filename = layers{ilayer};

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_48x3.mat');

% load sorted DNN activations. N.B.: this is already averaged across exemplars to save
% memory. Dimensions: 20 trials x 48 conditions x n units
load(['./Data/' name filesep layers{ilayer} '.mat']);
data = layer; clear layer

% define classification parameters
chance_level = 50;
timewindow   = 1; % use 1 fake 'timepoint' to use the EEG classification function
locations    = 4;
categories   = 4;
bg           = 3;
bins         = 4;
binsize      = round(size(data,1)/bins);
train_col    = 1:bins-1;
test_col     = bins;
labels_train = vertcat(ones(length(train_col),1),2*ones(length(train_col),1) );
labels_test  = vertcat(ones(length(test_col),1),2*ones(length(test_col),1));

% preallocate results matrix
RDM = single(nan(permutations,bg,locations,locations,categories,categories));

% loop through permutations
for iperm = 1:permutations
    
    % before each permutation, bin the data with random assignment of trials to bins
    perm_data   = data(randperm(size(data,1)),:,:); % randomize trial order
    binned_data = reshape(perm_data, [binsize bins size(perm_data,2) size(perm_data,3)] ); clear perm_data
    binned_data = double(squeeze(nanmean(binned_data,1))); % average trials in bins to get new pseudo-trials
    
    % now perform pairwise cross-decoding of all location pairs, across all
    % combinations of categories and within each background condition
    
    for iBG = 1:bg
        
        for locationA = 1:locations
            for locationB = 1:locations
                
                for catA = 1:categories
                    for catB = 1:categories
                        
                        % find condition's index
                        trainA = find(DM.values(:,1)== catA & DM.values(:,2)==locationA & DM.values(:,3)==iBG-1);
                        trainB = find(DM.values(:,1)== catA & DM.values(:,2)==locationB & DM.values(:,3)==iBG-1);
                        
                        testA  = find(DM.values(:,1)== catB & DM.values(:,2)==locationA & DM.values(:,3)==iBG-1);
                        testB  = find(DM.values(:,1)== catB & DM.values(:,2)==locationB & DM.values(:,3)==iBG-1);
                        
                        % extract data
                        traindataA = squeeze(binned_data(:,trainA,:));
                        traindataB = squeeze(binned_data(:,trainB,:));
                        
                        testdataA = squeeze(binned_data(:,testA,:));
                        testdataB = squeeze(binned_data(:,testB,:));
                        
                        % decode location across category
                        [RDM(iperm,iBG,locationA,locationB,catA,catB)] = ...
                         traintest(traindataA,traindataB,testdataA,testdataB,timewindow,labels_train,labels_test,train_col);
                        
                    end
                end
            end
        end
    end
end

% average across permutations
RDM = squeeze(nanmean(RDM,1));

% put location in the back and average across it
RDM = permute(RDM,[4 5 1 2 3 ]);
RDM = nanmean(RDM(:,:,:,triu(ones(4,4),1)>0),4);

% put across categories in the back again
RDM = permute(RDM,[3 1 2]);

% extract and average upper and lower diagonal, which is training and testing
% across categories (in both directions, hence upper and lower diagonal).
% Also subtract chance
result = squeeze(nanmean(RDM(:,eye(4,4)==0),2))-chance_level; clear RDM

duration = toc;

% save
save([savepath filename '.mat'],'result','duration','-v7.3'); clear result duration


