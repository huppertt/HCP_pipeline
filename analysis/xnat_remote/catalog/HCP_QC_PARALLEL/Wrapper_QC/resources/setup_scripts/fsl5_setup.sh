#!/bin/bash

# fsl5_setup.sh
#

FSLDIR=/usr/pkg/fsl
source ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
LD_LIBRARY_PATH=${FSLDIR}/lib::${LD_LIBRARY_PATH}
export FSLDIR PATH LD_LIBRARY_PATH