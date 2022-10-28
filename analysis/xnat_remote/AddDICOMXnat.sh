#! /bin/bash

if [ -z "$xdc_put" ]; then
    export xdc_put=" -u hcpadmin -p 'hcp22' -m PUT -r "
fi
if [ -z "$xdc_get" ]; then
    export xdc_get=" -u hcpadmin -p 'hcp22' -m GET -r "
fi


if [ -z "$xrem" ]; then
    export xrem="http://10.48.86.212:8080/data/projects/"
fi

export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2
export sess=$3
export scan=$4
export type=$5
export file=$6
export scanfile=$7

export sessiontype="mrSessionData"

eval VAR=\$\($"XnatDataClient $xdc_get ${xrem}${project}/subjects/${subjid}/experiments/${sess}/scans/ | grep ${scan}"\)

if [ -z "$VAR" ]; then
    echo "scan type not found: Creating entry"
    eval thisdir=\$\($"dirname $0"\)
    eval "${thisdir}/CreateScan.sh ${project} ${subjid} ${sess} ${scan} ${type}"
fi

export xrem="${xrem}${project}/subjects/${subjid}/experiments/${sess}/scans/${scan}"


export cmd="XnatDataClient $xdc_put ${xrem}/resources/DICOM/files/${scanfile} -l ${file}"

# create subject
#echo ${cmd}
bash -c "${cmd}"
