function plot_location_timecourse(sbj)
% Extract the timecourse of location across category for each individual
% background condition from the results RDM and plot the result.

% Input:
%   sbj: subject's number, integer

% load results RDM
load(sprintf('../Results/EEG/s%.2d_Location_Timecourse.mat',sbj));
% dimensions of the results RDM are now:
% 3 backgrounds x 3 backgrounds x 4 locations x 4 locations x 4 categories
% x 4 categories x timepoints

%% extract location across categories, within each background condition

% put location in the back
location = permute(RDM,[4 5 6 1 2 3 ]);

% average across upper diagonal: location decoding
location = squeeze(nanmean(location(:,:,:,:,triu(ones(4,4),1)>0),5));

% now put category in the back again so we can take extract the
% cross-decoding results from the off-dialgonals
location = permute(location,[ 3 4 1 2]);

% extract and average upper and lower diagonal, which is location decoding
% across categories, training and testing in both directions (hence upper and lower diagonal)
% also subtract 50 = chance level
LocXCat = squeeze(nanmean(location(:,:,eye(4,4)==0),3))-50; clear location RDM

% now we can extract the diagonals from the background (3x3), because we
% only look at within background location decoding for the timecourse
no   = squeeze(LocXCat(:,1));
low  = squeeze(LocXCat(:,2));
high = squeeze(LocXCat(:,3));

%% now plot the resulting timecourses

% get the time points that we analyzed (in case they are subsampled)
t = timepoints(timewindow);

% define upper and lower y-axis bounds
ylimlow = -10;
ylimup  = 40;

% figure setup
hf = figure('position',[1,1,750, 750], 'unit','pixel');
set(gcf,'PaperUnits','centimeters','PaperSize',[20,20],'PaperPosition',[0,0,20,20]);
colordef white
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultAxesFontSize',25)
set(0,'DefaultTextFontSize',25)
set(gcf,'Color','w')
set(gca,'linewidth',3);
% set(gca,'xtick',[timepoints(timewindow(1)):100:timepoints(timewindow(end))]);
% set(gca,'ticklength',2*get(gca,'ticklength'));

% define colors
c1 = [0.6,0.6,0.6];
c2 = [0,1,0];
c3 = [0,0,1];

plot(t,no,'color',c1,'linewidth',3)
hold on
plot(t,low,'color',c2,'linewidth',3)
hold on
plot(t,high,'color',c3,'linewidth',3)

hold on
% stimulus onset
plot([0 0],[ylimlow ylimup],'k--','linewidth',3);
hold on
% chance line
plot(timepoints(timewindow),0*ones(length(timewindow),1),'k--','linewidth',3) 

% legend
L = legend({'No Clutter','Low Clutter','High Clutter'},'AutoUpdate','off')
set(L,'box','off');

ylabel('Classification Accuracy - Chance (%)');
xlabel('Time (ms)');

