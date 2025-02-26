#!/bin/bash
RESUME=" -resume"

# Display help
function HELP {
    echo -e \\n"\e[95mHelp documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
    echo -e "${REV}Function:${NORM} This script runs the nexflow pipeline."\\n
    echo -e "Command line switches are optional. The following switches are recognized."
    echo -e "${REV}-s${NORM}  --scratch the nextflow pipelien without -resume so from scratch"
    echo -e "${REV}-h${NORM}  --Displays this help message."\\n
    exit 1
}

while getopts :sh FLAG; do
    case $FLAG in
	s) # start from scrath othrwise resume
	    RESUME=''
	    ;;
	h) # Help
	    HELP
	    ;;
	\?) # Unrecognized option - show help
	    echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
	    HELP
	    ;;
    esac
done

wdir=/path/to/working/directory/				## change : Your working directory
proj="example"  						## change : Your project name inside of Quotation Marks
run="example_run1"						## change : Descriptive name for this specific run inside of Quotation Marks
dt=$(date '+%Y_%m_%d_%H_%M_%S');
nf_runname="${proj}_${run}_${dt}"
workdir="${wdir}${proj}/${run}/work"
resultdir="${wdir}${proj}/${run}/result"
scratchdir="${wdir}${proj}/${run}/scratch"

### set up cache/tmp locations ### 

mkdir -p $scratchdir/.singularity
mkdir -p $scratchdir/.singularity/tmp
mkdir -p $scratchdir/.singularity/localcache
mkdir -p $scratchdir/.singularity/pull

### bind directories between the host system and the container ### 

export SINGULARITY_CACHEDIR=$scratchdir/.singularity
export SINGULARITY_TMPDIR=$SINGULARITY_CACHEDIR/tmp
export SINGULARITY_LOCALCACHEDIR=$SINGULARITY_CACHEDIR/localcache
export SINGULARITY_PULLFOLDER=$SINGULARITY_CACHEDIR/pull
export SINGULARITY_BINDPATH="$SINGULARITY_TMPDIR:/tmp"

echo $nf_runname

### run nextflow ####

nextflow run nf-core/rnaseq \
	-r 3.12.0 \
	-profile singularity \
	--input example_DesignFile.csv \
	--singularity_pull_docker_container \
	-name $nf_runname \
	-params-file example_nf-params.json \
	-w $workdir \
	--outdir $resultdir \
	$RESUME

### remove environment variables ###

unset SINGULARITY_CACHEDIR
unset SINGULARITY_TMPDIR
unset SINGULARITY_LOCALCACHEDIR
unset SINGULARITY_PULLFOLDER
unset SINGULARITY_BINDPATH

### validate bam files ###  

mkdir -p "${resultdir}/star_salmon/picard_validatesamfile" 
samtools quickcheck -v *.bam > "${resultdir}/star_salmon/picard_validatesamfile/bad_bams.fofn"   && echo "all ok" || echo "some files failed check, see bad_bams.fofn" 

find "${resultdir}/star_salmon" -name "*bam"  | xargs -I {} java -jar /path/to/Picard/picard.jar ValidateSamFile -I {} -MODE SUMMARY |& tee "${resultdir}/star_salmon/picard_validatesamfile/bam_summary.txt" 
grep -E "INPUT|ERROR:|WARNING:" "${resultdir}/star_salmon/picard_validatesamfile/bam_summary.txt" | cut -d " " -f 9 | cut -d "/" -f 11 > "${resultdir}/star_salmon/picard_validatesamfile/error_messages.txt" 

echo "Bam file validation process is completed:" 
echo "cd ${resultdir}/star_salmon/picard_validatesamfile" 