Key scripts used in offline analysis of fMRI data from fMRI NF-guided meditation training

1) Online_conf_PSC_groupdiff --> Group difference in the signal from the proxy confound roi used online during NF
2) PCC_offline_groupdiff --> Group difference in PCC signal
3) PCC_online_offline_corr --> Correlation between online denoised and offline denoised PCC signals
4) Transfer_FC_groupdiffD2 --> Group difference in the change in FC from baseline to transfer meditation between PCC and the gPPI cluster (DLPFC) on NF day 2
5) bids_conversion --> BIDSification of fMRI data
6) fMRI_NuisanceRegressors --> Estimation of all nuisance regressors for offline denoising of fMRI data
7) fmriprep_batch_med --> Preprocessing commands from fmriprep used for baseline and transfer meditation fMRI data
8) fmriprep_batch_nf --> Preprocessing commands from fmriprep used for NF-guided meditation fMRI data
9) palm_gppi_groupdiff --> Group difference in voxel-wise gPPI seeded at PCC
