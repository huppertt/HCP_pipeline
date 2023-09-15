#!/bin/bash
# bxh_xcede_tools_setup.sh;

PACKAGES_HOME=/sulcusdata/xnat/pipeline/catalog/HCP_QC_PARALLEL/Wrapper_QC/resources
source ${PACKAGES_HOME}/setup_scripts/AFNI_setup.sh
BXH_XCEDE_TOOLS_HOME=${PACKAGES_HOME}/tools/bxh_xcede_tools
PATH=${BXH_XCEDE_TOOLS_HOME}/bin:${PATH}
export PATH