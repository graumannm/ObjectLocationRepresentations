function plot_searchlight(sbj,BG)
% plot axial slices of searchlight classification of object location across
% categories.

% Input:
%       sbj: subject's number, integer
%       BG: background,integer. 1=no, 2=low, 3= high clutter

task                  = 'Location';
background_conditions = {'No','Low','High'};

% load searchlight .mat file
load(sprintf(['./Results/fMRI/Searchlight/s%.2d/s%.2d_' task '_SL_' background_conditions{BG} '_Clutter.mat'],sbj,sbj));

count=0;
figure;

set(0,'DefaultAxesFontSize',5)
set(0,'DefaultTextFontSize',5)

for slice=12:2:60
    
    count=count+1;
    subplot(5,5,count)
    imagesc(squeeze(SL(:,:,slice))); axis square; colorbar
    
    sgtitle([background_conditions{BG} ' Clutter'])
end
