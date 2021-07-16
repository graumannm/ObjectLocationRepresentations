% run single subject demo analysis

clear
clc
addpath(genpath('Code'));
addpath(genpath('Data'));
spm_path = '/scratch/monikag/Toolboxes/spm8'; % insert you path to the SPM toolbox here. Only needed for searchlight

%% set parameters for EEG time-resolved and time-generalization analysis
steps        = 10; % downsample EEG data to 10 ms for speed. Set steps=1 for full 1 ms temporal resolution.
permutations = 5; % 5 permutations for speed. This gives a close approximation to the result with full 100 permutations (used in paper).

%% set parameters for ROI analysis
subs  = 25;
nROIs = 9;
BG    = 3;
ROIs  = nan(subs,nROIs*BG);

%% Durations

% Durations time-resolved analyses (example subject):
% 5 permutations downsampled to 10 ms resolution takes ~37 seconds (fast parameters).
% 100 permutations with 1 ms resulution takes ~2 hours (original parameters).

% Durations time-generalization (example subject):
% 5 permutations downsampled to 10 ms resolution takes ~4 minutes (fast parameters).
% 100 permutations downsampled to 10 ms takes ~85 minutes (original parameters).

% Duration ROI analysis (all subjects):
% ~ 2 minutes

%% prompt user input

disp('This is a quick demo of the analyses for a representative single subject for speed (EEG) or the entire dataset (ROI).')
disp('Please bear in mind that single subject data can be noisier than the group averaged result.')
disp('The result can vary slightly from time to time due to random assignment of trials to bins and training and testing set.')

task = input(' \n Would you like to see results for location (1) or category classification (2)?');

if task~=1 & task~=2
    error('Please press 1 for location or 2 for category.')
end

analysis=input('Which analysis would you like to run?\n Press \n 1 for ROI \n 2 for timecourse \n 3 for time-generalization \n');

% pick example subject
if analysis == 2 || analysis == 3 % EEG
    sbj = 25;
end

%% run selected analysis
if task ==1 % location analyses
    
    if analysis==1 % ROI
        
        % run analysis
        for isub = 1:subs
            result       = Location_ROI(isub);
            result       = result';
            ROIs(isub,:) = result(:); clear result
        end
        
        % test for significance above chance and plot
        alpha = 0.05;
        for itest = 1:size(ROIs,2)
            
            [p_rois(itest), h(itest)] = signrank(ROIs(:,itest));
        end
        [mask, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(p_rois,alpha,'pdep');
        plot_ROI(ROIs,task,mask);
        
    elseif analysis==2 % timecourse
        Location_Time_Resolved(steps,permutations,sbj);
        plot_timecourse(sbj,task);
        
    elseif analysis==3 % time-generalization
        Location_Time_Generalization(steps,permutations,sbj);
        plot_time_generalization(sbj,task);
    else
        error('Please press 1=ROI,2=timecourse or 3=time-generalization.')
    end
    
else % category analyses
    
    if analysis==1 % ROI
        
        % run analysis
        for isub = 1:subs
            result       =  Category_ROI(isub);
            result       = result';
            ROIs(isub,:) = result(:); clear result
        end
        
        % test for significance above chance and plot
        alpha = 0.05;
        for itest = 1:size(ROIs,2)
            
            [p_rois(itest), h(itest)] = signrank(ROIs(:,itest));
        end
        [mask, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(p_rois,alpha,'pdep');
        plot_ROI(ROIs,task,mask);
        
    elseif analysis==2 % timecourse
        Category_Time_Resolved(steps,permutations,sbj);
        plot_timecourse(sbj,task);
        
    elseif analysis==3 % time-generalization
        Category_Time_Generalization(steps,permutations,sbj);
        plot_time_generalization(sbj,task);
    else
        error('Please press 1=ROI,2=timecourse or 3=time-generalization.')
    end
    
end

%% Optional: Searchlight analysis (~16 hours, 2 GB memory)
% You also have the option to run the searchlight classification analysis
% of object location across categories. This analysis takes ~16 hours per
% background condition.

% to run this analysis uncomment the following 3 lines:

% addpath(genpath(spm_path));
% iBG     = 1; % 1= no, 2= low, 3= high clutter
% subject = 1;
% Location_Searchlight(subject,iBG);

% to plot the (existing) result uncomment and run this line:

% plot_searchlight(1,iBG);

%% Optional: DNN analysis (~40 minutes with 5 permutations)
% You also have the option to run the DNN classification analysis
% of object location across categories. This analysis takes ~10 minutes per layer with 5 permutations.

% to run this analysis uncomment the following lines:

% permutations = 5;
% for ilayer = 1:4 % 1=V1,2=V2,3=V4,4=IT
%     Location_DNN(permutations,ilayer);
% end
% plot_DNN;
