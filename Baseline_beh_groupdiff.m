clear
close all
root_dir = '/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results';
addpath(genpath('/Applications/Academic_Material/PhD/Main_experiment/UPDATED_code_data_results/frank-pk-DataViz-3.2.3.0'));

%%
e_sublist = sort([7;8;12;13;15;20;22;24;30;32;34;36;39;42;45;46;47;52;53;54]);
c_sublist = sort([9;10;16;18;19;27;28;29;31;35;37;38;40;44;48;49;50;51;55;57]);

sublist = sort([e_sublist;c_sublist]);

%% Loading

direc = dir([root_dir '/Data/Behavioral/Baseline']);

for i=3:length(direc)
    load([direc(i).folder '/' direc(i).name]);
end

[~,~,inds2] = intersect(sublist,age(:,end-1),'stable');
age = age(inds2,:);

[~,~,inds2] = intersect(sublist,sex(:,end-1),'stable');
sex = sex(inds2,:);

[~,~,inds2] = intersect(sublist,staiT(:,end-1),'stable');
stai = staiT(inds2,:);

[~,~,inds2] = intersect(sublist,ffmq_odaNjNrT(:,end-1),'stable');
ffmq = ffmq_odaNjNrT(inds2,:);

[~,~,inds2] = intersect(sublist,mwq(:,end-1),'stable');
mwq = mwq(inds2,:);

[~,~,inds2] = intersect(sublist,medex(:,end-1),'stable');
medex = medex(inds2,:);

[~,~,inds2] = intersect(sublist,psqi(:,end-1),'stable');
psqi = psqi(inds2,:);

[~,exp_inds,~] = intersect(sublist,e_sublist);
group = zeros(length(sublist),1);
group(exp_inds) = 1;
cont_inds = find(~group);

%% dass 
[dass_sublist,~,inds2] = intersect(das_bl(:,end-1),sublist,'stable');
group_dass = group(inds2,:);
exp_inds_dass = find(group_dass);
cont_inds_dass = find(~group_dass);

dass_total = mean(das_bl(:,1:3),2);
das_bl = [das_bl(:,1:3),dass_total,das_bl(:,end-1:end)];

%% bct
[bct_sublist,~,inds2] = intersect(bct_acc_bl(:,end),sublist,'stable');
group_bct = group(inds2,:);
exp_inds_bct = find(group_bct);
cont_inds_bct = find(~group_bct);

ffmq_for_bct = ffmq(inds2,:);

bct_validate = isequal(ffmq_for_bct(:,end-1),bct_acc_bl(:,end))
[rho,pval] = corr(ffmq_for_bct(:,1:6),bct_acc_bl(:,1));

%% Checking sub order in all
sub_order_check = isequal(age(:,end-1),sex(:,end-1),...
    ffmq(:,end-1),...
    psqi(:,end-1),mwq(:,end-1),stai(:,end-1),...
    medex(:,end-1),sublist)


%% Group differences

[~,p_age,~,stats_age] = ttest2(age(exp_inds,1),age(cont_inds,1));

[~,p_medex,~,stats_medex] = ttest2(medex(exp_inds,1),medex(cont_inds,1));

[~,p_mwq,~,stats_mwq] = ttest2(mwq(exp_inds,1),mwq(cont_inds,1));

[~,p_psqi,~,stats_psqi] = ttest2(psqi(exp_inds,1),psqi(cont_inds,1));

[~,p_stai,~,stats_stai] = ttest2(stai(exp_inds,1),stai(cont_inds,1));

for i=1:6
    [~,p_ffmq(i,1),~,stats_ffmq(i,:)] = ttest2(ffmq(exp_inds,i),ffmq(cont_inds,i));
end

for i = 1:4
    [~,p_dass(i,1),~,stats_dass(i,:)] = ttest2(das_bl(exp_inds_dass,i),das_bl(cont_inds_dass,i));
end

[~,p_bct,~,stats_bct] = ttest2(bct_acc_bl(exp_inds_bct,1),bct_acc_bl(cont_inds_bct,1));

fem_exp = size(find(sex(exp_inds,1)),1);
fem_cont = size(find(sex(cont_inds,1)),1);


