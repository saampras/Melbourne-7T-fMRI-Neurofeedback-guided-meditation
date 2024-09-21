clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';

addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%% Loading and organizing data 

e_sublist = sort([7;8;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;18;19;27;28;29;31;35;37;38;44;48;49;50;51;55;57]);
sublist = sort([e_sublist;c_sublist]);


%%

direc = dir([root_dir '/Data/Behavioral/sms_sss_5min_meditation']);

for i=3:length(direc)
    load([direc(i).folder '/' direc(i).name]);
end

age = importdata([root_dir '/Data/NeuroBehavioral/age.mat']);
sex = importdata([root_dir '/Data/NeuroBehavioral/gender.mat']);

%% 
[~,~,inds2] = intersect(sublist,post_med_sss(:,end-1),'stable');
post_med_smsbody = post_med_smsbody(inds2,:);
pre_med_smsbody = pre_med_smsbody(inds2,:);
post_med_smsmind = post_med_smsmind(inds2,:);
pre_med_smsmind = pre_med_smsmind(inds2,:);
pre_med_sss = pre_med_sss(inds2,:);
post_med_sss = post_med_sss(inds2,:);

mean_sss = (post_med_sss + pre_med_sss) / 2;

[~,~,inds2] = intersect(sublist,inter_ses_times_med(:,end-1),'stable');
inter_ses_times_med = inter_ses_times_med(inds2,:);
time_intervals = [zeros(size(inter_ses_times_med,1),1),inter_ses_times_med(:,1:end-2)];
for i = 2:6
    time_intervals(:,i) = time_intervals(:,i-1)+time_intervals(:,i);
end

time_intervals = [time_intervals,inter_ses_times_med(:,end-1:end)];
time_intervals2 = time_intervals;
time_intervals2(:,2:6) = time_intervals(:,2:6).^2;

[~,~,inds2] = intersect(sublist,age(:,end),'stable');
age = age(inds2,:);
[~,~,inds2] = intersect(sublist,sex(:,end),'stable');
sex = sex(inds2,:);

[~,exp_inds,~] = intersect(sublist,e_sublist,'stable');
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% Checking subject order in all
sub_order_check = isequal(post_med_smsbody(:,end-1),...
    pre_med_smsbody(:,end-1),post_med_smsmind(:,end-1),...
    pre_med_smsmind(:,end-1),...
    pre_med_sss(:,end-1),...
    post_med_sss(:,end-1),age(:,end),sex(:,end),...
    inter_ses_times_med(:,end-1),sublist)


%% Subject-wise linear slopes over time

%Regressing covariates out from post med sms before calculating slopes
for i=1:6
    [beta,~,st] = glmfit(zscore([mean_sss(:,i),pre_med_smsmind(:,i),age(:,1),sex(:,1)]),post_med_smsmind(:,i));
    post_med_smsmind_cov_removed(:,i) = st.resid + beta(1);
    
    [beta,~,st] = glmfit(zscore([mean_sss(:,i),pre_med_smsbody(:,i),age(:,1),sex(:,1)]),post_med_smsbody(:,i));
    post_med_smsbody_cov_removed(:,i) = st.resid + beta(1);
    
end

% Uncomment if NOT Regressing covariates out from post med sms before calculating slopes
% post_med_smsmind_cov_removed = post_med_smsmind(:,1:6);
% post_med_smsbody_cov_removed = post_med_smsbody(:,1:6);
% post_med_sms_cov_removed = post_med_sms(:,1:6);


for p = 1:length(sublist)   
    x_time = zscore(time_intervals(p,1:end-2)');
    
    x = x_time;
    y_postmed_mind_slope = post_med_smsmind_cov_removed(p,1:end)';
    y_postmed_body_slope = post_med_smsbody_cov_removed(p,1:end)';
    
    [beta_postmed_mind_slope(:,p),~,~] = ...
        glmfit(x,y_postmed_mind_slope,'normal','constant','on');
    
    [beta_postmed_body_slope(:,p),~,~] = ...
        glmfit(x,y_postmed_body_slope,'normal','constant','on'); 
    
end

postmed_mind_slope = [beta_postmed_mind_slope(2,:)',inter_ses_times_med(:,end-1:end)];
postmed_body_slope = [beta_postmed_body_slope(2,:)',inter_ses_times_med(:,end-1:end)];


%% GLM of linear slopes for between-group difference

gr = group;
gr(cont_inds) = -1;

Y_slope_mind = postmed_mind_slope(:,1); 
Y_slope_body = postmed_body_slope(:,1); 
X_subwise = gr;
[~,~,stats_mind] = glmfit(X_subwise,Y_slope_mind,'normal','constant','on');
p_mind_slope = stats_mind.p(2)
cohen_d_mind_slope_grdiff = stats_mind.t(2)/sqrt(stats_mind.dfe)

[~,~,stats_body] = glmfit(X_subwise,Y_slope_body,'normal','constant','on');
p_body_slope = stats_body.p(2)
cohen_d_body_slope_grdiff = stats_body.t(2)/sqrt(stats_body.dfe);


%% Plotting SMS Mind data

f1 = figure();
set(f1,'Position',[100 100 1000 600],'Color','w');
text_font = 40;


xtick_labels = {'BL','App s1','App s2','App s3','App s4','FU'};
x_label = {'','Timepoint'};
x_angle = 45;
yrange = [];
xtick_vals = 1:1:6;
ytick_vals = [];


data = post_med_smsmind_cov_removed(:,1:6);

exp_data = data(exp_inds,:);
cont_data = data(cont_inds,:);

viol_data{1} = exp_data;
viol_data{2} = cont_data;

legend_details = {['exp (N=' num2str(size(exp_data,1)) ')'],...
    ['cont (N=' num2str(size(cont_data,1)) ')']};

title_text = {'5-minute meditation',...
    'state mindfulness of MIND',''};
y_label = {'SMS-Mind scores'};
group_names = {'EXP','CONT'};

h1 = daboxplot(viol_data,'linkline',1,...
    'xtlabels',{''},'legend',group_names,...
    'whiskers',1,'outliers',1,'outsymbol','k>',...
    'scatter',2,'boxalpha',0.6,'jitter',1,'scattersize',75,...
    'mean',1);

xl = xlim; xlim([xl(1), xl(2)]);    % make more space for the legend
set(gca,'FontSize',text_font)
set(h1.ln,'LineWidth',6.5,'LineStyle','-');
set(h1.ot,'LineWidth',1);
set(gca,'linewidth',5)
for i = 1:6
    set(h1.mn(i,1),'LineWidth',4.5,'Color',[0 0 0.8]);
    set(h1.mn(i,2),'LineWidth',4.5,'Color',[0.8 0 0]);
    set(h1.md(i,1),'LineWidth',4.5,'Color',[0 0 0.8]);
    set(h1.md(i,2),'LineWidth',4.5,'Color',[0.8 0 0]);
end
set(h1.ot,'LineWidth',2);
set(h1.lg,'LineWidth',0.05);
set(h1.lg,'FontSize',30);

%Baseline session group difference
[~,p_bldiff_mind,~,stats_bldiff_mind] = ttest2(exp_data(:,1),cont_data(:,1));

%% Plotting SMS Body data

f2 = figure();
set(f2,'Position',[100 100 1000 600],'Color','w');
text_font = 40;

data = post_med_smsbody_cov_removed(:,1:6);

exp_data = data(exp_inds,:);
cont_data = data(cont_inds,:);

viol_data{1} = exp_data;
viol_data{2} = cont_data;

group_names = {'EXP','CONT'};

h2 = daboxplot(viol_data,'linkline',1,...
    'xtlabels',{''},'legend',group_names,...
    'whiskers',1,'outliers',1,'outsymbol','k>',...
    'scatter',2,'boxalpha',0.6,'jitter',1,'scattersize',75,...
    'mean',1);

ylim([min(data(:)),max(data(:))]);
set(gca,'FontSize',text_font)
set(h2.ln,'LineWidth',6.5,'LineStyle','-');
set(h2.ot,'LineWidth',1);
set(gca,'linewidth',5)
for i = 1:6
    set(h2.mn(i,1),'LineWidth',4.5,'Color',[0 0 0.8]);
    set(h2.mn(i,2),'LineWidth',4.5,'Color',[0.8 0 0]);
    set(h2.md(i,1),'LineWidth',4.5,'Color',[0 0 0.8]);
    set(h2.md(i,2),'LineWidth',4.5,'Color',[0.8 0 0]);
end
set(h2.ot,'LineWidth',2);
set(h2.lg,'LineWidth',0.05);
set(h2.lg,'FontSize',30);

%Baseline session group difference
[~,p_bldiff_body,~,stats_bldiff_body] = ttest2(exp_data(:,1),cont_data(:,1));



%% Plotting group difference in slopes of SMS-Mind
f = figure();
set(f,'Position',[300 800 500 400],'Color','w');

text_font = 40;

exp_data = postmed_mind_slope(exp_inds,1); 
cont_data = postmed_mind_slope(cont_inds,1); 

viol_data{1} = exp_data;
viol_data{2} = cont_data;
c =  [0, 0, 1;...
      1, 0, 0];
  
group_names = {'EXP', 'CONT'};

h = daboxplot(viol_data,'outsymbol','k+',...
    'color',c,'fill',1,'outliers',1,...
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

y_label = {''};

ax = gca;
set(gca,'linewidth',5)
ax.FontSize = text_font;
xlabel('');
ylabel('');
xtickangle(x_angle)
xticklabels('');

%% Plotting group difference in slopes of SMS-Body
f = figure();
set(f,'Position',[300 800 500 400],'Color','w');

text_font = 40;
linethickness = 1;


exp_data = postmed_body_slope(exp_inds,1); 
cont_data = postmed_body_slope(cont_inds,1); 

viol_data{1} = exp_data;
viol_data{2} = cont_data;
c =  [0, 0, 1;...
      1, 0, 0];
  
group_names = {'EXP', 'CONT'};

h = daboxplot(viol_data,'outsymbol','k+',...
    'color',c,'fill',1,'outliers',1,...
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

y_label = {''};

ax = gca;
set(gca,'linewidth',5)
ax.FontSize = text_font;
xlabel('');
ylabel('');
xtickangle(x_angle)
xticklabels('');

%% Plotting subject-wise slopes of SMS-Mind
f = figure();
set(f,'Position',[100 100 1000 600],'Color','w');

text_font = 50;
ramp = 1:1:6;

exp_data = postmed_mind_slope(exp_inds,1).*ramp; 
cont_data = postmed_mind_slope(cont_inds,1).*ramp; 

viol_data{1} = exp_data;
viol_data{2} = cont_data;
c =  [0, 0, 1;...
      1, 0, 0];
  
group_names = {'EXP', 'CONT'};

for ei = 1:length(exp_data)
    line(ramp,exp_data(ei,:),'color',[0,0,0.8],'LineWidth',0.5);
    hold on;
end

for ci = 1:length(cont_data)
    line(ramp,cont_data(ci,:),'color',[0.8,0,0],'LineWidth',0.5);
    hold on;
end 

L1 = line(ramp,mean(exp_data,1),'color',[0,0,0.8],'LineWidth',8);
L2 = line(ramp,mean(cont_data,1),'color',[0.8,0,0],'LineWidth',8);
L1.LineStyle = '-.';
L2.LineStyle = '-.';
%legend([L1 L2],group_names)

y_label = {''};

ax = gca;
ax.FontSize = text_font;
xlabel('');
ylabel('');
xtickangle(x_angle)
xticklabels('');
xlim([0 7]);
set(gca,'linewidth',5)

%% Saving SMS-Mind slopes

lin_slope_smsmind = [postmed_mind_slope(:,1),postmed_mind_slope(:,end-1:end)];
savepath1 = [root_dir '/Data/Behavioral/sms_sss_5min_meditation/lin_slope_smsmind.mat'];
save(savepath1,'lin_slope_smsmind');



