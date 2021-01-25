% run single subject demo analysis
% requirement: libsvm toolbox has to be in the path

clear
clc

%% set parameters for EEG time-resolved and time-generalization analysis

steps        = 10; % downsample to 10 ms for speed. Set steps=1 for full 1 ms temporal resolution.
permutations = 5; % 5 permutations for speed. This gives a close approximation to the result with full 100 permutations (used in paper).
% Set to 100 permutations for full replication of

% Durations time-resolved analyses:
% 5 permutations downsampled to 10 ms resolution takes ~37 seconds (fast parameters).
% 100 permutations with full 1 ms resulution takes ~2 hours (original
% parameters).

% Durations time-generalization:
% 5 permutations downsampled to 10 ms resolution takes ~4 minutes (fast parameters).
% 100 permutations downsampled to 10 ms takes ~85 minutes (original
% parameters).

%% prompt user input

task = input('Would you like to see results for location (1) or category classification (2)?');

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