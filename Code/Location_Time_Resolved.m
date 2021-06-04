function Location_Time_Resolved(steps,permutations,sbj)
% Analysis corresponding to Fig. 3a.
% Time-resolved EEG cross-decoding of object location across categories, in
% each background condition separately. 
% Saves single subject's time-resolved RDM.

% Duration:
% 5 permutations downsampled to 10 ms resolution takes ~37 seconds
% 100 permutations with full 1 ms resulution takes ~2 hours

% Input:
%       steps: time steps to analyze, integer. 1= 1 ms resolution. Use steps=10 to
%       downsample to 10 ms resolution to make script run faster
%       permutations: how many permutations, integer
%       sbj: subject's number, integer

tic

% prepare paths & filenames
addpath('/home/monikag/CATLOC/ObjectLocationRepresentations/Code/HelperFunctions');
addpath('/home/monikag/CATLOC/ObjectLocationRepresentations/Code/LibsvmFunctions'); % libsvm 3.1.1.
savepath = '/home/monikag/CATLOC/ObjectLocationRepresentations/Results/EEG/';
if ~isdir(savepath); mkdir(savepath); end
filename = 'Location_Timecourse';

% load data. Dimensions: 48 conditions x 60 trials x 63 channels x 1100
% time points
load(sprintf('/home/monikag/CATLOC/ObjectLocationRepresentations/Data/EEG/s%.2d_EEG.mat',sbj));

% define which time points to analyze
timewindow = 1:steps:length(timepoints);

% forward to code for 1st and second half of experiment. In 1st half design was
% 50 % no, 25% low and 25 % high clutter, but we only take 25% of no
% clutter condition to keep all equal.
% 2nd half was 1/3 of trials for no, low and high clutter.
if sbj<17
    [RDM, patterns] = location_timecourse_1sthalf(data,timewindow,permutations);
elseif sbj > 16 
    [RDM, patterns] = location_timecourse_2ndhalf(data,timewindow,permutations);
else
    error('wrong subject input! Has to be integer between 1 and 29!')
end

duration = toc;

% save result
save([savepath 's' sprintf('%.2d',sbj) '_' filename '.mat' ],'RDM','patterns','timepoints','timewindow','duration','-v7.3');

