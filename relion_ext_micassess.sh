#!/bin/bash
#
# Written by Wolfgang Lugmayr <wolfgang.lugmayr@cssb-hamburg.de>
#
# You may use this software as allowed by the 2-Clause BSD License
# https://opensource.org/licenses/BSD-2-Clause
#

#-----------------------------------------------------------
print_help() {
    echo
    echo "$(basename $1) - Relion micrograph assessment external job wrapper"
    echo
    echo "usage: $(basename $1) args"
    echo "  --o             jobdir"
    echo "  --in_mics       MotionCorr/job???/corrected_micrographs.star"
    echo "  --help          give this help"
    echo "  --version       show version number"
    echo
}

#-----------------------------------------------------------
check_file() {
    if [ ! -f ${1} ]; then
        echo "ERROR: ${1} does not exist"
        exit 1
    fi
}
check_dir() {
    if [ ! -d ${1} ]; then
        echo "ERROR: ${1} does not exist or is no directory"
        exit 1
    fi
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
        -o | --o) DIR="$2" ;;
        -i | --in_mics) IN_MICS_STAR="$2" ;;
        -h | --help) HELP=1 ;;
        -v | --version) echo "$(basename $0) 1.0"; exit 4 ;;
    esac
    shift
done
if [ ${HELP} -eq 1 ]; then
    print_help $0
    exit 4
fi

# prepare job
echo "preparing input movies"
cd ${DIR}
PREFIX=../..
cp ${PREFIX}/${IN_MICS_STAR} micrographs_motioncorrected.star
relion_star_printtable ${PREFIX}/${IN_MICS_STAR} data_micrographs _rlnMicrographName >micnames.txt
MDIR=$(basename $(dirname $(head -1 micnames.txt)))
mkdir -p ${MDIR}
cd ${MDIR}
for f in $(cat ../micnames.txt); do
    cp -sn ${PREFIX}/../$f .
done
cd ..

# preparing list of micrograph names for micassess
INPUT_STAR=micrographs_micassess.star
echo -e "data_\nloop_\n_rlnMicrographName" >${INPUT_STAR}
/usr/bin/ls -1 ${MDIR}/*.mrc >>${INPUT_STAR}

# check, document and run job
echo "checking file ${REM_MICASSESS_SCRIPT}"
check_file ${REM_MICASSESS_SCRIPT}
echo "checking models directory ${REM_MICASSESS_MODELS}"
check_dir ${REM_MICASSESS_MODELS}

echo ${REM_MICASSESS_SCRIPT} --i ${INPUT_STAR} --o ${DIR} --mdir ${REM_MICASSESS_MODELS} >>note.txt
if [ -z ${REM_MICASSESS_SUBMIT} ]; then
	bash ${REM_MICASSESS_SCRIPT} --i ${INPUT_STAR} --o ${DIR} --mdir ${REM_MICASSESS_MODELS}
else
	${REM_MICASSESS_SUBMIT} ${REM_MICASSESS_SCRIPT} --i ${INPUT_STAR} --o ${DIR} --mdir ${REM_MICASSESS_MODELS}
fi


