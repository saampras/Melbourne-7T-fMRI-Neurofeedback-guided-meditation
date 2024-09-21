clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));
%Neural analysis sublist
sublist = importdata([root_dir '/Data/Neural/sub_pp_ids_rem2.txt']);

e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);

subs_excl = [];
[~,excl_inds,~] = intersect(sublist,subs_excl);
sublist(excl_inds) = [];

%%

FC = importdata([root_dir '/Data/Neural/FC_pcc_dlpfc_r1r5r6r10.mat']);
FC = reshape(FC(:,1),34,4);
FC(excl_inds,:) = [];
FC = [FC,sublist];

sss_bl_tr = importdata([root_dir '/Data/Behavioral/sms_sss_mri/mri_sss_bl_tr.mat']);
mfd_bl_tr = importdata([root_dir '/Data/NeuroBehavioral/mfd_mri_bl_tr.mat']);
age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

[~,~,inds2] = intersect(sublist,sss_bl_tr(:,end-1),'stable');
sss_bl_tr = sss_bl_tr(inds2,:);

[~,~,inds2] = intersect(sublist,mfd_bl_tr(:,end),'stable');
mfd_bl_tr = mfd_bl_tr(inds2,:);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);


[~,exp_inds,~] = intersect(sublist,e_sublist);
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking sub order in all
sub_order_check = isequal(FC(:,end),sss_bl_tr(:,end-1),...
    mfd_bl_tr(:,end),...
    age(:,end),sex(:,end),sublist)

%% Group difference in FC difference value 

FC_data_diffD2 = FC(:,4) - FC(:,3);

gr = group;
gr(gr==0) = -1;

Y_r6r10_diff = FC_data_diffD2;
X_diff_d2 = [gr,zscore([mean(sss_bl_tr(:,3:4),2),...
    mean(mfd_bl_tr(:,3:4),2),age(:,1),sex(:,1)])];
[~,~,stats_diff_d2] = ...
    glmfit(X_diff_d2,Y_r6r10_diff,...
    'normal','constant','on');
p_diff_d2 = stats_diff_d2.p(2)
cohen_d_diff_d2 = stats_diff_d2.t(2)/sqrt(stats_diff_d2.dfe)


%% Plotting

f = figure();
set(f,'Position',[300 800 500 400],'Color','w');
text_font = 40;
hold on


xtick_labels = {'Baseline D1',...
    'Transfer D1',...
    'Baseline D2','Transfer D2'};
x_label = {''};

yrange = [];
ytick_vals = [];
x_angle = 45;
xtick_vals = 1:1:4;

[beta,~,st] = glmfit(zscore([mean(sss_bl_tr(:,3:4),2),...
    mean(mfd_bl_tr(:,3:4),2)]),Y_r6r10_diff);
Y_diff_res = st.resid + beta(1);

exp_data = Y_diff_res(exp_inds); 
cont_data = Y_diff_res(cont_inds); 

viol_data{1} = exp_data;
viol_data{2} = cont_data;
group_names = {'EXP','CONT'};
c =  [0, 0, 1;...
      1, 0, 0];

h = daboxplot(viol_data,'linkline',0,'mean',1,...
    'xtlabels',{''},...
    'whiskers',1,'outliers',1,'outsymbol','k>',...
    'scatter',2,'boxalpha',0.5,'jitter',1,'scattersize',50,...
    'mean',1);

set(h.mn(1),'LineWidth',4.5,'Color',[0 0 0.8]);
set(h.mn(2),'LineWidth',4.5,'Color',[0.8 0 0]);
set(h.md(1),'LineWidth',1,'Color',[0 0 0.8]);
set(h.md(2),'LineWidth',1,'Color',[0.8 0 0]);
set(h.ot,'LineWidth',2);


title_text = {''};
y_label = {'PCC-DLPFC','Functional Connectivity'};
ylabel('');

legend_details = {['exp (N=' num2str(size(exp_data,1)) ')'],...
    ['cont (N=' num2str(size(cont_data,1)) ')']};

set(gca,'FontSize',text_font);
set(gca,'linewidth',5)

