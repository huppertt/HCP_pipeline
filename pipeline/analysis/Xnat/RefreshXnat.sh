#! /bin/bash

export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2
export sess=$3
export scan=$4
export type=$5
export jsess=$6


if [ -z "$jsess" ] ; then
    if [ -z "$xdc_post" ]; then
        export xdc_post=" -u hcpadmin -p 'hcp22' -m POST"
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -u hcpadmin -p 'hcp22' -m GET"
    fi

else

    if [ -z "$xdc_post" ]; then
        export xdc_post=" -s ${jsess} -m POST "
    fi
    if [ -z "$xdc_get" ]; then
        export xdc_get=" -s ${jsess} -m GET "
    fi
fi

if [ -z "$xrem" ]; then
    export xrem=" -r http://10.48.86.212:8080/data/projects/"
fi



eval VAR=\$\($"XnatDataClientCerebro $xdc_get ${xrem}${project}/subjects/${subjid}/experiments/ | grep ${sess}"\)



export xrem="${xrem}${project}/subjects/${subjid}/experiments/${sess}/scans/${scan}"


export cmd="XnatDataClientCerebro $xdc_post /sevices/refresh/catalog?resource=${xrem}"

# create subject
#echo ${cmd}
bash -c "${cmd}"
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
