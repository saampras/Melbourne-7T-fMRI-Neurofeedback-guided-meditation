clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';

addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%% Loading and organizing data 

e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;18;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);

sublist = sort([e_sublist;c_sublist]);

%%

direc = dir([root_dir '/Data/Behavioral/MRI_selfRatings']);

for i=3:length(direc)
    load([direc(i).folder '/' direc(i).name]);
end

mri_sss_nf = importdata([root_dir '/Data/Behavioral/sms_sss_mri/mri_sss_nf.mat']);


[~,~,inds2] = intersect(sublist,mri_sss_nf(:,end-1),'stable');
mri_sss_nf = mri_sss_nf(inds2,:);
mean_mri_sss_d1 = mean(mri_sss_nf(:,1:3),2);
mean_mri_sss_d2 = mean(mri_sss_nf(:,4:6),2);

[~,~,inds2] = intersect(sublist,nf_corres(:,end-1),'stable');
nf_corres = nf_corres(inds2,:);
med_perf = med_perf(inds2,:);
nf_helpful = nf_helpful(inds2,:);


age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,exp_inds,~] = intersect(sublist,e_sublist,'stable');
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking sub order in all
sub_order_check = isequal(mri_sss_nf(:,end-1),...
    nf_corres(:,end-1),med_perf(:,end-1),...
    nf_helpful(:,end-1),age(:,end),sex(:,end),sublist)



%% Wilcoxon test for group difference on each day

for d = 1:2
[p_nfhelp(d,1),~,stats_wx_nfhelp(d,:)] = ranksum(nf_helpful(exp_inds,d),...
    nf_helpful(cont_inds,d));
[p_nfcorres(d,1),~,stats_wx_nfcorres(d,:)] = ranksum(nf_corres(exp_inds,d),...
    nf_corres(cont_inds,d));
[p_medperf(d,1),~,stats_wx_medperf(d,:)] = ranksum(med_perf(exp_inds,d),...
    med_perf(cont_inds,d));
end


%% Plotting

xtick_labels = {'NF ses-1','NF ses-2'};
x_angle = 25;
text_font = 40;
yrange = [1 5];
xtick_vals = 1:1:2;
linethickness = 1.5;
ytick_vals = yrange(1):1:yrange(2);

%% Did feedback values correspond with focus levels?

f1 = figure();
set(f1,'Position',[300 800 500 400],'Color','w');

data1 = nf_corres(:,1);
data2 = nf_corres(:,2);

exp_data = [data1(exp_inds),data2(exp_inds)];
cont_data = [data1(cont_inds),data2(cont_inds)];

nf_corres_median_exp = median(exp_data);
nf_corres_median_cont = median(cont_data);

c =  [0, 0, 1;...
      1, 0, 0];
group_names = {'EXP','CONT'};

viol_data{1} = exp_data;
viol_data{2} = cont_data;

h1 = daboxplot(viol_data,'outsymbol','k+',...
    'xtlabels',xtick_labels,'color',c,'fill',1,'outliers',1,...
    'whiskers',0,'scatter',2,'jitter',1,'scattersize',25,'mean',1,...
    'boxalpha',0.2,'boxwidth',1,'linkline',0,'legend',group_names);
set(h1.sc(1:2,1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h1.sc(1:2,2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h1.mn(1:2,1),'LineWidth',1,'Color',[0 0 0.8]);
set(h1.mn(1:2,2),'LineWidth',1,'Color',[0.8 0 0]);
set(h1.md(1:2,1),'LineWidth',3.5,'Color',[0 0 0.8]);
set(h1.md(1:2,2),'LineWidth',3.5,'Color',[0.8 0 0]);

ylabel({''});
set(gca,'FontSize',text_font);
ylim([0 6]);
yticks([1:5]);
xlim([0 3]);
xticklabels('');
set(gca,'FontSize',text_font);
set(gca,'linewidth',5)
set(h1.lg,'LineWidth',0.05);
set(h1.lg,'FontSize',30);


%% Rating of meditation performance

f2 = figure();
set(f2,'Position',[300 800 500 400],'Color','w');

data1 = med_perf(:,1);
data2 = med_perf(:,2);
exp_data = [data1(exp_inds),data2(exp_inds)];
cont_data = [data1(cont_inds),data2(cont_inds)];

med_perf_median_exp = median(exp_data);
med_perf_median_cont = median(cont_data);

viol_data{1} = exp_data;
viol_data{2} = cont_data;

h2 = daboxplot(viol_data,'outsymbol','k+',...
    'xtlabels',xtick_labels,'color',c,'fill',1,'outliers',1,...
    'whiskers',0,'scatter',2,'jitter',1,'scattersize',25,'mean',1,...
    'boxalpha',0.2,'boxwidth',1,'linkline',0,'legend',group_names);
set(h2.sc(1:2,1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h2.sc(1:2,2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h2.mn(1:2,1),'LineWidth',1,'Color',[0 0 0.8]);
set(h2.mn(1:2,2),'LineWidth',1,'Color',[0.8 0 0]);
set(h2.md(1:2,1),'LineWidth',3.5,'Color',[0 0 0.8]);
set(h2.md(1:2,2),'LineWidth',3.5,'Color',[0.8 0 0]);

ylabel({''});
set(gca,'FontSize',text_font);
ylim([0 6]);
yticks([1:5]);
xlim([0.2 3]);
xticklabels('');
set(gca,'FontSize',text_font);
set(gca,'linewidth',5)
set(h2.lg,'LineWidth',0.05);
set(h2.lg,'FontSize',30);

%% Was feedback helpful for learning to meditate?

f3 = figure();
set(f3,'Position',[300 800 500 400],'Color','w');

data1 = nf_helpful(:,1);
data2 = nf_helpful(:,2);
exp_data = [data1(exp_inds),data2(exp_inds)];
cont_data = [data1(cont_inds),data2(cont_inds)];

viol_data{1} = exp_data;
viol_data{2} = cont_data;

nf_helpful_median_exp = median(exp_data);
nf_helpful_median_cont = median(cont_data);

h3 = daboxplot(viol_data,'outsymbol','k+',...
    'xtlabels',xtick_labels,'color',c,'fill',1,'outliers',1,...
    'whiskers',0,'scatter',2,'jitter',1,'scattersize',25,'mean',1,...
    'boxalpha',0.2,'boxwidth',1,'linkline',0,'legend',group_names);
set(h3.sc(1:2,1),'MarkerEdgeColor','b','Marker','>',...
    'MarkerFaceColor','b'); 
set(h3.sc(1:2,2),'MarkerEdgeColor','r','Marker','>','MarkerFaceColor','r'); 
set(h3.mn(1:2,1),'LineWidth',1,'Color',[0 0 0.8]);
set(h3.mn(1:2,2),'LineWidth',1,'Color',[0.8 0 0]);
set(h3.md(1:2,1),'LineWidth',3.5,'Color',[0 0 0.8]);
set(h3.md(1:2,2),'LineWidth',3.5,'Color',[0.8 0 0]);

ylabel({''});
set(gca,'FontSize',text_font);
ylim([0 6]);
yticks([1:5]);
xlim([0 3]);
xticklabels('');
set(gca,'FontSize',text_font);
set(gca,'linewidth',5)
set(h3.lg,'LineWidth',0.05);
set(h3.lg,'FontSize',30);

