function plot_time_generalization(sbj,analysis)

%% extract location or category information from RDM

if analysis ==1
    
    % load results RDM
    load(sprintf('../Results/EEG/s%.2d_Location_TimeGeneralization.mat',sbj));
    
    % put location in the back
    RDM = permute(RDM,[3 4 5 6 1 2 ]);
    % now cat x cat x time x time x loc x loc
    
    % average across upper diagonal: location decoding
    RDM = squeeze(nanmean(RDM(:,:,:,:,triu(ones(4,4),1)>0),5));
    % now cat x cat x time x time
    
    % now put category in the back again so we can take extract the
    % cross-decoding results from the off-dialgonals
    RDM = permute(RDM,[ 3 4 1 2]);
    
else % category
    
    % load results RDM
    load(sprintf('../Results/EEG/s%.2d_Category_TimeGeneralization.mat',sbj));
    
    % put category in the back
    RDM = permute(RDM,[5 6 1 2 3 4 ]);
    % now time x time x loc x loc x cat x cat
    
    % average across upper diagonal: category decoding
    RDM = squeeze(nanmean(RDM(:,:,:,:,triu(ones(4,4),1)>0),5));
    % now time x time x loc x loc
    
end

% extract cross-decoding from off-diagonals
result = squeeze(nanmean(RDM(:,:,eye(4,4)==0),3))-50;

%% now plot the resulting time-generalization matrix
% get the time points that we analyzed (in case they are subsampled)
t = timepoints(timewindow);

figure;
imagesc(t,t,result);
hold on
line([-100 600],[-100 600],'Color','k','Linewidth',1); % line through diagonal
hold on
line([0 0],[-100 600],'Color','k','Linewidth',1); % vertical stimulus onset
hold on
line([-100 600],[0 0],'Color','k','Linewidth',1); % horizontal stimulus onset
hold on
axis square;
axis xy;
h=colorbar
% caxis([ylimdown ylimup])
set(0,'DefaultAxesFontName', 'Candara')
set(0,'DefaultTextFontname', 'Candara')
set(0,'DefaultAxesFontSize',25)
set(0,'DefaultTextFontSize',25)
colordef white
set(gcf,'Color','w')
xlabel('Test Time: High Clutter');
ylabel('Train Time: No Background');