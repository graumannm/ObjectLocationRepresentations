% run single subject demo analysis

clear
clc
addpath(genpath('Code'));
addpath(genpath('Data'));
addpath(genpath('Results'));

%% set parameters for EEG time-resolved and time-generalization analysis

steps        = 10; % downsample EEG data to 10 ms for speed. Set steps=1 for full 1 ms temporal resolution.
permutations = 5; % 5 permutations for speed. This gives a close approximation to the result with full 100 permutations (used in paper).

%% Durations

% Durations time-resolved analyses:
% 5 permutations downsampled to 10 ms resolution takes ~37 seconds (fast parameters).
% 100 permutations with 1 ms resulution takes ~2 hours (original parameters).

% Durations time-generalization:
% 5 permutations downsampled to 10 ms resolution takes ~4 minutes (fast parameters).
% 100 permutations downsampled to 10 ms takes ~85 minutes (original parameters).

% Duration ROI analysis:
% ~ 3 seconds

%% prompt user input

disp('This is a quick demo of the analyses for a representative single subject.')
disp('Please bear in mind that single subject data can be noisier than the group averaged result.')

task = input(' \n Would you like to see results for location (1) or category classification (2)?');

if task~=1 & task~=2
    error('Please press 1 for location or 2 for category.')
end

analysis=input('Which analysis would you like to run?\n Press \n 1 for ROI \n 2 for timecourse \n 3 for time-generalization \n');

if analysis==1 % fMRI
    sbj = 1;
elseif analysis == 2 || analysis == 3 % EEG
    sbj = 25;
else
    error('Please press 1=ROI,2=timecourse or 3=time-generalization.')
end

%% run selected analysis
if task ==1 % location analyses
    
    if analysis==1 % ROI
        Location_ROI(sbj);
        plot_ROI(sbj,task);
        
    elseif analysis==2 % timecourse
        Location_Time_Resolved(steps,permutations,sbj);
        plot_timecourse(sbj,task);
        
    elseif analysis==3 % time-generalization
        Location_Time_Generalization(steps,permutations,sbj);
        plot_time_generalization(sbj,task);
    end
    
else % category analyses
    
    if analysis==1 % ROI
        Category_ROI(sbj);
        plot_ROI(sbj,task);
        
    elseif analysis==2 % timecourse
        Category_Time_Resolved(steps,permutations,sbj);
        plot_timecourse(sbj,task);
        
    elseif analysis==3 % time-generalization
        Category_Time_Generalization(steps,permutations,sbj);
        plot_time_generalization(sbj,task);
    end
    
end

%% Optional: Searchlight analysis (~16 hours, 2 GB memory)
% You also have the option to run the searchlight classification analysis
% of object location across categories. This analysis takes ~16 hours per
% background condition. Because of the long duration, the results
% for this analysis are already saved in ./Results/fMRI/Searchlight/

% to run this analysis uncomment the following lines:

% BG = 1; % 1= no, 2= low, 3= high clutter
% Location_Searchlight(1,BG); 

% to plot the (existing) result uncomment and run this line:

% plot_searchlight(1,BG);

% These results figures are already saved in ./Figures as
% Location_Searchlight_NoClutter.fig
% Location_Searchlight_LowClutter.fig
% Location_Searchlight_HighClutter.fig

%% Optional: DNN analysis (~40 minutes with 5 permutations)
% You also have the option to run the DNN classification analysis
% of object location across categories. This analysis takes ~10 minutes per layer with 5 permutations. 
% Because of the long duration, the results
% for this analysis are already saved in ./Results/CORnet-S/

% to run this analysis uncomment the following lines:

% permutations = 5;
% for ilayer = 1:4 % 1=V1,2=V2,3=V4,4=IT
%     Location_DNN(permutations,ilayer);
% end
% plot_DNN;

% The results figure is saved in ./Figures as
% Location_CORnet-S.fig
