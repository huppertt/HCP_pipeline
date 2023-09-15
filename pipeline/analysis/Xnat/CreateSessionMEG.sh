#! /bin/bash
export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2
export sess=$3
export date=$4
export jsess=$5

export sessiontype="megSessionData"

if [ -z "$jsess" ] ; then
    if [ -z "$xdc_put" ]; then
        export xdc_put=" -u hcpadmin -p 'hcp22' -m PUT "
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -u hcpadmin -p 'hcp22' -m GET "
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

eval VAR=\$\($"XnatDataClientCerebro $xdc_get ${xrem}${project}/subjects/ | grep ${subjid}"\)


if [ -z "$VAR" ]; then
    echo "Subject not found: Creating entry"
    eval thisdir=\$\($"dirname $0"\)
    eval "${thisdir}/CreateSubject.sh ${project} ${subjid} ${jsess}"
fi

export cmd="XnatDataClientCerebro $xdc_put ${xrem}${project}/subjects/${subjid}/experiments/${sess}?xnat:${sessiontype}/date=${date}"

# create subject
#echo ${cmd}
bash -c "${cmd}"