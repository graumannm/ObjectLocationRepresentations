function Location_Searchlight(sbj,BG)
% Whole brain searchlight classsification of object location across categories in each background
% condition separately.
% Requirement: SPM has to be in the path.

% Duration: ~ 16 hours on high-performance computing cluster
% Memory: ~2 GB

% Input:
%       sbj = subject number, integer
%       BG = background, integer. 1=no, 2=low, 3= high clutter.

tic

% prepare paths & filenames
addpath('Code/HelperFunctions');
addpath('Code/LibsvmFunctions'); % libsvm 3.1.1.
savepath              = ['./Results/fMRI/Searchlight/s' sprintf('%.2d',sbj) '/'];
if ~isdir(savepath); mkdir(savepath); end
background_conditions = {'No','Low','High'};
filename              = ['s' sprintf('%.2d',sbj) '_Location_SL_' background_conditions{BG} '_Clutter'];

% load design matrix for indexing of conditions in decoding loop
load('DesignMatrix_48x3.mat');

%% load volume
% Dimensions: 10 runs x 3 backgrounds x 4 locations x 4
% categories x voxels
load(sprintf(['./Data/fMRI/Volume/s%.2d/s%.2d_Volume.mat'],sbj,sbj))

% randomize runs before averaging
runs = 10;
bins = 2;
data = data(randperm(10),:,:,:,:);
% average 2 runs
data = reshape(data,[bins (runs/bins) 3 4 4 size(data,5)]);
data = squeeze(nanmean(data,1));

%% define parameters

% searchlight parameters
searchlight_radius      =  4;
sz_volume               = size(mask_img);           % size of the results volume (mask is nan==no brain,0==brain)
% this line creates MX MY MZ = ndgrid(1:x,1:y,1:z) matrices of the size XxYxZ. MX is counting down
% from 1:x along the 1st dimension, MY is counting down from 1:y along the
% 2nd dimension and MZ is counting down 1:z along the 3rd dimension.
[MX,MY,MZ]              = ndgrid(1:sz_volume(1),1:sz_volume(2),1:sz_volume(3)); % for later calculating searchlight radius
idx_volume              = zeros(sz_volume);        % preallocate, volume of 0s of size of mask_img
idx_volume(brain_index) = 1:length(brain_index);   % values inside brain are indices,1:nvoxels
nvox                    = length(brain_index);     % number of voxels

% classification parameters
labels_train = [ones(1,(size(data,1))-1) 2*ones(1,(size(data,1))-1)]; %labels for training
labels_test  = [1 2]; % labels for the left our run
locations    = 4;
categories   = 4;
chance_level = 50;

% preallocate final results volume
results_img_RDM = nan(sz_volume(1),sz_volume(2),sz_volume(3),locations,locations,categories,categories); 

%% start searchlight loop

for iVox = 1:nvox % go thorugh all voxels
    
    if mod(iVox,1000)==0 % every 1000 voxels, print progress report
        disp([num2str(iVox) 'voxel out of ' num2str(nvox) 'voxel' ])
    end
    
    % define current position of searchlight
    [xc,yc,zc]    = ind2sub(sz_volume,brain_index(iVox));                    % find x,y,z coordinates of iVox voxel
    radiuses      = zeros(sz_volume);                                        % volume of zeros where radius distances to center voxels are saved
    radiuses      = sqrt((MX-xc).^2 + (MY-yc).^2 + (MZ-zc).^2);              % distances by euclidean geometry
    lin_index_sub = find((radiuses<searchlight_radius) & ~isnan(mask_img) ); % find voxels < radius away from center voxel
    vox_index    = idx_volume(lin_index_sub);                                % gets the idx_volume indexes for each of these points
    vox_index    = vox_index(find(vox_index>0));
    
    % preallocate results runs volume, will be updated for each voxel
    run_wise_accuracy = nan(size(data,1),locations,locations,categories,categories);
    
    for iRun = 1:size(data,1)
        
        % leave-one-run-out cross-validation
        iTrainRun = find([1:size(data,1)]~=iRun);  % index to runs for training (all except one)
        iTestRun  = iRun;                          % index to run for testing (the one left out)
        
        for LocationA = 1:locations
            for LocationB = 1:locations
                
                for CatA = 1:categories
                    for CatB = 1:categories
                        
                        data_train = [squeeze(data(iTrainRun,BG,LocationA,CatA,vox_index));...
                                      squeeze(data(iTrainRun,BG,LocationB,CatA,vox_index))];
                        
                        data_test  = [squeeze(data(iTestRun,BG,LocationA,CatB,vox_index))';...
                                      squeeze(data(iTestRun,BG,LocationB,CatB,vox_index))'];
                        
                        model = libsvmtrain(labels_train',data_train,'-s 0 -t 0 -q');
                        
                        [predicted_label, accuracy, decision_values] = libsvmpredict(labels_test', data_test, model);
                        
                        run_wise_accuracy(iRun,LocationA,LocationB,CatA,CatB) = accuracy(1); % save up run-wise accuracy
                        
                    end
                end
            end
        end
    end
    
    % average across runs and store in results RDM
    results_img_RDM(xc,yc,zc,:,:,:,:) = squeeze(nanmean(run_wise_accuracy,1)); clear run_wise_accuracy
    
end

% put location in the back
SL = permute(results_img_RDM,[1 2 3 6 7 4 5]);

% average across upper diagonal, which is decoding of location
SL = squeeze(nanmean(SL(:,:,:,:,:,triu(ones(4,4),1)>0),6));

% take off-diagonals for cross-decoding across categories and subtract
% chance
SL = squeeze(nanmean(SL(:,:,:,eye(4,4)==0),4))-chance_level;

%% save

% 1) as mat file
save([savepath '_' filename  '.mat'],'SL','-v7.3');

% 2) as .img file that can be viewed in a viewer like xjview or mricron
results_hdr         = vol_hdr; % use previous header and adapt it
results_hdr.descrip = 'location across category'; 
results_hdr.private =   [];                               
results_hdr.fname   = [savepath filename  '.img']; 
spm_write_vol(results_hdr,SL);

toc