
clear
close all

root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));


%Neural analysis sublist
sublist = importdata([root_dir '/Data/Neural/sub_pp_ids_rem2.txt']);
%sublist = importdata([root_dir '/Data/Neural/sub_pp_ids.txt']); %use this for expMatched analysis
e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);


[~,exp_inds,~] = intersect(sublist,e_sublist);
groups = zeros(length(sublist),1);
groups(exp_inds) = 1;
cont_inds = find(~groups);

pcc_online = importdata([root_dir '/Data/Neural/nf_psc_rundata.mat']);

age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);
cont_matchExp = importdata([root_dir '/Data/Neural/cont_matched_exp_ids_nf.mat']);
mri_sss_nf = importdata([root_dir '/Data/Behavioral/sms_sss_mri/mri_sss_nf.mat']);

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,~,inds2] = intersect(sublist,mri_sss_nf(:,end-1),'stable');
mri_sss_nf = mri_sss_nf(inds2,:);

sss1 = [mean(mri_sss_nf(:,1:3),2),mri_sss_nf(:,end-1:end)];
sss2 = [mean(mri_sss_nf(:,4:6),2),mri_sss_nf(:,end-1:end)];

[~,~,inds2] = intersect(sublist,pcc_online(:,end-1),'stable');
pcc_online = pcc_online(inds2,:);
% 
[~,~,inds2] = intersect(sublist(cont_inds),cont_matchExp(:,1),'stable');
cont_matchExp = cont_matchExp(inds2,:);


%% Extracting offline day-wise PCC GLM beta values

source_path = [root_dir '/Data/Neural/pcc_offline_thr0p3_betas/'];
for s = 1:length(sublist)
    sub = num2str(sublist(s));
    t = 0;
    for d = 1:2
        day = num2str(d);
        
        pcc_offline(s,d) = load([source_path 'sub-' sub ...
                 '_ses-d' day '_task-nf_pcc_0p3_beta.txt']);
        for r = 1:3
            run = num2str(r);
            t = t+1;
            pcc_offline_runs(s,t) = load([source_path 'sub-' sub ...
                '_ses-d' day '_run-0' run '_task-nf_pcc_0p3_beta.txt']);
        end    

    end
end

pcc_offline = [pcc_offline,sublist];
pcc_offline_runs = [pcc_offline_runs,sublist];

%% Checking sub order in all
sub_order_check = isequal(pcc_online(:,end-1),pcc_offline(:,end),...
    age(:,end),sex(:,end),sublist)

 
%% Correlation of day-wise values

pcc_off_mean1 = pcc_offline(:,1); %with mfd correction
pcc_on_mean1 = mean(pcc_online(:,1:3),2);

[rho1,pval_corr1] = corr(pcc_off_mean1,pcc_on_mean1);

pcc_off_mean2 = pcc_offline(:,2); %with mfd correction
pcc_on_mean2 = mean(pcc_online(:,4:6),2);

[rho2,pval_corr2] = corr(pcc_off_mean2,pcc_on_mean2);

%% ExpMatched analysis: Correlation of mean values between sham and real PSC in control group

% for i=1:size(cont_matchExp,1)
%     cont_matchExp_inds(i,1) = find(cont_matchExp(i,1) == pcc_online(:,end-1));
%     cont_matchExp_inds(i,2) = find(cont_matchExp(i,2) == pcc_online(:,end-1));
% end
% pcc_online_matchExp = pcc_online(cont_matchExp_inds(:,2),:);
% pcc_online_cont = pcc_online(cont_matchExp_inds(:,1),:);
% 
% pcc_offline_matchExp = pcc_offline(cont_matchExp_inds(:,2),:);
% pcc_offline_cont = pcc_offline(cont_matchExp_inds(:,1),:);
% 
% sss_cont_s1 = sss1(cont_matchExp_inds(:,1),:);
% sss_cont_s2 = sss2(cont_matchExp_inds(:,1),:);
% sss_matchExp_s1 = sss1(cont_matchExp_inds(:,2),:);
% sss_matchExp_s2 = sss2(cont_matchExp_inds(:,2),:);
% age_cont = age(cont_matchExp_inds(:,1),:);
% sex_cont = sex(cont_matchExp_inds(:,1),:);
% age_matchExp = age(cont_matchExp_inds(:,2),:);
% sex_matchExp = sex(cont_matchExp_inds(:,2),:);
% 
% [beta,~,st] = glmfit(zscore([age_cont(:,1),sex_cont(:,1),sss_cont_s1(:,1)]),pcc_offline_cont(:,1));
% pcc_offline_cont_resi_s1 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_cont(:,1),sex_cont(:,1),sss_cont_s2(:,1)]),pcc_offline_cont(:,2));
% pcc_offline_cont_resi_s2 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_matchExp(:,1),sex_matchExp(:,1),sss_matchExp_s1(:,1)]),pcc_offline_matchExp(:,1));
% pcc_offline_matchExp_resi_s1 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_matchExp(:,1),sex_matchExp(:,1),sss_matchExp_s2(:,1)]),pcc_offline_matchExp(:,2));
% pcc_offline_matchExp_resi_s2 = st.resid + beta(1);
% 
% 
% [beta,~,st] = glmfit(zscore([age_cont(:,1),sex_cont(:,1),sss_cont_s1(:,1)]),mean(pcc_online_cont(:,1:3),2));
% pcc_online_cont_resi_s1 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_cont(:,1),sex_cont(:,1),sss_cont_s2(:,1)]),mean(pcc_online_cont(:,4:6),2));
% pcc_online_cont_resi_s2 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_matchExp(:,1),sex_matchExp(:,1),sss_matchExp_s1(:,1)]),mean(pcc_online_matchExp(:,1:3),2));
% pcc_online_matchExp_resi_s1 = st.resid + beta(1);
% 
% [beta,~,st] = glmfit(zscore([age_matchExp(:,1),sex_matchExp(:,1),sss_matchExp_s2(:,1)]),mean(pcc_online_matchExp(:,4:6),2));
% pcc_online_matchExp_resi_s2 = st.resid + beta(1);
% 
% 
% 
% [rho_on1,pval_on1] = corr(pcc_offline_matchExp_resi_s1,pcc_offline_cont_resi_s1);
% [rho_on2,pval_on2] = corr(pcc_offline_matchExp_resi_s2,pcc_offline_cont_resi_s2);
% 
% [rho_off1,pval_off1] = corr(pcc_online_matchExp_resi_s1,pcc_online_cont_resi_s1);
% [rho_off2,pval_off2] = corr(pcc_online_matchExp_resi_s2,pcc_online_cont_resi_s2);

%% Scatter plot

f = figure();
set(f,'Position',[300 800 500 400],'Color','w');
font = 40;

x = pcc_on_mean1;
y = pcc_off_mean1;

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval

[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);

patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
      [0.8 0.8 0.8],'EdgeColor','None','FaceAlpha',0.5);
hold on;
line(x,y_fit,'color',[0,0,0],'LineWidth',2);
scatter(x,y,50,[0.3 0.3 0.3],'filled'); hold on;
ax = gca;

% xlabel({'ONLINE PCC', 'mean percent signal change'});
% ylabel({'OFFLINE PCC','mean activation'});

xlabel({''});
ylabel({''});

ax.FontSize = font;
set(gca,'linewidth',5)

%% Scatter plot

f = figure();
set(f,'Position',[300 800 500 400],'Color','w');

x = pcc_on_mean2;
y = pcc_off_mean2;

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval

[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);

patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
      [0.8 0.8 0.8],'EdgeColor','None','FaceAlpha',0.5);
hold on;
line(x,y_fit,'color',[0,0,0],'LineWidth',2);
scatter(x,y,50,[0.3 0.3 0.3],'filled'); hold on;
ax = gca;

% xlabel({'ONLINE PCC', 'mean percent signal change'});
% ylabel({'OFFLINE PCC','mean activation'});

xlabel({''});
ylabel({''});

ax.FontSize = font;
set(gca,'linewidth',5)

