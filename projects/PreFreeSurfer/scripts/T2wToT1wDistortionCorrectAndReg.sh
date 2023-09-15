#!/bin/bash 
set -e
# Requirements for this script
#  installed versions of: FSL (version 5.0.6), HCP-gradunwarp (HCP version 1.0.2)
#  environment: FSLDIR and PATH for gradient_unwarp.py

################################################ SUPPORT FUNCTIONS ##################################################

Usage() {
  echo "`basename $0`: Script for performing gradient-nonlinearity and susceptibility-inducted distortion correction on T1w and T2w images, then also registering T2w to T1w"
  echo " "
  echo "Usage: `basename $0` [--workingdir=<working directory>]"
  echo "            --t1=<input T1w image>"
  echo "            --t1brain=<input T1w brain-extracted image>"
  echo "            --t2=<input T2w image>"
  echo "            --t2brain=<input T2w brain-extracted image>"
  echo "            [--fmapmag=<input fieldmap magnitude image>]"
  echo "            [--fmapphase=<input fieldmap phase images (single 4D image containing 2x3D volumes)>]"
  echo "            [--echodiff=<echo time difference for fieldmap images (in milliseconds)>]"
  echo "            [--SEPhaseNeg=<input spin echo negative phase encoding image>]"
  echo "            [--SEPhasePos=<input spin echo positive phase encoding image>]"
  echo "            [--echospacing=<effective echo spacing of fMRI image, in seconds>]"
  echo "            [--seunwarpdir=<direction of distortion according to voxel axes>]"
  echo "            --t1sampspacing=<sample spacing (readout direction) of T1w image - in seconds>"
  echo "            --t2sampspacing=<sample spacing (readout direction) of T2w image - in seconds>"
  echo "            --unwarpdir=<direction of distortion according to voxel axes (post reorient2std)>"
  echo "            --ot1=<output corrected T1w image>"
  echo "            --ot1brain=<output corrected, brain-extracted T1w image>"
  echo "            --ot1warp=<output warpfield for distortion correction of T1w image>"
  echo "            --ot2=<output corrected T2w image>"
  echo "            --ot2brain=<output corrected, brain-extracted T2w image>"
  echo "            --ot2warp=<output warpfield for distortion correction of T2w image>"
  echo "            --method=<method used for distortion correction: FIELDMAP or TOPUP>"
  echo "            [--topupconfig=<topup config file>]"
  echo "            [--gdcoeffs=<gradient distortion coefficients (SIEMENS file)>]"
}

# function for parsing options
getopt1() {
    sopt="$1"
    shift 1
    for fn in $@ ; do
	if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then
	    echo $fn | sed "s/^${sopt}=//"
	    return 0
	fi
    done
}

defaultopt() {
    echo $1
}

################################################### OUTPUT FILES #####################################################

# For distortion correction:
#
# Output files (in $WD): Magnitude  Magnitude_brain  Phase  FieldMap
#                        Magnitude_brain_warppedT1w  Magnitude_brain_warppedT1w2${TXwImageBrainBasename}
#                        fieldmap2${T1wImageBrainBasename}.mat   FieldMap2${T1wImageBrainBasename}
#                        FieldMap2${T1wImageBrainBasename}_ShiftMap  
#                        FieldMap2${T1wImageBrainBasename}_Warp ${T1wImageBasename}  ${T1wImageBrainBasename}
#        Plus the versions with T1w -> T2w
#
# Output files (not in $WD):  ${OutputT1wTransform}   ${OutputT1wImage}  ${OutputT1wImageBrain}
#        Note that these outputs are actually copies of the last three entries in the $WD list
#
#
# For registration:
#
# Output images (in $WD/T2w2T1w):  sqrtT1wbyT2w  T2w_reg.mat  T2w_reg_init.mat
#                                  T2w_dc_reg  (the warp field)
#                                  T2w_reg     (the warped image)
# Output images (not in $WD):  ${OutputT2wTransform}   ${OutputT2wImage}
#        Note that these outputs are copies of the last two images (respectively) from the T2w2T1w subdirectory

################################################## OPTION PARSING #####################################################

# Just give usage if no arguments specified
if [ $# -eq 0 ] ; then Usage; exit 0; fi
# check for correct options
if [ $# -lt 17 ] ; then Usage; exit 1; fi

# parse arguments
WD=`getopt1 "--workingdir" $@`  # "$1"
T1wImage=`getopt1 "--t1" $@`  # "$2"
T1wImageBrain=`getopt1 "--t1brain" $@`  # "$3"
T2wImage=`getopt1 "--t2" $@`  # "$4"
T2wImageBrain=`getopt1 "--t2brain" $@`  # "$5"
MagnitudeInputName=`getopt1 "--fmapmag" $@`  # "$6"
PhaseInputName=`getopt1 "--fmapphase" $@`  # "$7"
TE=`getopt1 "--echodiff" $@`  # "$8"
SpinEchoPhaseEncodeNegative=`getopt1 "--SEPhaseNeg" $@`  # "$7"
SpinEchoPhaseEncodePositive=`getopt1 "--SEPhasePos" $@`  # "$5"
DwellTime=`getopt1 "--echospacing" $@`  # "$9"
SEUnwarpDir=`getopt1 "--seunwarpdir" $@`  # "${11}"
T1wSampleSpacing=`getopt1 "--t1sampspacing" $@`  # "$9"
T2wSampleSpacing=`getopt1 "--t2sampspacing" $@`  # "${10}"
UnwarpDir=`getopt1 "--unwarpdir" $@`  # "${11}"
OutputT1wImage=`getopt1 "--ot1" $@`  # "${12}"
OutputT1wImageBrain=`getopt1 "--ot1brain" $@`  # "${13}"
OutputT1wTransform=`getopt1 "--ot1warp" $@`  # "${14}"
OutputT2wImage=`getopt1 "--ot2" $@`  # "${15}"
OutputT2wTransform=`getopt1 "--ot2warp" $@`  # "${16}"
DistortionCorrection=`getopt1 "--method" $@`  # "${21}"
TopupConfig=`getopt1 "--topupconfig" $@`  # "${22}"
GradientDistortionCoeffs=`getopt1 "--gdcoeffs" $@`  # "${18}"

# default parameters
WD=`defaultopt $WD .`

T1wImage=`${FSLDIR}/bin/remove_ext $T1wImage`
T1wImageBrain=`${FSLDIR}/bin/remove_ext $T1wImageBrain`
T2wImage=`${FSLDIR}/bin/remove_ext $T2wImage`
T2wImageBrain=`${FSLDIR}/bin/remove_ext $T2wImageBrain`

T1wImageBrainBasename=`basename "$T1wImageBrain"`
T1wImageBasename=`basename "$T1wImage"`
T2wImageBrainBasename=`basename "$T2wImageBrain"`
T2wImageBasename=`basename "$T2wImage"`

Modalities="T1w T2w"

echo " "
echo " START: T2wToT1wDistortionCorrectionAndReg"

mkdir -p $WD
mkdir -p ${WD}/FieldMap

# Record the input options in a log file
echo "$0 $@" >> $WD/log.txt
echo "PWD = `pwd`" >> $WD/log.txt
echo "date: `date`" >> $WD/log.txt
echo " " >> $WD/log.txt
echo ${MagnitudeInputName}

HASFMAP=1
if [ ! -f ${MagnitudeInputName} ] ; then
    HASFMAP=0
    echo "No field map found"
fi

########################################## DO WORK ########################################## 

if [ ${HASFMAP} = 1 ] ; then
###### FIELDMAP VERSION (GE FIELDMAPS) ######
if [ $DistortionCorrection = "FIELDMAP" ] ; then
  ### Create fieldmaps (and apply gradient non-linearity distortion correction)
  echo " "
  echo " "
  echo " "
  #echo ${HCPPIPEDIR_Global}/FieldMapPreprocessingAll.sh ${WD}/FieldMap ${MagnitudeInputName} ${PhaseInputName} ${TE} ${WD}/Magnitude ${WD}/Magnitude_brain ${WD}/Phase ${WD}/FieldMap ${GradientDistortionCoeffs} ${GlobalScripts}

  ${HCPPIPEDIR_Global}/FieldMapPreprocessingAll.sh \
    --workingdir=${WD}/FieldMap \
    --fmapmag=${MagnitudeInputName} \
    --fmapphase=${PhaseInputName} \
    --echodiff=${TE} \
    --ofmapmag=${WD}/Magnitude \
    --ofmapmagbrain=${WD}/Magnitude_brain \
    --ofmap=${WD}/FieldMap \
    --gdcoeffs=${GradientDistortionCoeffs}
###### TOPUP VERSION (SE FIELDMAPS) ######
elif [ $DistortionCorrection = "TOPUP" ] ; then
  if [[ ${SEUnwarpDir} = "x" || ${SEUnwarpDir} = "y" ]] ; then
    ScoutInputName="${SpinEchoPhaseEncodePositive}"
  elif [[ ${SEUnwarpDir} = "-x" || ${SEUnwarpDir} = "-y" || ${SEUnwarpDir} = "x-" || ${SEUnwarpDir} = "y-" ]] ; then
    ScoutInputName="${SpinEchoPhaseEncodeNegative}"
  fi
  # Use topup to distortion correct the scout scans
  #    using a blip-reversed SE pair "fieldmap" sequence
  ${HCPPIPEDIR_Global}/TopupPreprocessingAll.sh \
      --workingdir=${WD}/FieldMap \
      --phaseone=${SpinEchoPhaseEncodeNegative} \
      --phasetwo=${SpinEchoPhaseEncodePositive} \
      --scoutin=${ScoutInputName} \
      --echospacing=${DwellTime} \
      --unwarpdir=${SEUnwarpDir} \
      --ofmapmag=${WD}/Magnitude \
      --ofmapmagbrain=${WD}/Magnitude_brain \
      --ofmap=${WD}/FieldMap \
      --ojacobian=${WD}/Jacobian \
      --gdcoeffs=${GradientDistortionCoeffs} \
      --topupconfig=${TopupConfig}
fi


### LOOP over available modalities ###

for TXw in $Modalities ; do
    # set up required variables
    if [ $TXw = T1w ] ; then
	TXwImage=$T1wImage
	TXwImageBrain=$T1wImageBrain
	TXwSampleSpacing=$T1wSampleSpacing
	TXwImageBasename=$T1wImageBasename
	TXwImageBrainBasename=$T1wImageBrainBasename
    else
	TXwImage=$T2wImage
	TXwImageBrain=$T2wImageBrain
	TXwSampleSpacing=$T2wSampleSpacing
	TXwImageBasename=$T2wImageBasename
	TXwImageBrainBasename=$T2wImageBrainBasename
    fi

    # Forward warp the fieldmap magnitude and register to TXw image (transform phase image too)
    ${FSLDIR}/bin/fugue --loadfmap=${WD}/FieldMap --dwell=${TXwSampleSpacing} --saveshift=${WD}/FieldMap_ShiftMap${TXw}.nii.gz    
    ${FSLDIR}/bin/convertwarp --relout --rel --ref=${WD}/Magnitude --shiftmap=${WD}/FieldMap_ShiftMap${TXw}.nii.gz --shiftdir=${UnwarpDir} --out=${WD}/FieldMap_Warp${TXw}.nii.gz    
   
    
    if [ $DistortionCorrection = "FIELDMAP" ] ; then

      ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/Magnitude -r ${WD}/Magnitude -w ${WD}/FieldMap_Warp${TXw}.nii.gz -o ${WD}/Magnitude_warpped${TXw}
      ${FSLDIR}/bin/flirt -interp spline -dof 6 -in ${WD}/Magnitude_warpped${TXw} -ref ${TXwImage} -out ${WD}/Magnitude_warpped${TXw}2${TXwImageBasename} -omat ${WD}/Fieldmap2${TXwImageBasename}.mat -searchrx -30 30 -searchry -30 30 -searchrz -30 30
      ${FSLDIR}/bin/fixFLIRT.sh ${WD}/Fieldmap2${TXwImageBasename}.mat  >> $WD/tmp.mat
      mv $WD/tmp.mat ${WD}/Fieldmap2${TXwImageBasename}.mat

    elif [ $DistortionCorrection = "TOPUP" ] ; then
      ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/Magnitude_brain -r ${WD}/Magnitude_brain -w ${WD}/FieldMap_Warp${TXw}.nii.gz -o ${WD}/Magnitude_brain_warpped${TXw}
      ${FSLDIR}/bin/flirt -interp spline -dof 6 -in ${WD}/Magnitude_brain_warpped${TXw} -ref ${TXwImageBrain} -out ${WD}/Magnitude_brain_warpped${TXw}2${TXwImageBasename} -omat ${WD}/Fieldmap2${TXwImageBasename}.mat -searchrx -30 30 -searchry -30 30 -searchrz -30 30
    fi
    
    ${FSLDIR}/bin/flirt -in ${WD}/FieldMap.nii.gz -ref ${TXwImage} -applyxfm -init ${WD}/Fieldmap2${TXwImageBasename}.mat -out ${WD}/FieldMap2${TXwImageBasename}
    
    # Convert to shift map then to warp field and unwarp the TXw
    ${FSLDIR}/bin/fugue --loadfmap=${WD}/FieldMap2${TXwImageBasename} --dwell=${TXwSampleSpacing} --saveshift=${WD}/FieldMap2${TXwImageBasename}_ShiftMap.nii.gz    
    ${FSLDIR}/bin/convertwarp --relout --rel --ref=${TXwImageBrain} --shiftmap=${WD}/FieldMap2${TXwImageBasename}_ShiftMap.nii.gz --shiftdir=${UnwarpDir} --out=${WD}/FieldMap2${TXwImageBasename}_Warp.nii.gz    
    ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${TXwImage} -r ${TXwImage} -w ${WD}/FieldMap2${TXwImageBasename}_Warp.nii.gz -o ${WD}/${TXwImageBasename}
    
    # Make a brain image (transform to make a mask, then apply it)
    ${FSLDIR}/bin/applywarp --rel --interp=nn -i ${TXwImageBrain} -r ${TXwImageBrain} -w ${WD}/FieldMap2${TXwImageBasename}_Warp.nii.gz -o ${WD}/${TXwImageBrainBasename} 
    ${FSLDIR}/bin/fslmaths ${WD}/${TXwImageBasename} -mas ${WD}/${TXwImageBrainBasename} ${WD}/${TXwImageBrainBasename}
    
    # Copy files to specified destinations
    if [ $TXw = T1w ] ; then 
       ${FSLDIR}/bin/imcp ${WD}/FieldMap2${TXwImageBasename}_Warp ${OutputT1wTransform}
       ${FSLDIR}/bin/imcp ${WD}/${TXwImageBasename} ${OutputT1wImage}
       ${FSLDIR}/bin/imcp ${WD}/${TXwImageBrainBasename} ${OutputT1wImageBrain}
    fi
    
done
else
    
    ${FSLDIR}/bin/imcp ${T1wImageBrain} ${WD}/${T1wImageBrainBasename} 
    ${FSLDIR}/bin/imcp ${T1wImage} ${WD}/${T1wImageBasename}
    ${FSLDIR}/bin/imcp ${T2wImageBrain} ${WD}/${T2wImageBrainBasename} 
    ${FSLDIR}/bin/imcp ${T2wImage} ${WD}/${T2wImageBasename}

    ${FSLDIR}/bin/imcp ${WD}/${T1wImageBasename} ${OutputT1wImage}
    ${FSLDIR}/bin/imcp ${WD}/${T1wImageBrainBasename} ${OutputT1wImageBrain}
fi




### END LOOP over modalities ###


### Now do T2w to T1w registration
mkdir -p ${WD}/T2w2T1w
    
# Main registration: between corrected T2w and corrected T1w
${FSLDIR}/bin/epi_reg --epi=${WD}/${T2wImageBrainBasename}.nii.gz --t1=${WD}/${T1wImageBasename}.nii.gz --t1brain=${WD}/${T1wImageBrainBasename}.nii.gz --out=${WD}/T2w2T1w/T2w_reg

    ${FSLDIR}/bin/fixFLIRT.sh ${WD}/T2w2T1w/T2w_reg.mat  >> "$WD"/tmp.mat
      mv "$WD"/tmp.mat ${WD}/T2w2T1w/T2w_reg.mat


if [ ${HASFMAP} = 1 ] ; then    
    # Make a warpfield directly from original (non-corrected) T2w to corrected T1w  (and apply it)
    ${FSLDIR}/bin/convertwarp --relout --rel --ref=${T1wImage}.nii.gz --warp1=${WD}/FieldMap2${T2wImageBasename}_Warp.nii.gz --postmat=${WD}/T2w2T1w/T2w_reg.mat -o ${WD}/T2w2T1w/T2w_dc_reg

    ${FSLDIR}/bin/applywarp --rel --interp=spline --in=${T2wImage}.nii.gz --ref=${T1wImage}.nii.gz --warp=${WD}/T2w2T1w/T2w_dc_reg --out=${WD}/T2w2T1w/T2w_reg

else
    ${FSLDIR}/bin/convertwarp --relout --rel --ref=${T1wImage}.nii.gz --postmat=${WD}/T2w2T1w/T2w_reg.mat -o ${WD}/T2w2T1w/T2w_dc_reg
    ${FSLDIR}/bin/applywarp --rel --interp=spline --in=${T2wImage}.nii.gz --ref=${T1wImage}.nii.gz --warp=${WD}/T2w2T1w/T2w_dc_reg --out=${WD}/T2w2T1w/T2w_reg
fi
   

# Add 1 to avoid exact zeros within the image (a problem for myelin mapping?)
${FSLDIR}/bin/fslmaths ${WD}/T2w2T1w/T2w_reg.nii.gz -add 1 ${WD}/T2w2T1w/T2w_reg.nii.gz -odt float

# QA image
${FSLDIR}/bin/fslmaths ${WD}/T2w2T1w/T2w_reg -mul ${T1wImage}.nii.gz -sqrt ${WD}/T2w2T1w/sqrtT1wbyT2w -odt float
    
# Copy files to specified destinations
${FSLDIR}/bin/imcp ${WD}/T2w2T1w/T2w_dc_reg ${OutputT2wTransform}
${FSLDIR}/bin/imcp ${WD}/T2w2T1w/T2w_reg ${OutputT2wImage}

echo " "
echo " END: T2wToT1wDistortionCorrectionAndReg"
echo " END: `date`" >> $WD/log.txt

########################################## QA STUFF ########################################## 

if [ -e $WD/qa.txt ] ; then rm -f $WD/qa.txt ; fi
echo "cd `pwd`" >> $WD/qa.txt
echo "# View registration result of corrected T2w to corrected T1w image: showing both images + sqrt(T1w*T2w)" >> $WD/qa.txt
echo "fslview ${OutputT1wImage} ${OutputT2wImage} ${WD}/T2w2T1w/sqrtT1wbyT2w" >> $WD/qa.txt
echo "# Compare pre- and post-distortion correction for T1w" >> $WD/qa.txt
echo "fslview ${T1wImage} ${OutputT1wImage}" >> $WD/qa.txt
echo "# Compare pre- and post-distortion correction for T2w" >> $WD/qa.txt
echo "fslview ${T2wImage} ${WD}/${T2wImageBasename}" >> $WD/qa.txt

##############################################################################################
