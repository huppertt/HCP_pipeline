#! /bin/bash

export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2
export sess=$3
export file1=$4
export file2=$5
export jsess=$6

export sessiontype="mrSessionData"

if [ -z "$jsess" ] ; then
    if [ -z "$xdc_put" ]; then
        export xdc_put=" -u hcpadmin -p hcp22 -m PUT"
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -u hcpadmin -p hcp22 -m GET"
    fi

else

    if [ -z "$xdc_put" ]; then
        export xdc_put=" -s ${jsess} -m PUT"
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -s ${jsess} -m GET"
    fi
fi

if [ -z "$xrem" ]; then
    export xrem=" -r http://10.48.86.212:8080/data/archive/projects/"
fi

export xrem="${xrem}${project}/subjects/${subjid}/experiments/${sess}/assessors/"

export cmd="XnatDataClientCerebro $xdc_put ${xrem}HCP201_MR1_PC_20170616052124/out/resources/VALIDATION/VALIDATION_catalog.xml -l ${file1}"
bash -c "${cmd}"
echo ${cmd}

export cmd="XnatDataClientCerebro $xdc_put ${xrem}HCP201_MR1_PC_20170616052124/out/resources/VALIDATION/files/test_rule.xml -l ${file2}"
bash -c "${cmd}"
echo ${cmd}


# create subject
#echo ${cmd}
