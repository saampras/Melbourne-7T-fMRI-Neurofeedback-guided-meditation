#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3
#SBATCH --time=30:00:00
#SBATCH --job-name=Med_fmriprep
#SBATCH --mem=50G
#SBATCH -o med_%a.out
#SBATCH -e med_%a.error
#SBATCH --partition=cascade
#SBATCH --array=1-39
# mail alert at abortion of execution
#SBATCH --mail-type=FAIL

# send mail to this address
#SBATCH --mail-user=saamprasg@student.unimelb.edu.au

root_dir=$'/scratch/punim0801/NF_Meditation'
#2,3,5,14,21,26,28,32,38
date
echo $root_dir
echo $SLURM_JOB_NAME
echo $SLURM_ARRAY_TASK_ID

module load GCCcore/11.3.0
module load Apptainer/1.2.3


SUBJECT_pp=`sed -n -e "${SLURM_ARRAY_TASK_ID}p" ${root_dir}/sub_pp_ids.txt`

echo "subject ID pp: " ${SUBJECT_pp}

# launch processing for each subject
export APPTAINERENV_TEMPLATEFLOW_HOME="$HOME/.cache/templateflow"  # Tell fMRIPrep the mount point

echo "Starting ..."

#apptainer run -B "${root_dir}":"${root_dir}" --cleanenv "${root_dir}/fMRIprep/fmriprep_23.2.1.sif" "${root_dir}/bids_data_dir" "${root_dir}/bids_data_dir/derivatives" --ignore {slicetiming,fieldmaps} --mem_mb 80000 participant --task-id med --participant-label "${SUBJECT_pp}" --fs-license-file "${root_dir}/fMRIprep/license.txt" --output-spaces MNI152NLin2009cAsym:res-2 --longitudinal --stop-on-first-crash --use-syn-sdc --work-dir /tmp/
apptainer run -B "${root_dir}":"${root_dir}" --cleanenv "${root_dir}/fMRIprep/fmriprep_23.2.1.sif" "${root_dir}/bids_data_dir" "${root_dir}/bids_data_dir/derivatives" --ignore {slicetiming,fmap-jacobian} --mem_mb 50000 participant --task-id med --participant-label "${SUBJECT_pp}" --fs-license-file "${root_dir}/fMRIprep/license.txt" --output-spaces MNI152NLin2009cAsym:res-2 --longitudinal --stop-on-first-crash --use-syn-sdc --work-dir /tmp/

echo "Completed ..."
