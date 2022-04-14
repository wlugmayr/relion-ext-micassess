#!/bin/bash
#
# Written by Wolfgang Lugmayr <wolfgang.lugmayr@cssb-hamburg.de>
#
# You may use this software as allowed by the 2-Clause BSD License
# https://opensource.org/licenses/BSD-2-Clause
#
#SBATCH --partition cssbgpu,allgpu
#SBATCH --time 1-00:00
#SBATCH --constraint GPUx1
#SBATCH --cpus-per-task 1
#SBATCH --error run.err
#SBATCH --output run.out
#SBATCH --job-name rem_mica
unset LD_PRELOAD

#-----------------------------------------------------------
print_help() {
    echo
    echo "$(basename $1) - Relion micrograph assessment external job wrapper"
    echo
    echo "usage: $(basename $1) args"
    echo "  --o             jobdir"
    echo "  --mdir          the directoy containing the models"
    echo "  --help          give this help"
    echo "  --version       show version number"
    echo
}

# default values
HELP=0

# print help
if [ $# -eq 0 ]; then
    HELP=1
fi
# parse args
while [ $# -gt 0 ] ; do
    case $1 in
    	-i | --i) INPUT_STAR="$2" ;;
        -o | --o) DIR="$2" ;;
        -m | --mdir) MDIR="$2" ;;
        -h | --help) HELP=1 ;;
        -v | --version) echo "$(basename $0) 1.0"; exit 4 ;;
    esac
    shift
done
if [ ${HELP} -eq 1 ]; then
    print_help $0
    exit 4
fi

# run the job
echo "### start : $(date)  ###"
echo "### master: $(hostname)  ###"
echo "### jobid : ${SLURM_JOB_ID}  ###"
source /beegfs/cssb/software/spack/share/spack/setup-env.sh
source $(spack location -i environment-modules)/init/profile.sh
module purge
module load micassess/1.0.0
# we need relion_star_printtable
module load relion

# run micassess
micassess -d K3 -m ${MDIR} -i ${INPUT_STAR}

# make a list of files for storage cleanup and helpers
rm -f *.tmp
for i in $(cat micnames.txt); do echo $(basename $i) >>input.tmp; done
sort input.tmp >input_sorted.tmp
relion_star_printtable micrographs_micassess_good.star data_ rlnMicrographName >micgood.tmp
for i in $(cat micgood.tmp); do echo $(basename $i) >>good.tmp; done
sort good.tmp >good_sorted.tmp
diff input_sorted.tmp good_sorted.tmp | grep '<' | cut -c3- >micrographs_to_remove.txt
cat micrographs_to_remove.txt | sed -e "s/.mrc/.tiff/g" >movies_to_remove.txt
cp micrographs_motioncorrected.star micrographs_micassessed.star
for i in $(cat micrographs_to_remove.txt); do
	grep -v $i micrographs_micassessed.star >micrographs_micassessed.tmp
	mv micrographs_micassessed.tmp micrographs_micassessed.star
done
rm *.tmp

# print useful output files
echo "MicAssess: see the result preview images in: ${DIR}/MicAssess" >>note.txt
echo "MicAssess: consider to delete the movies in: ${DIR}/movies_to_remove.txt to save disk space" >>note.txt
echo "MicAssess: consider to use: ${DIR}/micrographs_micassessed.star for the next analysis steps" >>note.txt
echo " ++++" >>note.txt
echo "#####################################"
echo "MicAssess: see the result preview images in: ${DIR}/MicAssess"
echo "MicAssess: consider to delete the movies in: ${DIR}/movies_to_remove.txt to save disk space"
echo "MicAssess: consider to use: ${DIR}/micrographs_micassessed.star for the next analysis steps"

touch RELION_JOB_EXIT_SUCCESS

echo "### end: $(date)  ###"

