%Correlations between the day 2 PCC-DLPFC functional decoupling and the behavioural outcomes (SMS-Mind, BCT and DASS)

clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));


%neural analysis sublist
sublist_init = importdata([root_dir '/Data/Neural/sub_pp_ids_rem2.txt']);

e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);

subs_excl = [];
[~,excl_inds,~] = intersect(sublist_init,subs_excl);


%%
FC_initial = importdata([root_dir '/Data/Neural/FC_pcc_dlpfc_r1r5r6r10.mat']);
FC = [reshape(FC_initial(:,1),length(sublist_init),4),sublist_init];
FC(excl_inds,:) = [];
sublist = sublist_init;
sublist(excl_inds) = []; 


%% Loading 

dass1 = importdata([root_dir '/Data/Behavioral/DASS/das_bl.mat']);
dass2 = importdata([root_dir '/Data/Behavioral/DASS/das_fu.mat']);
lin_smsslope = importdata([root_dir '/Data/Behavioral/sms_sss_5min_meditation/lin_slope_smsmind.mat']);

sss_nf = importdata([root_dir '/Data/Behavioral/sms_sss_mri/mri_sss_nf.mat']);
age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

ppi_betas_d1 = load([root_dir '/Data/Neural/gPPI_day2/betas/dlpfc_betas_d1.txt']);
ppi_betas_d2 = load([root_dir '/Data/Neural/gPPI_day2/betas/dlpfc_betas_d2.txt']);
ppi_betas = [ppi_betas_d1,ppi_betas_d2,sublist];

bct_acc = importdata([root_dir '/Data/Behavioral/BCT/bct_acc.mat']);

%% Reorganizing

[final_sublist,~,inds_d] = intersect(sublist,dass1(:,end-1),'stable');
dass1 = dass1(inds_d,:);
dass2 = dass2(inds_d,:);

[~,~,inds2] = intersect(final_sublist,bct_acc(:,end),'stable');
bct_acc = bct_acc(inds2,:);
bct_acc_diff = [bct_acc(:,2) - bct_acc(:,1),bct_acc(:,end)];
%different number of subjects (due to BCT error in 1 pp)

[~,~,inds2] = intersect(final_sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(final_sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,~,inds2] = intersect(final_sublist,FC(:,end),'stable');
FC = FC(inds2,:);

[~,~,inds2] = intersect(final_sublist,sss_nf(:,end-1),'stable');
sss_nf = sss_nf(inds2,:);
sss_nf = [mean(sss_nf(:,1:3),2),mean(sss_nf(:,4:6),2),sss_nf(:,end-1:end)];

[~,~,inds2] = intersect(final_sublist,ppi_betas(:,end),'stable');
ppi_betas = ppi_betas(inds2,:);

[~,~,inds2] = intersect(final_sublist,lin_smsslope(:,end-1),'stable');
lin_smsslope = lin_smsslope(inds2,:);


[~,exp_inds,~] = intersect(final_sublist,e_sublist);
group = zeros(length(final_sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking sub order in all
sub_order_check = isequal(dass1(:,end-1),dass2(:,end-1),...
    FC(:,end),...
    age(:,end),sex(:,end),sss_nf(:,end-1),...
    ppi_betas(:,end),lin_smsslope(:,end-1),...
    final_sublist)

%% Regressing SSS from NF ppi betas

for i=1:2
    [beta,~,st] = glmfit(zscore(sss_nf(:,i)),ppi_betas(:,i));
    ppi_betas_res(:,i) = st.resid + beta(1);
end

fmri_data = ppi_betas_res(:,2)*-1; %Day 2 (-ve for deactivation)
%loaded betas are positive as they belong to rest>med contrast. -ve
%sign will simply flip the contrast here

%% PPI-DASS correlations

dassTot_diff = [mean(dass2(:,1:3),2)-mean(dass1(:,1:3),2),dass1(:,end-1:end)];

%Full sample
[rho_dass,p_dass] = partialcorr(fmri_data,dassTot_diff(:,1),...
    zscore([age(:,1),sex(:,1)])) 

%Post-hoc because of full-sample significance
%Exp
[rho_exp_dass,p_exp_dass] = partialcorr(fmri_data(exp_inds),...
     dassTot_diff(exp_inds,1),...
     zscore([age(exp_inds,1),sex(exp_inds,1)])); 

%Cont
[rho_cont_dass,p_cont_dass] = partialcorr(fmri_data(cont_inds),...
    dassTot_diff(cont_inds,1),...
    zscore([age(cont_inds,1),sex(cont_inds,1)]));

%% PPI-SMS Mind slope correlations

sms_beh = lin_smsslope;
%Full sample
[rho_sms,p_sms] = partialcorr(fmri_data,...
    sms_beh(:,1),...
    zscore([age(:,1),sex(:,1)])) %Not significant


%% PPI-BCT accuracy correlations

[bct_sublist,~,inds2] = intersect(bct_acc_diff(:,end),final_sublist,'stable');
fmri_data_bct = fmri_data(inds2,:)*-1;
bct_exp_inds = find(group(inds2));
bct_cont_inds = find(~group(inds2));
age_bct = age(inds2,:);
sex_bct = sex(inds2,:);

check_order_bct = isequal(bct_acc_diff(:,end),age_bct(:,end),...
    sex_bct(:,end),bct_sublist)

%Full sample
[rho_bct,p_bct] = partialcorr(fmri_data_bct,...
    bct_acc_diff(:,1),...
    zscore([age_bct(:,1),sex_bct(:,1)])) %Not significant


%% Plotting

%% DASS - PPI
f1 = figure();
set(f1,'Position',[300 800 500 400],'Color','w');
text_font = 40;

%Exp
x = dassTot_diff(exp_inds,1);
y = fmri_data(exp_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);

%patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0 0 0.8],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p1 = line(x,y_fit,'LineStyle','--','color',[0,0,0.9],'LineWidth',2.5);
s1 = scatter(x,y,100,[0 0 0.9],'filled'); hold on;
ylabel('');
xlabel('');
ax = gca;
ax.FontSize = text_font;

%Cont
x = dassTot_diff(cont_inds,1);
y = fmri_data(cont_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);
ylabel('');
xlabel('');

% patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0.8 0 0],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p2 = line(x,y_fit,'color',[0.8,0,0],'LineWidth',2.5);
s2 = scatter(x,y,100,[0.9 0 0],'filled'); hold on;

%Full
x = dassTot_diff(:,1);
y = fmri_data(:);

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
      [0.3 0.3 0.3],'EdgeColor','None','FaceAlpha',0.2);
hold on;
p3 = line(x,y_fit,'color',[0,0,0],'LineWidth',2.5);



L = legend([s1,s2],{'EXP','CONT'},'LineWidth',0.1,'FontSize',30);

ax = gca;
ax.FontSize = text_font;
set(gca,'linewidth',5)

%% SMS - PPI

f2 = figure();
set(f2,'Position',[300 800 500 400],'Color','w');

%Exp
x = sms_beh(exp_inds,1);
y = fmri_data(exp_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);

% patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0 0 0.8],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p1 = line(x,y_fit,'color',[0,0,0.8],'LineWidth',2.5);
s1 = scatter(x,y,100,[0 0 0.9],'filled'); hold on;
ylabel('');
xlabel('');
ax = gca;
ax.FontSize = text_font;

%Cont
x = sms_beh(cont_inds,1);
y = fmri_data(cont_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);
ylabel('');
xlabel('');

% patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0.8 0 0],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p2 = line(x,y_fit,'color',[0.8,0,0],'LineWidth',2.5);
s2 = scatter(x,y,100,[0.9 0 0],'filled'); hold on;

%Full
x = sms_beh(:,1);
y = fmri_data;

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
      [0.3 0.3 0.3],'EdgeColor','None','FaceAlpha',0.2);
hold on;
p3 = line(x,y_fit,'color',[0,0,0],'LineWidth',2.5);



L = legend([s1,s2],{'EXP','CONT'},'LineWidth',0.1,'FontSize',30);

ax = gca;
ax.FontSize = text_font;
set(gca,'linewidth',5)

%% BCT - PPI
f3 = figure();
set(f3,'Position',[300 800 500 400],'Color','w');

%Exp
x = bct_acc_diff(bct_exp_inds,1);
y = fmri_data_bct(bct_exp_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);

% patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0 0 0.8],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p1 = line(x,y_fit,'color',[0,0,0.8],'LineWidth',2.5);
s1 = scatter(x,y,100,[0 0 0.9],'filled'); hold on;
ylabel('');
xlabel('');
ax = gca;
ax.FontSize = text_font;

%Cont
x = bct_acc_diff(bct_cont_inds,1);
y = fmri_data_bct(bct_cont_inds);

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);
ylabel('');
xlabel('');

% patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
%       [0.8 0 0],'EdgeColor','None','FaceAlpha',0.1);
hold on;
%p2 = line(x,y_fit,'color',[0.8,0,0],'LineWidth',2.5);
s2 = scatter(x,y,100,[0.9 0 0],'filled'); hold on;

%Full
x = bct_acc_diff(:,1);
y = fmri_data_bct;

nan_idx = isnan(y); %all the NaN indices
[p,S] = polyfit(x(~nan_idx),y(~nan_idx),1);
[y_fit,dy] = polyconf(p,x,S,'alpha',0.05,...
'predopt','curve');%curve option plots confidence interval
[x1_uniq,ind_uniq] = unique(x);
lower = y_fit(ind_uniq)-dy(ind_uniq);
upper = y_fit(ind_uniq)+dy(ind_uniq);
ylabel('');
xlabel('');
xticks([-40:40:60]);
patch([x1_uniq; flipud(x1_uniq)],[lower; flipud(upper)],...
      [0.3 0.3 0.3],'EdgeColor','None','FaceAlpha',0.2);
hold on;
p3 = line(x,y_fit,'color',[0,0,0],'LineWidth',2.5);



L = legend([s1,s2],{'EXP','CONT'},'LineWidth',0.1,'FontSize',30);

ax = gca;
ax.FontSize = text_font;
set(gca,'linewidth',5)
