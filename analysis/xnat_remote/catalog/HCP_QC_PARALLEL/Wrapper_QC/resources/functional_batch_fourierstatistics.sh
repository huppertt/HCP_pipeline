#!/bin/bash

#Given a params file and an index of the scan as input argument,
#this script would generate the FourierStatistics for the scan
#The scan is picked up from the array using the $SGE_TASK_ID for the given task

my_sge_task_id=$1
paramsFile=$2
#Pass yes or no for isStructural
isStructural=$3

##############################################
#
# Import the paths from configuration file
#
##############################################

source $paramsFile

source ${xnatpipeline}/catalog/HCP_QC_PARALLEL/Wrapper_QC/resources/config/level2qc.config

source ${xnatpipeline}/catalog/HCP_QC_PARALLEL/Wrapper_QC/resources/setup_scripts/epd-python_setup.sh




my_scan=${functional_usable_scanids[$my_sge_task_id]}

FUNCTIONAL_PLOT_GENERATOR=${xnatpipeline}/catalog/HCP_QC_PARALLEL/FourierCoefficients/resources/generate_plots_functional.csh
STRUCTURAL_PLOT_GENERATOR=${xnatpipeline}/catalog/HCP_QC_PARALLEL/FourierCoefficients/resources/generate_plots_struc.csh

indir=${workdir}/RAWNIFTI/${my_scan}

inpattern="*.nii.gz"

outdir=${fourier_slope_statistics_dir}/${my_scan}


pushd $indir 
/disk/HCP/pipeline/external/Python-3.5.2/bin/bin/python3.5 ${xnatpipeline}/catalog/HCP_QC_PARALLEL/Wrapper_QC/resources/hcp_functional_qc_tools/FourierStatistics/FourierSlope.py -D ${indir} -N $inpattern -O $outdir
popd

pushd ${fourier_slope_statistics_dir}
	if [ $isStructural = no ] ; then
	  $FUNCTIONAL_PLOT_GENERATOR $sessionId ${fourier_slope_statistics_dir}/${my_scan}  ${fourier_slope_statistics_dir}/${my_scan} $my_scan 
	else
	  $STRUCTURAL_PLOT_GENERATOR $sessionId ${fourier_slope_statistics_dir}/${my_scan} ${fourier_slope_statistics_dir}/${my_scan} $my_scan 
	fi
popd

exit 0;
