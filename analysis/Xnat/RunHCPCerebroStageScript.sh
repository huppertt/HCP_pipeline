#!/bin/bash
export project=$1
export subjid=$2
export stage=$3
export queue=$4

export tmpdir=/disk/HCP/tmp/${USER}/slurmlogs
mkdir -p ${tmpdir}

export tmpsh=${tmpdir}/slurmjob_$(date +%F).sh
export outfile=${tmpdir}/slurmjob_$(date +%F)_srun.log
export runfile=${tmpdir}/slurmjob_$(date +%F)_srun.sh

export folder=/disk/sulcus/analyzed/${project}
mkdir -p ${folder}/${subjid}

export cmd=`echo "HCP_runall('${subjid}',${stage},'${folder}');"`

echo ${queue}

echo '#!/bin/sh' >>${runfile}

export name=${subjid}_${stage}
export email=huppertt@upmc.edu


if [ "$queue" == "local" ] ; then 
    echo -n "/usr/local/bin/matlab -nosplash -nodesktop -nojvm -nodisplay -r \"try;">>${runfile}
    echo -n "path(path,'/disk/HCP/pipeline/analysis'); HCP_matlab_setenv; ${cmd}; catch; disp(lasterr); end; exit;\"">>${runfile}
    source $runfile>>$outfile
else
    echo -n "/home/pkg/`hostname`/MATLAB/R2014a/bin/matlab -nosplash -nodesktop -nojvm -nodisplay -r \"try;">>${runfile}
    echo -n "path(path,'/disk/HCP/pipeline/analysis'); HCP_matlab_setenv; ${cmd}; catch; disp(lasterr); end; exit;\"">>${runfile}
    echo "#!/bin/bash" >>${tmpsh}
    echo "#SBATCH --mail-type=end" >>${tmpsh}
    echo "#SBATCH --job-name=${name}" >>${tmpsh}
    echo "#SBATCH --mail-user=${email}" >>${tmpsh}
    echo "srun --partition=${queue} -Q -o ${outfile} ${runfile}" >>${tmpsh}
    sbatch --share ${tmpsh}
fi
