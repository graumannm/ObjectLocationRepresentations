function plot_ROI(sbj,analysis)
% plotting of ROI results either for decoding of object location across
% categories (analysis==1) or vice versa (analysis==2), within each
% background condition separately.

% Input:
%   sbj: subject's number, integer
%   analysis: integer, 1=location, 2=category

if analysis == 1
    filename = 'Location';
else
    filename = 'Category';
end

% load results RDM
load(sprintf(['../Results/fMRI/ROI/s%.2d_' filename '_ROI.mat'],sbj));
ROI_name  = {'V1' 'V2' 'V3' 'V4' 'LO'};

% flatten result into vector, sorted by ROI
myData = result';
myData = myData(:);

%% figure setup
hf = figure('position',[1,1,1000, 750], 'unit','pixel');
set(gcf,'PaperUnits','centimeters','PaperSize',[30,30],'PaperPosition',[0,0,30,30]);
colordef white
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultAxesFontSize',25)
set(0,'DefaultTextFontSize',25)
set(gcf,'Color','w')
hold on

% colors
c1 = [0.6,0.6,0.6];
c2 = [0,1,0];
c3 = [0,0,1];

% fake bars (for legend)
h=bar(0,0);
set(h,'facecolor',c1);
set(h,'linewidth',3);
h=bar(0,0);
set(h,'facecolor',c2);
set(h,'linewidth',3);
h=bar(0,0);
set(h,'facecolor',c3);
set(h,'linewidth',3);

% x axis position: wide distance=1.1; narrow=0.9
% xb = [1.05,1.95,  3.05,3.95  ,5.05,5.95  ,7.05,7.95];
xb = nan(3,5); % vector containing bar positions
xb(1,1)=1.05;
for j = 2:15
    
    if ismember(j,[4,7,10,13]) % big step before new ROI
        xb(j)=xb(j-1)+1.6;
    else
        xb(j)=xb(j-1)+0.85; % small step between bgs
    end
    
end
xb = xb(:); % straighten bar positions

% plot stuff
for i=1:size(myData,1) % same as length of m

    % plot the bar
    h = bar(xb(i),myData(i)); % xb says where m(i) what
    if ismember(i,[1,4,7,10,13]) % nobg
        set(h,'facecolor',c1);
    elseif ismember(i,[2,5,8,11,14]) % low clutter
        set(h,'facecolor',c2);
    else
        set(h,'facecolor',c3); % high clutter
    end
    set(h,'linewidth',3);
    
end

% legend
L=legend({'No Background','Low Clutter','High Clutter'});
set(L,'box','off');

% other plot properties
ylabel('Classification Accuracy (%)');
xlabel('ROI');
set(gca,'linewidth',3);
set(gca,'xtick',[xb([2,5,8,11,14],1)]); % where to put labels
set(gca,'xticklabel',{'V1' 'V2' 'V3' 'V4' 'LOC'});
axis tight
lims=ylim;
ylim([lims(1) lims(2)+10]) % add space for legend 
xlim([0.2 18]); % make x-axis wider so all bars are visible
set(gca,'ticklength',2*get(gca,'ticklength'))
