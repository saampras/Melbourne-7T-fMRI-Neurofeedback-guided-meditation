
clear
close all

root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%neural analysis sublist
sublist = importdata([root_dir '/Data/Neural/sub_pp_ids_rem2.txt']);

e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);


online_conf_med = importdata([root_dir '/Data/Neural/conf_psc_nf_med.mat']);
online_conf_rest = importdata([root_dir '/Data/Neural/conf_psc_nf_rest.mat']);

[~,~,inds2] = intersect(sublist,online_conf_med(:,end),'stable');
online_conf_med = online_conf_med(inds2,:);
online_conf_rest = online_conf_rest(inds2,:);

age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,exp_inds,~] = intersect(sublist,e_sublist);
groups = zeros(length(sublist),1);
groups(exp_inds) = 1;
cont_inds = find(~groups);

%% Checking sub order in all
sub_order_check = isequal(online_conf_med(:,end),online_conf_rest(:,end),...
    age(:,end),sex(:,end),sublist)


num_runs = 6;

for run = 1:num_runs
   ir = (run*2)-1:run*2; 
   online_conf_rest_runwise(:,run) = mean(online_conf_rest(:,ir),2);   
   im = (1+(run-1)*6):(6+(run-1)*6);
   Conf_psc_runwise(:,run) = mean(online_conf_med(:,im),2);     
end

Conf_psc_runwise = [Conf_psc_runwise,sublist];


%% Group difference of confound PSC values

gr = groups;
gr(gr==0) = -1;
cov = zscore([age(:,1),sex(:,1)]);
X_gr = [gr,cov];
Y_confdiff_d1 = mean(Conf_psc_runwise(:,1:3),2);

[~,~,stats_confdiff_d1] = glmfit(X_gr,Y_confdiff_d1,...
    'normal','constant','on');
p_confdiff_d1 = stats_confdiff_d1.p(2)
tstat_confdiff_d1 = stats_confdiff_d1.t(2);
Cohen_d_confdiff_d1 = tstat_confdiff_d1/sqrt(stats_confdiff_d1.dfe)

Y_confdiff_d2 = mean(Conf_psc_runwise(:,4:6),2);
[~,~,stats_confdiff_d2] = glmfit(X_gr,Y_confdiff_d2,...
    'normal','constant','on');
p_confdiff_d2 = stats_confdiff_d2.p(2)
tstat_confdiff_d2 = stats_confdiff_d2.t(2);
Cohen_d_confdiff_d2 = tstat_confdiff_d2/sqrt(stats_confdiff_d2.dfe)



%% plot
 
f = figure();
set(f,'Position',[300 800 500 400],'Color','w');

text_font = 40;
hold on

xtick_vals = 1:1:2;


[beta,~,st] = glmfit(zscore([age(:,1),sex(:,1)]),Y_confdiff_d1(:,1));
Y_confdiff_d1_resi = st.resid + beta(1);
[beta,~,st] = glmfit(zscore([age(:,1),sex(:,1)]),Y_confdiff_d2(:,1));
Y_confdiff_d2_resi = st.resid + beta(1);

exp_data = [Y_confdiff_d1_resi(exp_inds),Y_confdiff_d2_resi(exp_inds)]; 
cont_data = [Y_confdiff_d1_resi(cont_inds),Y_confdiff_d2_resi(cont_inds)]; 

viol_data{1} = exp_data;
viol_data{2} = cont_data;
group_names = {'EXP','CONT'};
c =  [0, 0, 1;...
      1, 0, 0];


h = daboxplot(viol_data,'linkline',0,'mean',1,...
    'xtlabels',{''},'legend',group_names,...
    'whiskers',1,'outliers',1,'outsymbol','k>',...
    'scatter',2,'boxalpha',0.5,'jitter',1,'scattersize',50,...
    'mean',1);

set(h.mn(1,1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.mn(2,1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.mn(1,2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.mn(2,2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.md(1,1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.md(2,1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.md(1,2),'LineWidth',1,'Color',[0.8 0 0]);
set(h.md(2,2),'LineWidth',1,'Color',[0.8 0 0]);
%set(h.ln,'LineWidth',6.5,'LineStyle','-');
set(h.ot,'LineWidth',2);
set(h.lg,'LineWidth',0.05);
set(h.lg,'FontSize',30);

ylabel('');
xticks(xtick_vals);
set(gca,'linewidth',5)

set(gca,'FontSize',text_font);

