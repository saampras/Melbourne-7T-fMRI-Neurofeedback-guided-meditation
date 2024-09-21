#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=00:45:00
#SBATCH --job-name=bids
#SBATCH --mem=6G
#SBATCH -o bids_%a.out
#SBATCH -e bids_%a.error
#SBATCH --partition=cascade
#SBATCH --array=2,4-39
# mail alert at abortion of execution
#SBATCH --mail-type=FAIL

# send mail to this address
#SBATCH --mail-user=saamprasg@student.unimelb.edu.au

root_data_dir=$'/scratch/punim0801/NF_Meditation'
root_tool_dir=$'/home/saampras/punim0801/Toolboxes'

module load GCCcore/11.3.0
module load Python/3.10.4
module load dcm2niix/1.0.20230411

SUB_pp=`sed -n -e "${SLURM_ARRAY_TASK_ID}p" ${root_data_dir}/sub_pp_ids.txt`
SUB_daris=`sed -n -e "${SLURM_ARRAY_TASK_ID}p" ${root_data_dir}/sub_daris_ids.txt`

echo "pp num = $SUB_pp"
echo "daris num = $SUB_daris"

#Separate slurm scripts for .11(pp44, array no. 1) and .20(pp8, array no. 3)
#For array no. 1 - .2 and .3
#For array no. 3 - .3 and .2

for d in {1..2}
do

#creating subfolder inside sourcedata
mkdir -p ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}

#moving dicom data into bids dir 
echo "mv ${root_data_dir}/1.7.127/${SUB_daris}/${SUB_daris}.1/${SUB_daris}.1.${d}/dicom_series/* ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/"
mv ${root_data_dir}/1.7.127/${SUB_daris}/${SUB_daris}.1/${SUB_daris}.1.${d}/dicom_series/* ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/

#helper command - to generate nift files and json files from dicom headers
echo "${root_tool_dir}/dcm2bids_helper -d ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/ -o ${root_data_dir}/bids_data_dir/tmp_dcm2bids/helper/sub${SUB_pp}_D${d}/ --force"
${root_tool_dir}/dcm2bids_helper -d ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/ -o ${root_data_dir}/bids_data_dir/tmp_dcm2bids/helper/sub${SUB_pp}_D${d}/ --force

#dcm2bids for each folder
echo "${root_tool_dir}/dcm2bids -d ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/ -p ${SUB_pp} -s "d${d}" -c ${root_data_dir}/bids_data_dir/code/dcm2bids_config.json -o ${root_data_dir}/bids_data_dir/ --auto_extract_entities --force_dcm2bids --clobber"
${root_tool_dir}/dcm2bids -d ${root_data_dir}/bids_data_dir/sourcedata/sub${SUB_pp}_D${d}/ -p ${SUB_pp} -s "d${d}" -c ${root_data_dir}/bids_data_dir/code/dcm2bids_config.json -o ${root_data_dir}/bids_data_dir/ --auto_extract_entities --force_dcm2bids --clobber

#Adding the IntendedFor field in the sbref and fmap jsons using the correct format
json_dir="${root_data_dir}/bids_data_dir/sub-${SUB_pp}/ses-d${d}"
echo ${json_dir}

path_med1=$"ses-d${d}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-01_bold.nii.gz"
path_med2=$"ses-d${d}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-02_bold.nii.gz"
path_nf1=$"ses-d${d}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-01_bold.nii.gz"
path_nf2=$"ses-d${d}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-02_bold.nii.gz"
path_nf3=$"ses-d${d}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-03_bold.nii.gz"


#fmap files
tmp=$(mktemp)
jq --arg var1 ${path_med1} --arg var2 ${path_med2} --arg var3 ${path_nf1} --arg var4 ${path_nf2} --arg var5 ${path_nf3} '.IntendedFor = [$var1,$var2,$var3,$var4,$var5]' ${json_dir}/fmap/sub-${SUB_pp}_ses-d${d}_dir-AP_epi.json > "$tmp" && mv "$tmp" ${json_dir}/fmap/sub-${SUB_pp}_ses-d${d}_dir-AP_epi.json

tmp=$(mktemp)
jq --arg var1 ${path_med1} --arg var2 ${path_med2} --arg var3 ${path_nf1} --arg var4 ${path_nf2} --arg var5 ${path_nf3} '.IntendedFor = [$var1,$var2,$var3,$var4,$var5]' ${json_dir}/fmap/sub-${SUB_pp}_ses-d${d}_dir-PA_epi.json > "$tmp" && mv "$tmp" ${json_dir}/fmap/sub-${SUB_pp}_ses-d${d}_dir-PA_epi.json

#Sbref files
tmp=$(mktemp)
jq --arg var ${path_med1} '.IntendedFor = $var' ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-01_sbref.json > "$tmp" && mv "$tmp" ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-01_sbref.json

tmp=$(mktemp)
jq --arg var ${path_med2} '.IntendedFor = $var' ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-02_sbref.json > "$tmp" && mv "$tmp" ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-med_dir-PA_run-02_sbref.json

tmp=$(mktemp)
jq --arg var ${path_nf1} '.IntendedFor = $var' ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-01_sbref.json > "$tmp" && mv "$tmp" ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-01_sbref.json

tmp=$(mktemp)
jq --arg var ${path_nf2} '.IntendedFor = $var' ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-02_sbref.json > "$tmp" && mv "$tmp" ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-02_sbref.json

tmp=$(mktemp)
jq --arg var ${path_nf3} '.IntendedFor = $var' ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-03_sbref.json > "$tmp" && mv "$tmp" ${json_dir}/func/sub-${SUB_pp}_ses-d${d}_task-nf_dir-PA_run-03_sbref.json

echo "Completed Day ${d}"

done


