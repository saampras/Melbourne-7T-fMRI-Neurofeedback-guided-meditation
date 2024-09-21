close all
clear
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));


%Neural analysis sublist
init_sublist = importdata([root_dir '/Data/Neural/sub_pp_ids_rem2.txt']);

e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);

mri_sss_nf = importdata([root_dir '/Data/Behavioral/sms_sss_mri/mri_sss_nf.mat']);

subs_excl = [];
[~,excl_inds,~] = intersect(init_sublist,subs_excl,'stable');
sublist = init_sublist;
sublist(excl_inds) = [];

%%
[~,exp_inds,~] = intersect(sublist,e_sublist);
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

[~,~,inds2] = intersect(sublist,mri_sss_nf(:,end-1),'stable');
mri_sss_nf = mri_sss_nf(inds2,:);
sss_d1 = mean(mri_sss_nf(:,1:3),2);
sss_d2 = mean(mri_sss_nf(:,4:6),2);


source_path = [root_dir '/Data/Neural/pcc_offline_thr0p3_betas/'];
source_path2 = [root_dir '/Data/Neural/dlpfc_glm_betas/'];
for s = 1:length(init_sublist)
    sub = num2str(init_sublist(s));
    t = 0;
    for d = 1:2
        day = num2str(d);
        dlpfc_glm(s,d) = load([source_path2 'sub-' sub ...
                '_ses-d' day '_task-nf_dlpfc_glm_beta.txt']);
        pcc_offline(s,d) = load([source_path 'sub-' sub ...
                 '_ses-d' day '_task-nf_pcc_0p3_beta.txt']);
   
    end
end

pcc_offline = [pcc_offline,init_sublist];
dlpfc_glm = [dlpfc_glm,init_sublist];
[~,~,inds2] = intersect(sublist,pcc_offline(:,end),'stable');
pcc_offline = pcc_offline(inds2,:);
dlpfc_glm = dlpfc_glm(inds2,:);

age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);
[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);


%% Checking sub order in all
sub_order_check = isequal(mri_sss_nf(:,end-1),pcc_offline(:,end),...
    age(:,end),sex(:,end),sublist)


%% Group difference on each day

Y_pcc_d1 = pcc_offline(:,1);
Y_pcc_d2 = pcc_offline(:,2);

gr = group;
gr(~gr) = -1;
X_d1 = [gr,zscore([sss_d1(:,1),age(:,1),sex(:,1)])];
[~,~,stats_pcc_d1] = glmfit(X_d1,Y_pcc_d1,'normal','constant','on'); 
p_pcc_d1 = stats_pcc_d1.p(2)
cohen_d_pcc_d1 = stats_pcc_d1.t(2)/sqrt(stats_pcc_d1.dfe);

X_d2 = [gr,zscore([sss_d2(:,1),age(:,1),sex(:,1)])];
[~,~,stats_pcc_d2] = glmfit(X_d2,Y_pcc_d2,'normal','constant','on'); 
p_pcc_d2 = stats_pcc_d2.p(2)
cohen_d_pcc_d2 = stats_pcc_d2.t(2)/sqrt(stats_pcc_d2.dfe);

%% DLPFC
% dlpfc_d1 = dlpfc_glm(:,1);
% dlpfc_d2 = dlpfc_glm(:,2);
% 
% [~,~,stats_dlpfc_d1] = glmfit(X_d1,dlpfc_d1,'normal','constant','on'); 
% p_dlpfc_d1 = stats_dlpfc_d1.p(2)
% cohen_d_dlpfc_d1 = stats_dlpfc_d1.t(2)/sqrt(stats_dlpfc_d1.dfe);
% 
% [~,~,stats_dlpfc_d2] = glmfit(X_d2,dlpfc_d2,'normal','constant','on'); 
% p_dlpfc_d2 = stats_dlpfc_d2.p(2)
% cohen_d_dlpfc_d2 = stats_dlpfc_d2.t(2)/sqrt(stats_dlpfc_d2.dfe);
% 
% [beta1,~,stats1] = glmfit(x_d1,dlpfc_d1);
% dlpfc_d1_res = stats1.resid + beta1(1);
% 
% [beta2,~,stats2] = glmfit(x_d2,dlpfc_d2);
% dlpfc_d2_res = stats2.resid + beta2(1);



%% plotting PCC results

f = figure();
set(f,'Position',[300 800 500 400],'Color','w');
text_font = 40;
hold on


xtick_labels = {'Day 1','Day 2'};


yrange = [];
ytick_vals = [];
x_angle = 0;
xtick_vals = 1:1:2;


x_d1 = zscore([sss_d1(:,1),age(:,1),sex(:,1)]);
[beta1,~,stats1] = glmfit(x_d1,Y_pcc_d1);
Y_pcc_d1_res = stats1.resid + beta1(1);

x_d2 = zscore([sss_d2(:,1),age(:,1),sex(:,1)]);
[beta2,~,stats2] = glmfit(x_d2,Y_pcc_d2);
Y_pcc_d2_res = stats2.resid + beta2(1);

exp_data = [Y_pcc_d1_res(exp_inds),Y_pcc_d2_res(exp_inds)]; 
cont_data = [Y_pcc_d1_res(cont_inds),Y_pcc_d2_res(cont_inds)]; 

%exp_data = [Y_pcc_d1_res(exp_inds),dlpfc_d1_res(exp_inds),Y_pcc_d2_res(exp_inds),dlpfc_d2_res(exp_inds)]; 
%cont_data = [Y_pcc_d1_res(cont_inds),dlpfc_d1_res(cont_inds),Y_pcc_d2_res(cont_inds),dlpfc_d2_res(cont_inds)]; 

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

title_text = {''};
y_label = {'PCC','activation'};
ylabel('');
xticks(xtick_vals);
set(gca,'linewidth',5)

set(gca,'FontSize',text_font);

