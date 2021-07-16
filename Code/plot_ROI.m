function plot_ROI(myData,task)
% plotting of ROI results either for decoding of object location across
% categories (task==1) or vice versa (task==2), within each
% background condition separately.

% Input:
%   myData: decoding results. Dimensions: subjects x [3 backgrounds*ROIs]
%   task: integer, 1=location, 2=category

if task == 1
    filename = 'Location';
    ylims = [-1 25];
else
    filename = 'Category';
    ylims = [-1.5 7];
end

BG    = 3;
nrois = (size(myData,2))/BG;

%% figure setup
hf = figure('position',[1,1,1000, 750], 'unit','pixel');
set(gcf,'PaperUnits','centimeters','PaperSize',[30,30],'PaperPosition',[0,0,30,30]);
colordef white
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultAxesFontSize',25)
set(0,'DefaultTextFontSize',25)
set(gcf,'Color','w')
barcolor = nan; % initialize
hold on

% colors
c1 = [0.6,0.6,0.6];
c2 = [0,1,0];
c3 = [0,0,1];

% c1 = [0.6,0.6,0.6];
% c2 = [0,0.7,0];
% c3 = [0,0,0.7];

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

% means
m = mean(myData);

xb       = nan(BG,nrois); % vector containing bar positions
xb(1,1)  = 1.05;
newsteps = (BG+1):BG:length(m)-2;

for j = 2:length(m)
    
    if ismember(j,newsteps) % big step before new ROI
        xb(j)=xb(j-1)+1.6;
    else
        xb(j)=xb(j-1)+0.85; % small step between bgs
    end
    
end
xb  = xb(:); % straighten bar positions
se  = std(myData)/sqrt(size(myData,1));
no  = [1:3:length(m)-2];
low = [2:3:length(m)-1];

% plot bars
for ibar=1:size(myData,2)
    
    h = bar(xb(ibar),m(ibar));
    clear barcolor
    if ismember(ibar,no) % nobg
        set(h,'facecolor',c1);
        barcolor = c1;
    elseif ismember(ibar,low) % low clutter
        set(h,'facecolor',c2);
        barcolor = c2;
    else
        set(h,'facecolor',c3); % high clutter
        barcolor = c3;
    end
    set(h,'linewidth',3);
    
    hl = line([xb(ibar),xb(ibar)],[m(ibar)-se(ibar),m(ibar)+se(ibar)]);
    set(hl,'linewidth',3);
    set(hl,'color','k');
    
    % plot single subject dots for single bar for correct x-axis position
    for isub=1:size(myData,1)
%         plot(xb(ibar),squeeze(myData(isub,ibar)),'.','Color',barcolor+0.3);
        plot(xb(ibar),squeeze(myData(isub,ibar)),'.','Color',[0.5 0.5 0.5]);
        hold on
    end
    
end

% legend
L=legend({'No clutter','Low clutter','High clutter'});
set(L,'box','off');

% other plot properties
ylabel('Classification accuracy - chance level (%)');
xlabel('ROI');
set(gca,'linewidth',3);
set(gca,'xtick',[xb(low,1)]);
set(gca,'xticklabel',{'V1' 'V2' 'V3' 'V4' 'LOC' 'IPS0' 'IPS1' 'IPS2' 'SPL'});
axis tight
% ylim(ylims);
xlim([0.2 length(m)+3]);
set(gca,'ticklength',2*get(gca,'ticklength'))
title(filename)
