clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%% Loading and organizing data 

e_sublist = sort([7;8;13;15;20;22;24;30;32;34;36;39;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;44;48;49;50;51;55;57]);

sublist = sort([e_sublist;c_sublist]);


age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

load([root_dir '/Data/Behavioral/DASS/das_bl.mat']);
load([root_dir '/Data/Behavioral/DASS/das_fu.mat']);

sms_slope = importdata([root_dir '/Data/Behavioral/sms_sss_5min_meditation/lin_slope_smsmind.mat']);


direc = dir([root_dir '/Data/Behavioral/BCT']);

for i=3:length(direc)
    load([direc(i).folder '/' direc(i).name]);
end

[~,~,inds2] = intersect(sublist,bct_acc(:,end),'stable');
bct_acc = bct_acc(inds2,:);
bct_misc = bct_misc(inds2,:);
bct_probe_acc = bct_probe_acc(inds2,:);
bct_res = bct_res(inds2,:);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,~,inds2] = intersect(sublist,sms_slope(:,end-1),'stable');
sms_slope = sms_slope(inds2,:);

[~,exp_inds,~] = intersect(sublist,e_sublist);
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking sub order in all

sub_order_check = isequal(bct_acc(:,end),...
    age(:,end),sex(:,end),...
    sms_slope(:,end-1),sublist)


%% GLM

bct_acc_diff = bct_acc(:,2) - bct_acc(:,1);
bct_probe_acc_diff = bct_probe_acc(:,2) - bct_probe_acc(:,1);

gr = group;
gr(cont_inds) = -1;

X = [gr,zscore([age(:,1),sex(:,1)])];
[~,~,stats_acc] = glmfit(X,bct_acc_diff,'normal','constant','on');
p_acc = stats_acc.p(2) 
cohen_d_acc = stats_acc.t(2)/sqrt(stats_acc.dfe)


%% Wilcoxon test for group difference of probe accuracy data

[p_bct_probe,~,stats_bct_probe] = ranksum(bct_probe_acc_diff(exp_inds),...
    bct_probe_acc_diff(cont_inds));
df = 34;
p_bct_probe;
cohen_d_bct_probe = stats_bct_probe.zval/sqrt(df);

%% Correlation between bct accuracy difference and sms

[rho_sms_bct,pval_sms_bct] = partialcorr(sms_slope(:,1),bct_acc_diff(:,1),...
    [age(:,1),sex(:,1)]);

%% Plotting BCT accuracy

f = figure();
set(f,'Position',[300 800 500 400],'Color','w');
text_font = 40;


%BCT acc
[beta,~,st] = glmfit(zscore([age(:,1),sex(:,1)]),bct_acc_diff(:,1));
bct_acc_diff_resi = st.resid + beta(1);


e_data = bct_acc_diff_resi(exp_inds);
c_data = bct_acc_diff_resi(cont_inds);
%y_label = {'BCT accuracy %'};
y_label = {''};

xtick_labels = {''};
x_angle = 0;


viol_data{1} = e_data;
viol_data{2} = c_data;
c =  [0, 0, 1;...
      1, 0, 0];
  
group_names = {'EXP', 'CONT'};

h = daboxplot(viol_data,'outsymbol','k+',...
    'xtlabels',xtick_labels,'color',c,'fill',1,'outliers',1,...
    'whiskers',0,'scatter',2,'jitter',1,'scattersize',50,'mean',1,...
    'boxalpha',0.2,'boxwidth',1);

xl = xlim; xlim([xl(1)+0.6, xl(2)-0.6]); % make more space for the legend
set(h.sc(1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h.sc(2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h.mn(1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.mn(2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.md(1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.md(2),'LineWidth',1,'Color',[0.8 0 0]);
set(h.ot,'LineWidth',2);


set(gca,'FontSize',text_font);
xtickangle(x_angle)
set(gca,'linewidth',5)
%xlim([0.75 2.2]);

%% Plotting BCT probes

f2 = figure();
set(f2,'Position',[300 800 500 400],'Color','w');
text_font = 40;


e_data = bct_probe_acc_diff(exp_inds);
c_data = bct_probe_acc_diff(cont_inds);
y_label = {''};

xtick_labels = {''};
x_angle = 0;


viol_data{1} = e_data;
viol_data{2} = c_data;
c =  [0, 0, 1;...
      1, 0, 0];
  
group_names = {'EXP', 'CONT'};

h = daboxplot(viol_data,'outsymbol','k+',...
    'xtlabels',xtick_labels,'color',c,'fill',1,'outliers',1,...
    'whiskers',0,'scatter',2,'jitter',1,'scattersize',50,'mean',1,...
    'boxalpha',0.2,'boxwidth',1);

xl = xlim; xlim([xl(1)-0.1, xl(2)+0.3]); % make more space for the legend
set(h.sc(1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h.sc(2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h.mn(1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.mn(2),'LineWidth',1,'Color',[0.8 0 0]);
set(h.md(1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.md(2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.ot,'LineWidth',2);

set(gca,'FontSize',text_font);
xtickangle(x_angle)
set(gca,'linewidth',5)

%% Plotting correlation bw sms slopes and BCT acc

f3 = figure();
set(f3,'Position',[300 800 500 400],'Color','w');
x = sms_slope(:,1);
y = bct_acc_diff;


nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);
ylabel('');
xlabel('');

patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
      [0.3 0.3 0.3],'EdgeColor','None','FaceAlpha',0.1);
hold on;
p3 = line(x,y_fit,'color',[0,0,0],'LineWidth',2);
scatter(x,y,100,[0.5 0.5 0.5],'filled'); hold on;

ax = gca;
ax.FontSize = text_font;
set(gca,'linewidth',5)

