function Location_Time_Generalization(steps,permutations,sbj)
% Analysis corresponding to Fig. 5e.
% Time-generalization analysis of object location across categories, background and time.
% Additionally to cross-decoding across categories, we train on
% all timepoints in the no clutter and test on all timepoints in the high
% clutter condition.
% Saves single subject's time-time RDM.

% Duration:
% 5 permutations downsampled to 10 ms resolution takes ~4 minutes
% 100 permutations downsampled to 10 ms takes ~85 minutes

% Input:
%       steps: time steps to analyze, integer. 1= 1 ms resolution. Use steps=10 to
%       downsample to 10 ms resolution to make script run faster (used in paper)
%       permutations: how many permutations, integer
%       sbj: subject's number, integer

tic
addpath('Code/HelperFunctions');
addpath('Code/LibsvmFunctions');
savepath = './Results/EEG/';
if ~isdir(savepath); mkdir(savepath); end
filename = 'Location_TimeGeneralization';

% load data. Dimensions: 48 conditions x 60 trials x 63 channels x 1100
% time points
load(sprintf('./Data/EEG/s%.2d_EEG.mat',sbj));

% define which time points to analyze
time_end   = find(timepoints==600); % like in paper, we analyze up until 600 ms post-stimulus to save time and memory
timewindow = 1:steps:time_end;

% forward to function for 1st and second half of experiment. In 1st half design was
% 50 % no, 25% low and 25 % high clutter, but we only take 25% of the no
% clutter condition to keep all equal.
% 2nd half was 1/3 of trials for no, low and high clutter.
if sbj<17
    [RDM] = location_timetime_1sthalf(data,timewindow,permutations);
elseif sbj > 16 
    [RDM] = location_timetime_2ndhalf(data,timewindow,permutations);
else
    error('wrong subject input! Has to be integer between 1 and 29!')
end


duration = toc;

% save result
save([savepath 's' sprintf('%.2d',sbj) '_' filename '.mat' ],'RDM','timepoints','timewindow','duration','-v7.3');

