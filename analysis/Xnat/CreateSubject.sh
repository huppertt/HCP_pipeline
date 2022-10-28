#! /bin/bash

if [ -z "$xdc_put" ]; then
    export xdc_put=" -u hcpadmin -p 'hcp22' -m PUT -r "
fi

if [ -z "$xrem" ]; then
    export xrem="http://10.48.86.212:8080/data/projects/"
fi

export PATH=$PATH:/opt/local/bin

export project=$1
export subjid=$2

export cmd="XnatDataClient $xdc_put ${xrem}${project}/subjects/${subjid}"


# create subject
echo ${cmd}
bash -c "${cmd}"
