#!/bin/sh

#  CerebroXnatSetUp.sh
#  
#
#  Created by Huppert on 6/8/17.
#

script2run=$1
datafolder=$2

xnatpipeline=/disk/HCP/pipeline/xnat_remote
paramFile=${datafolder}/xnat.params
xmlfile=${datafolder}/logs/*.xml

${xnatpipeline}/catalog/pipeline-tools/resources/Pip2Bash.sh ${xmlfile} ${paramFile}
