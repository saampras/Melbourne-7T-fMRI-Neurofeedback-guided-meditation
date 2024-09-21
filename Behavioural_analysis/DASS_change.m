
clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%% Loading and organizing data 

e_sublist = sort([7;8;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;16;10;18;19;27;28;29;31;35;37;38;44;48;49;50;51;55;57]);

sublist = sort([e_sublist;c_sublist]);


%% 

load([root_dir '/Data/Behavioral/DASS/das_bl.mat']);
load([root_dir '/Data/Behavioral/DASS/das_fu.mat']);
age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

[~,~,inds2] = intersect(sublist,das_bl(:,end-1),'stable');

das_bl = das_bl(inds2,:);
das_fu = das_fu(inds2,:);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

dasTot_bl = [mean(das_bl(:,1:3),2),das_bl(:,end-1:end)];
dasTot_fu = [mean(das_fu(:,1:3),2),das_fu(:,end-1:end)];

[~,exp_inds,~] = intersect(sublist,e_sublist,'stable');
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking sub order in all
sub_order_check = isequal(das_bl(:,end-1),...
    das_fu(:,end-1),age(:,end),sex(:,end),sublist)

%% GLM

dasTot_Diff = dasTot_fu(:,1)-dasTot_bl(:,1);
gr = group;
gr(cont_inds) = -1;
X = [gr,zscore([age(:,1),sex(:,1)])];
%X = gr;

[~,~,stats_dasTot] = glmfit(X,dasTot_Diff,'normal','constant','on');
p_dasTot = stats_dasTot.p(2)
coh_d_Tot_diff = stats_dasTot.t(2)/sqrt(stats_dasTot.dfe)

%% GLM after outlier removal

outs = isoutlier(dasTot_Diff);
outs_inds = find(outs);
X2 = [gr,zscore([age(:,1),sex(:,1)])];
X2(outs_inds,:) = [];
Y2 = dasTot_Diff;
Y2(outs_inds,:) = [];

[~,~,stats_dasTot2] = glmfit(X2,Y2,'normal','constant','on');
p_dasTot2 = stats_dasTot2.p(2);
coh_d_Tot_diff2 = stats_dasTot2.t(2)/sqrt(stats_dasTot2.dfe);



%% Plotting
f = figure();
set(f,'Position',[300 800 500 400],'Color','w');
text_font = 40;

%% DASS total difference scores 

[beta,~,st] = glmfit(zscore([age(:,1),sex(:,1)]),dasTot_Diff(:,1));
dasTot_Diff_resi = st.resid + beta(1);

e_data = dasTot_Diff_resi(exp_inds,1);
c_data = dasTot_Diff_resi(cont_inds,1);
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

%xl = xlim; xlim([xl(1)-0.1, xl(2)+0.3]); % make more space for the legend
set(h.sc(1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h.sc(2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h.mn(1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.mn(2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.md(1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.md(2),'LineWidth',1,'Color',[0.8 0 0]);
set(h.ot,'LineWidth',2);

set(gca,'FontSize',text_font);
set(gca,'linewidth',5)
xtickangle(x_angle)

