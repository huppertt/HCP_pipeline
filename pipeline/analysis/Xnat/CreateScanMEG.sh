#! /bin/bash

export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2
export sess=$3
export scan=$4
export type=$5
export jsess=$6


if [ -z "$jsess" ] ; then
    if [ -z "$xdc_put" ]; then
    export xdc_put=" -u hcpadmin -p 'hcp22' -m PUT"
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -u hcpadmin -p 'hcp22' -m GET"
    fi

else

    if [ -z "$xdc_put" ]; then
        export xdc_put=" -s ${jsess} -m PUT "
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -s ${jsess} -m GET "
    fi
fi

if [ -z "$xrem" ]; then
    export xrem=" -r http://10.48.86.212:8080/data/projects/"
fi



export sessiontype="MEGSessionData"

eval VAR=\$\($"XnatDataClientCerebro $xdc_get ${xrem}${project}/subjects/${subjid}/experiments/ | grep ${sess}"\)

if [ -z "$VAR" ]; then
    echo "Session not found: Creating entry"
    eval thisdir=\$\($"dirname $0"\)
    eval "${thisdir}/CreateSessionMEG.sh ${project} ${subjid} ${sess} ${jsess}"
fi


export xrem="${xrem}${project}/subjects/${subjid}/experiments/${sess}/scans/${scan}"


export cmd="XnatDataClientCerebro $xdc_put ${xrem}?xnat:megScanData/type=${type}"

# create subject
#echo ${cmd}
bash -c "${cmd}"
