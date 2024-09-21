#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=3
#SBATCH --time=08:00:00
#SBATCH --job-name=NF_fmriprep
#SBATCH --mem=50G
#SBATCH -o nf_%a.out
#SBATCH -e nf_%a.error
#SBATCH --partition=cascade
#SBATCH --array=1-39
# mail alert at abortion of execution
#SBATCH --mail-type=FAIL

# send mail to this address
#SBATCH --mail-user=saamprasg@student.unimelb.edu.au
#usual full set time is 30 hours and mem is 60G
root_dir=$'/scratch/punim0801/NF_Meditation'

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

#apptainer run -B "${root_dir}":"${root_dir}" --cleanenv "${root_dir}/fMRIprep/fmriprep_23.2.1.sif" "${root_dir}/bids_data_dir" "${root_dir}/bids_data_dir/derivatives" --ignore slicetiming --mem_mb 60000 participant --task-id nf --participant-label "${SUBJECT_pp}" --fs-license-file "${root_dir}/fMRIprep/license.txt" --output-spaces MNI152NLin2009cAsym:res-2 --longitudinal --stop-on-first-crash --use-syn-sdc --cifti-output --work-dir /tmp/
apptainer run -B "${root_dir}":"${root_dir}" --cleanenv "${root_dir}/fMRIprep/fmriprep_23.2.1.sif" "${root_dir}/bids_data_dir" "${root_dir}/bids_data_dir/derivatives" --ignore slicetiming --mem_mb 50000 participant --task-id nf --participant-label "${SUBJECT_pp}" --fs-license-file "${root_dir}/fMRIprep/license.txt" --output-spaces MNI152NLin2009cAsym:res-2 --longitudinal --stop-on-first-crash --use-syn-sdc --work-dir /tmp/

echo "Completed ..."
