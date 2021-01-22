function Location_ROI(sbj)
% Decoding of object location across categories in each background
% condition separately and in each ROI.
% Requirements: SPM and libsvm toolboxes have to be in the path

% Duration: ~ 3 seconds

% Input:
%       sbj = subject number, integer

tic

% prepare paths & filenames
addpath('./HelperFunctions')
savepath = ['../Results/fMRI/ROI/s' sprintf('%.2d',sbj)];
filename = 'Location_ROI';
ROIs     = {'V1' 'V2' 'V3' 'V4' 'LO'};
if ~isdir(savepath); mkdir(savepath); end

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_48x3.mat');

% define decoding parameters
runs       = 10; % number of fMRI runs
bg         = 3;  % number of background conditions
locations  = 4;
categories = 4;
result     = nan(length(ROIs),bg); % preallocate results matrix

% loop through ROI's
for iROI = 1:length(ROIs)
    
    % load data
    load(sprintf(['../Data/fMRI/ROI/s%.2d/s%.2d_' ROIs{iROI} '.mat'],sbj,sbj));
    
    % randomize and average in bins of 2 to decode on 5 pseudo-runs
    data = data(randperm(size(data,1)),:,:,:,:); % randomize runs
    data = reshape(data,[2 (runs/2) bg locations categories size(data,5)]);
    data = squeeze(nanmean(data,1)); % average trials in bins to get new pseudo-trials
    
    % loop through backgrounds
    for iBG = 1:bg
        
        % extract this iteration's background
        data_bg = squeeze(data(:,iBG,:,:,:));
        
        % set the labels for SVM
        labels_train   = [ones(1,(size(data_bg,1))-1) 2*ones(1,(size(data_bg,1))-1)]; % labels for training
        labels_test    = [1 2]; % labels for the left out run
        
        % preallocate
        RDM = nan(size(data_bg,1),locations,locations,categories,categories);
        
        for iRun = 1:size(data_bg,1)
            
            % leave-on-run-out cross-validation
            iTrainRun = find([1:size(data_bg,1)]~=iRun);  % index to runs for training (all except one)
            iTestRun  = iRun;                          % index to run for testing (the one left out)
            
            for LocationA = 1:locations 
                for LocationB = 1:locations
                    
                    for CatA = 1:categories
                        for CatB = 1:categories
                            
                            data_train = [squeeze(data_bg(iTrainRun,LocationA,CatA,:));...
                                          squeeze(data_bg(iTrainRun,LocationB,CatA,:))];
                            
                            data_test  = [squeeze(data_bg(iTestRun,LocationA,CatB,:))';...
                                          squeeze(data_bg(iTestRun,LocationB,CatB,:))'];
                            
                            model = libsvmtrain(labels_train',data_train,'-s 0 -t 0 -q');
                            
                            [predicted_label, accuracy, decision_values] = libsvmpredict(labels_test', data_test, model);
                            
                            RDM(iRun,LocationA,LocationB,CatA,CatB) = accuracy(1); % save accuracy
                            
                        end
                    end
                end
            end
            
        end
        
        % average across runs
        RDM  = squeeze(nanmean(RDM,1)); % cat x cat x loc x loc
        
        % put location in the back
        RDM = permute(RDM,[3 4 1 2]); % loc x loc x cat x cat
        
        % average across upper diagonal, which is location decoding
        RDM = squeeze(nanmean(RDM(:,:,triu(ones(4,4),1)>0),3)); % cat x cat
        
        % extract and average upper and lower diagonal, which is training and testing in across categories (hence upper and lower diagonal)
        % also subtract 50 = chance level
        result(iROI,iBG) = mean(RDM(eye(4,4)==0))-50;
        
        clear RDM data_bg
        
    end
    clear data
end

% save
save([savepath '_' filename  '.mat'],'result');

toc




