
clear
root_dir = '/data/scratch/projects/punim0801/NF_Meditation';
addpath(genpath([root_dir '/Code']));

sublist = importdata([root_dir '/sub_pp_ids_rem2.txt']);

problematic = [];
task = {'med';'nf'};
%[task,day,run]
run_ids = [[1:10]',[111;211;212;213;112;121;221;222;223;122]];

tic;
rank_def = [];

for sub = 1:length(sublist)
    mkdir([root_dir '/Nuisance_EVs/sub-' num2str(sublist(sub))]);
    for t = 2:2
        if t==1
            runs = 2; %med
        else
            runs = 3; %nf
        end
        for d=2:2
            for r = 1:1
                formatSpec = 'Subject %d, Day %d, task %s, run %d \n';
                fprintf(formatSpec,sublist(sub),d,task{t},r);
                nuisance_regs = [];

                try
                    fmriprep_path = [root_dir '/bids_data_dir/derivatives/sub-' ...
                        num2str(sublist(sub)) '/ses-d' num2str(d) '/func'];
                    physio_path = [root_dir '/Physio_EVs/physIO/sub-' num2str(sublist(sub))];

                    %% Phys IO
                    %All Physio regressors are entered first
                    id = find(run_ids(:,2) == str2double([num2str(t) num2str(d) num2str(r)]));
                    phys_run = run_ids(id,1);
                    nuisance_regs = importdata([physio_path '/R_regressors_sub-' ...
                        num2str(sublist(sub)) '_run-' num2str(phys_run) '.txt']);


                    %% fmriprep
                    fmriprep_confounds = tsvread([fmriprep_path '/sub-' ...
                        num2str(sublist(sub)) '_ses-d' num2str(d) ...
                        '_task-' task{t} '_dir-PA_run-0' num2str(r) ...
                        '_desc-confounds_timeseries.tsv']);
                    confound_fields = fieldnames(fmriprep_confounds);
                    confound_cellarr = struct2cell(fmriprep_confounds);
                    num_vols = length(confound_cellarr{1});

                    %% Adding top 5 acompcor regressors to regressor set
                    acomp_ind = find(contains(confound_fields,'a_comp_cor'));
                    acomp5_ind = acomp_ind(1:5);

                    acomp5_regs = reshape(cell2mat(confound_cellarr(acomp5_ind)),...
                        [num_vols length(acomp5_ind)]);
                    acomp5_regs(isnan(acomp5_regs)) = 0;
                    nuisance_regs = [nuisance_regs,acomp5_regs];

                    %% Adding 24-motion regressors to regressor set
                    trans_ind = find(contains(confound_fields,'trans'));
                    rot_ind = find(contains(confound_fields,'rot'));
                    motion_ind = [trans_ind;rot_ind];
                    %motion_ind([3,4,7,8,11,12,15,16,19,20,23,24]) = [];%for 12-motion regressors
                    %motion_ind([3,7,11,15,19,23]) = [];%for 18-motion regressors
                    %motion_ind([4,8,12,16,20,24]) = [];%for 18-motion regressors

                    motion_regs = reshape(cell2mat(confound_cellarr(motion_ind)),...
                        [num_vols length(motion_ind)]);
                    motion_regs(isnan(motion_regs)) = 0;
                    nuisance_regs = [nuisance_regs,motion_regs];

                    %% Adding cosine signals for high-pass filtering
                    cos_ind = find(contains(confound_fields,'cosine'));
                    cos_regs = reshape(cell2mat(confound_cellarr(cos_ind)),...
                        [num_vols length(cos_ind)]);
                    cos_regs(isnan(cos_regs)) = 0;
                    nuisance_regs = [nuisance_regs,cos_regs];

                    %% Adding non-steady state volume regressors
                    nss_ind = find(contains(confound_fields,'non_steady_state'));
                    nss_regs = reshape(cell2mat(confound_cellarr(nss_ind)),...
                        [num_vols length(nss_ind)]);
                    nss_regs(isnan(nss_regs)) = 0;
                    nuisance_regs = [nuisance_regs,nss_regs];

                    %% saving
                    savepath = [root_dir '/Nuisance_EVs/sub-' num2str(sublist(sub)) ...
                        '/sub-' num2str(sublist(sub)) '_ses-d' num2str(d) ...
                        '_task-' task{t} '_run-0' num2str(r) '_nuisance_regresors.txt'];
                    writematrix(nuisance_regs,savepath,'Delimiter','tab');
                    %checking rank deficiency
                    rank_def = [rank_def;sub,t,d,r,(rank(nuisance_regs)<size(nuisance_regs,2))]; 
                    %writematrix(nuisance_regs,'test.txt','Delimiter','tab');

                catch
                     problematic = [problematic;sub,t,d,r];
                end
            end
        end
    end
end


toc;
%Subject 38 (id 24) day 2 nf run 1 has 709 instead of 710 vols in fmriprep
%confounds file, as well as actual data

%Subject 36 (id 22) day 2 nf run 1 has 205 instead of 710 vols in fmriprep
%confounds file, but actual data is fine
