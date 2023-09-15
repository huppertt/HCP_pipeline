#!/bin/bash 
set -e

# Requirements for this script
#  installed versions of: FSL (version 5.0.6) and FreeSurfer (version 5.3.0-HCP)
#  environment: FSLDIR, FREESURFER_HOME + others

################################################ SUPPORT FUNCTIONS ##################################################

Usage() {
  echo "`basename $0`: Script to register EPI to T1w, with distortion correction"
  echo " "
  echo "Usage: `basename $0` [--workingdir=<working dir>]"
  echo "             --scoutin=<input scout image (pre-sat EPI)>"
  echo "             --t1=<input T1-weighted image>"
  echo "             --t1restore=<input bias-corrected T1-weighted image>"
  echo "             --t1brain=<input bias-corrected, brain-extracted T1-weighted image>"
  echo "             --fmapmag=<input fieldmap magnitude image>"
  echo "             --fmapphase=<input fieldmap phase image>"
  echo "             --echodiff=<difference of echo times for fieldmap, in milliseconds>"
  echo "             --SEPhaseNeg=<input spin echo negative phase encoding image>"
  echo "             --SEPhasePos=<input spin echo positive phase encoding image>"
  echo "             --echospacing=<effective echo spacing of fMRI image, in seconds>"
  echo "             --unwarpdir=<unwarping direction: x/y/z/-x/-y/-z>"
  echo "             --owarp=<output filename for warp of EPI to T1w>"
  echo "             --biasfield=<input bias field estimate image, in fMRI space>"
  echo "             --oregim=<output registered image (EPI to T1w)>"
  echo "             --freesurferfolder=<directory of FreeSurfer folder>"
  echo "             --freesurfersubjectid=<FreeSurfer Subject ID>"
  echo "             --gdcoeffs=<gradient non-linearity distortion coefficients (Siemens format)>"
  echo "             [--qaimage=<output name for QA image>]"
  echo "             --method=<method used for distortion correction: FIELDMAP or TOPUP>"
  echo "             [--topupconfig=<topup config file>]"
  echo "             --ojacobian=<output filename for Jacobian image (in T1w space)>"

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

# Outputs (in $WD):
#  
#    FIELDMAP section only: 
#      Magnitude  Magnitude_brain  FieldMap
#
#    FIELDMAP and TOPUP sections: 
#      Jacobian2T1w
#      ${ScoutInputFile}_undistorted  
#      ${ScoutInputFile}_undistorted2T1w_init   
#      ${ScoutInputFile}_undistorted_warp
#
#    FreeSurfer section: 
#      fMRI2str.mat  fMRI2str
#      ${ScoutInputFile}_undistorted2T1w  
#
# Outputs (not in $WD):
#
#       ${RegOutput}  ${OutputTransform}  ${JacobianOut}  ${QAImage}



################################################## OPTION PARSING #####################################################

# Just give usage if no arguments specified
if [ $# -eq 0 ] ; then Usage; exit 0; fi
# check for correct options
if [ $# -lt 21 ] ; then Usage; exit 1; fi

# parse arguments
WD=`getopt1 "--workingdir" $@`  # "$1"
ScoutInputName=`getopt1 "--scoutin" $@`  # "$2"
T1wImage=`getopt1 "--t1" $@`  # "$3"
T1wRestoreImage=`getopt1 "--t1restore" $@`  # "$4"
T1wBrainImage=`getopt1 "--t1brain" $@`  # "$5"
SpinEchoPhaseEncodeNegative=`getopt1 "--SEPhaseNeg" $@`  # "$7"
SpinEchoPhaseEncodePositive=`getopt1 "--SEPhasePos" $@`  # "$5"
DwellTime=`getopt1 "--echospacing" $@`  # "$9"
MagnitudeInputName=`getopt1 "--fmapmag" $@`  # "$6"
PhaseInputName=`getopt1 "--fmapphase" $@`  # "$7"
deltaTE=`getopt1 "--echodiff" $@`  # "$8"
UnwarpDir=`getopt1 "--unwarpdir" $@`  # "${10}"
OutputTransform=`getopt1 "--owarp" $@`  # "${11}"
BiasField=`getopt1 "--biasfield" $@`  # "${12}"
RegOutput=`getopt1 "--oregim" $@`  # "${13}"
FreeSurferSubjectFolder=`getopt1 "--freesurferfolder" $@`  # "${14}"
FreeSurferSubjectID=`getopt1 "--freesurfersubjectid" $@`  # "${15}"
GradientDistortionCoeffs=`getopt1 "--gdcoeffs" $@`  # "${17}"
QAImage=`getopt1 "--qaimage" $@`  # "${20}"
DistortionCorrection=`getopt1 "--method" $@`  # "${21}"
TopupConfig=`getopt1 "--topupconfig" $@`  # "${22}"
JacobianOut=`getopt1 "--ojacobian" $@`  # "${23}"

ScoutInputFile=`basename $ScoutInputName`
T1wBrainImageFile=`basename $T1wBrainImage`


# default parameters
RegOutput=`$FSLDIR/bin/remove_ext $RegOutput`
WD=`defaultopt $WD ${RegOutput}.wdir`
GlobalScripts=${HCPPIPEDIR_Global}
TopupConfig=`defaultopt $TopupConfig ${HCPPIPEDIR_Config}/b02b0.cnf`
UseJacobian=false

echo " "
echo " START: DistortionCorrectionEpiToT1wReg_FLIRTBBRAndFreeSurferBBRBased"

mkdir -p $WD

# Record the input options in a log file
echo "$0 $@" >> $WD/log.txt
echo "PWD = `pwd`" >> $WD/log.txt
echo "date: `date`" >> $WD/log.txt
echo " " >> $WD/log.txt

if [ ! -e ${WD}/FieldMap ] ; then
  mkdir ${WD}/FieldMap
fi

########################################## DO WORK ########################################## 

cp ${T1wBrainImage}.nii.gz ${WD}/${T1wBrainImageFile}.nii.gz

if [ ! -f ${BiasField}.nii.gz ] ; then
   echo "Running FAST to generate BiasField"
   t1folder=`dirname ${T1wBrainImage}.nii.gz` 
   echo "${t1folder} ${T1wBrainImageFile} echoing the t1folder"
   mkdir ${t1folder}/fast
   ${FSLDIR}/bin/fast -t 1 -v -b -p -o ${t1folder}/fast/T1fast ${T1wBrainImage}.nii.gz
   cp -v ${t1folder}/fast/T1fast_bias.nii.gz ${BiasField}.nii.gz 
fi

if [ $DistortionCorrection = "FIELDMAP" ] ; then
    if [ ! -f ${MagnitudeInputName} ] ; then
        DistortionCorrection="NONE"
        echo "Not using field map correction"
    fi
fi

echo $DistortionCorrection

###### FIELDMAP VERSION (GE FIELDMAPS) ######
if [ $DistortionCorrection = "FIELDMAP" ] ; then
  # process fieldmap with gradient non-linearity distortion correction

 echo "  ${GlobalScripts}/FieldMapPreprocessingAll.sh \
      --workingdir=${WD}/FieldMap \
      --fmapmag=${MagnitudeInputName} \
      --fmapphase=${PhaseInputName} \
      --echodiff=${deltaTE} \
      --ofmapmag=${WD}/Magnitude \
      --ofmapmagbrain=${WD}/Magnitude_brain \
      --ofmap=${WD}/FieldMap \
      --gdcoeffs=${GradientDistortionCoeffs}"   

  ${GlobalScripts}/FieldMapPreprocessingAll.sh \
      --workingdir=${WD}/FieldMap \
      --fmapmag=${MagnitudeInputName} \
      --fmapphase=${PhaseInputName} \
      --echodiff=${deltaTE} \
      --ofmapmag=${WD}/Magnitude \
      --ofmapmagbrain=${WD}/Magnitude_brain \
      --ofmap=${WD}/FieldMap \
      --gdcoeffs=${GradientDistortionCoeffs}
 
  cp ${ScoutInputName}.nii.gz ${WD}/Scout.nii.gz
  #Test if Magnitude Brain and T1w Brain Are Similar in Size, if not, assume Magnitude Brain Extraction Failed and Must Be Retried After Removing Bias Field
  MagnitudeBrainSize=`${FSLDIR}/bin/fslstats ${WD}/Magnitude_brain -V | cut -d " " -f 2`
  T1wBrainSize=`${FSLDIR}/bin/fslstats ${WD}/${T1wBrainImageFile} -V | cut -d " " -f 2`

    echo ${MagnitudeBrainSize} 
    echo ${T1wBrainSize}

  if [[ X`echo "if ( (${MagnitudeBrainSize} / ${T1wBrainSize}) > 1.25 ) {1}" | bc -l` = X1 || X`echo "if ( (${MagnitudeBrainSize} / ${T1wBrainSize}) < 0.75 ) {1}" | bc -l` = X1 ]] ; then
    echo "went here"    
    ${FSLDIR}/bin/flirt -interp spline -dof 6 -in ${WD}/Magnitude.nii.gz -ref ${T1wImage} -omat "$WD"/Mag2T1w.mat -out ${WD}/Magnitude2T1w.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30
    ${FSLDIR}/bin/convert_xfm -omat "$WD"/T1w2Mag.mat -inverse "$WD"/Mag2T1w.mat
    #${FSLDIR}/bin/applywarp --interp=spline -i ${BiasField} -r ${WD}/Magnitude.nii.gz --premat="$WD"/T1w2Mag.mat -o ${WD}/Magnitude_Bias.nii.gz
    #mv ${WD}/Magnitude.nii.gz ${WD}/MagnitudeOrig.nii.gz
    #fslmaths ${WD}/MagnitudeOrig.nii.gz -div ${WD}/Magnitude_Bias.nii.gz ${WD}/Magnitude.nii.gz
    ${FSLDIR}/bin/applywarp --interp=nn -i ${WD}/${T1wBrainImageFile} -r ${WD}/Magnitude.nii.gz --premat="$WD"/T1w2Mag.mat -o ${WD}/Magnitude_brain_mask.nii.gz    
    #fslmaths ${WD}/Magnitude_brain_mask.nii.gz -bin -dilD ${WD}/Magnitude_brain_mask.nii.gz
    #fslmaths ${WD}/Magnitude.nii.gz -mas ${WD}/Magnitude_brain_mask.nii.gz ${WD}/Magnitude_brain.nii.gz
    #fslmaths ${WD}/${T1wBrainImageFile} -bin ${WD}/${T1wBrainImageFile}_mask
    #fslmaths ${T1wImage} -mas ${WD}/${T1wBrainImageFile}_mask ${WD}/${T1wBrainImageFile}_norestore_brain
    #${FSLDIR}/bin/flirt -interp spline -dof 6 -in ${WD}/Magnitude_brain.nii.gz -ref ${WD}/${T1wBrainImageFile}_norestore_brain -init "$WD"/Mag2T1w.mat -omat "$WD"/Mag2T1w.mat -out ${WD}/Magnitude2T1w.nii.gz -nosearch 
    #${FSLDIR}/bin/convert_xfm -omat "$WD"/T1w2Mag.mat -inverse "$WD"/Mag2T1w.mat   
    #${FSLDIR}/bin/applywarp --interp=nn -i ${WD}/${T1wBrainImageFile} -r ${WD}/Magnitude.nii.gz --premat="$WD"/T1w2Mag.mat -o ${WD}/Magnitude_brain_mask.nii.gz    
    #${FSLDIR}/bin/bet ${WD}/Magnitude.nii.gz ${WD}/Magnitude_brain.nii.gz -f 0.35 -m #Brain extract the magnitude image
    fslmaths ${WD}/Magnitude_brain_mask.nii.gz -bin ${WD}/Magnitude_brain_mask.nii.gz
    fslmaths ${WD}/Magnitude.nii.gz -mas ${WD}/Magnitude_brain_mask.nii.gz ${WD}/Magnitude_brain.nii.gz

   #  ${FSLDIR}/bin/flirt -interp spline -dof 6 -in ${WD}/Scout.nii.gz -ref ${T1wImage} -omat "$WD"/Scout2T1w.mat -out ${WD}/Scout2T1w.nii.gz -searchrx -10 10 -searchry -10 10 -searchrz -10 10
   # ${FSLDIR}/bin/flirt -interp spline -2D -in ${WD}/Scout.nii.gz -ref ${T1wImage} -omat "$WD"/Scout2T1w.mat -out ${WD}/Scout2T1w.nii.gz

    SUBJECTS_DIR=${FreeSurferSubjectFolder}
    export SUBJECTS_DIR
    fsl_rigid_register -i ${WD}/Scout.nii.gz -r ${T1wImage}.nii.gz -o ${WD}/Scout2T1w.nii.gz -maxangle 5 -fslmat "$WD"/Scout2T1w.mat
    echo " FInished rigid body"


    ${FSLDIR}/bin/convert_xfm -omat "$WD"/T1w2Scout.mat -inverse "$WD"/Scout2T1w.mat
    #${FSLDIR}/bin/applywarp --interp=spline -i ${BiasField} -r ${WD}/Scout.nii.gz --premat="$WD"/T1w2Scout.mat -o ${WD}/Scout_Bias.nii.gz
    #mv ${WD}/Scout.nii.gz ${WD}/ScoutOrig.nii.gz
    #fslmaths ${WD}/ScoutOrig.nii.gz -div ${WD}/Scout_Bias.nii.gz ${WD}/Scout.nii.gz
    ${FSLDIR}/bin/applywarp --interp=nn -i ${WD}/${T1wBrainImageFile} -r ${WD}/Scout.nii.gz --premat="$WD"/T1w2Scout.mat -o ${WD}/Scout_brain_mask.nii.gz    
    
    #${FSLDIR}/bin/bet ${WD}/Scout.nii.gz ${WD}/Scout_brain.nii.gz -f 0.35 -m #Brain extract the magnitude image 
    
    fslmaths ${WD}/Scout_brain_mask.nii.gz -bin ${WD}/Scout_brain_mask.nii.gz
    fslmaths ${WD}/Scout.nii.gz -mas ${WD}/Scout_brain_mask.nii.gz ${WD}/Scout_brain.nii.gz
       
    # register scout to T1w image using fieldmap
    ${FSLDIR}/bin/epi_reg --epi=${WD}/Scout_brain.nii.gz --t1=${WD}/${T1wImage} --t1brain=${WD}/${T1wBrainImageFile} --out=${WD}/${ScoutInputFile}_undistorted --fmap=${WD}/FieldMap.nii.gz --fmapmag=${WD}/Magnitude.nii.gz --fmapmagbrain=${WD}/Magnitude_brain.nii.gz --echospacing=${DwellTime} --pedir=${UnwarpDir}
    #${GlobalScripts}/epi_reg2 --epi=${WD}/Scout_brain.nii.gz --t1=${WD}/${T1wImage} --t1brain=${WD}/${T1wBrainImageFile} --out=${WD}/${ScoutInputFile}_undistorted --fmap=${WD}/FieldMap.nii.gz --fmapmag=${WD}/Magnitude.nii.gz --fmapmagbrain=${WD}/Magnitude_brain.nii.gz --echospacing=${DwellTime} --pedir=${UnwarpDir}
  else
    echo "skipped"
    # register scout to T1w image using fieldmap
    SUBJECTS_DIR=${FreeSurferSubjectFolder}
    export SUBJECTS_DIR
    #${GlobalScripts}/epi_reg2 --epi=${WD}/Scout.nii.gz --t1=${WD}/${T1wImage} --t1brain=${WD}/${T1wBrainImageFile} --out=${WD}/${ScoutInputFile}_undistorted --fmap=${WD}/FieldMap.nii.gz --fmapmag=${WD}/Magnitude.nii.gz --fmapmagbrain=${WD}/Magnitude_brain.nii.gz --echospacing=${DwellTime} --pedir=${UnwarpDir}

    ${FSLDIR}/bin/epi_reg --epi=${WD}/Scout.nii.gz --t1=${WD}/${T1wImage} --t1brain=${WD}/${T1wBrainImageFile} --out=${WD}/${ScoutInputFile}_undistorted --fmap=${WD}/FieldMap.nii.gz --fmapmag=${WD}/Magnitude.nii.gz --fmapmagbrain=${WD}/Magnitude_brain.nii.gz --echospacing=${DwellTime} --pedir=${UnwarpDir}
  fi
  # convert epi_reg warpfield from abs to rel convention (NB: this is the current convention for epi_reg but it may change in the future, or take an option)
  
  #${FSLDIR}/bin/immv ${WD}/${ScoutInputFile}_undistorted_warp ${WD}/${ScoutInputFile}_undistorted_warp_abs
  # ${FSLDIR}/bin/convertwarp --relout --abs -r ${WD}/${ScoutInputFile}_undistorted_warp_abs -w ${WD}/${ScoutInputFile}_undistorted_warp_abs -o ${WD}/${ScoutInputFile}_undistorted_warp
  
  #create spline interpolated output for scout to T1w + apply bias field correction
  ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${ScoutInputName} -r ${T1wImage} -w ${WD}/${ScoutInputFile}_undistorted_warp.nii.gz -o ${WD}/${ScoutInputFile}_undistorted_1vol.nii.gz
  ${FSLDIR}/bin/fslmaths ${WD}/${ScoutInputFile}_undistorted_1vol.nii.gz -div ${BiasField} ${WD}/${ScoutInputFile}_undistorted_1vol.nii.gz
  ${FSLDIR}/bin/immv ${WD}/${ScoutInputFile}_undistorted_1vol.nii.gz ${WD}/${ScoutInputFile}_undistorted2T1w_init.nii.gz
  ###Jacobian Volume FAKED for Regular Fieldmaps (all ones) ###
  ${FSLDIR}/bin/fslmaths ${T1wImage} -abs -add 1 -bin ${WD}/Jacobian2T1w.nii.gz
    
###### TOPUP VERSION (SE FIELDMAPS) ######
elif [ $DistortionCorrection = "TOPUP" ] ; then
  # Use topup to distortion correct the scout scans
  #    using a blip-reversed SE pair "fieldmap" sequence
  ${GlobalScripts}/TopupPreprocessingAll.sh \
      --workingdir=${WD}/FieldMap \
      --phaseone=${SpinEchoPhaseEncodeNegative} \
      --phasetwo=${SpinEchoPhaseEncodePositive} \
      --scoutin=${ScoutInputName} \
      --echospacing=${DwellTime} \
      --unwarpdir=${UnwarpDir} \
      --owarp=${WD}/WarpField \
      --ojacobian=${WD}/Jacobian \
      --gdcoeffs=${GradientDistortionCoeffs} \
      --topupconfig=${TopupConfig} \
      --usejacobian=$UseJacobian

  # create a spline interpolated image of scout (distortion corrected in same space)
  ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${ScoutInputName} -r ${ScoutInputName} -w ${WD}/WarpField.nii.gz -o ${WD}/${ScoutInputFile}_undistorted
  # apply Jacobian correction to scout image (optional)
  if [ $UseJacobian = true ] ; then
      ${FSLDIR}/bin/fslmaths ${WD}/${ScoutInputFile}_undistorted -mul ${WD}/Jacobian.nii.gz ${WD}/${ScoutInputFile}_undistorted
  fi
  # register undistorted scout image to T1w
  ${FSLDIR}/bin/epi_reg --epi=${WD}/${ScoutInputFile}_undistorted --t1=${T1wImage} --t1brain=${WD}/${T1wBrainImageFile} --out=${WD}/${ScoutInputFile}_undistorted
  # generate combined warpfields and spline interpolated images + apply bias field correction
  ${FSLDIR}/bin/convertwarp --relout --rel -r ${T1wImage} --warp1=${WD}/WarpField.nii.gz --postmat=${WD}/${ScoutInputFile}_undistorted.mat -o ${WD}/${ScoutInputFile}_undistorted_warp
  ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${WD}/Jacobian.nii.gz -r ${T1wImage} --premat=${WD}/${ScoutInputFile}_undistorted.mat -o ${WD}/Jacobian2T1w.nii.gz
  ${FSLDIR}/bin/applywarp --rel --interp=spline -i ${ScoutInputName} -r ${T1wImage} -w ${WD}/${ScoutInputFile}_undistorted_warp -o ${WD}/${ScoutInputFile}_undistorted

 # apply Jacobian correction to scout image (optional)
    if [ $UseJacobian = true ] ; then
          ${FSLDIR}/bin/fslmaths ${WD}/${ScoutInputFile}_undistorted -div ${BiasField} -mul ${WD}/Jacobian2T1w.nii.gz ${WD}/${ScoutInputFile}_undistorted2T1w_init.nii.gz 
    else
          ${FSLDIR}/bin/fslmaths ${WD}/${ScoutInputFile}_undistorted -div ${BiasField} ${WD}/${ScoutInputFile}_undistorted2T1w_init.nii.gz 
    fi
  
else
  echo "UNKNOWN DISTORTION CORRECTION METHOD"
  cp ${ScoutInputName}.nii.gz ${WD}/Scout.nii.gz  
  SUBJECTS_DIR=${FreeSurferSubjectFolder}
  export SUBJECTS_DIR
  fsl_rigid_register -i ${WD}/Scout.nii.gz -r ${T1wImage}.nii.gz -o ${WD}/Scout2T1w.nii.gz -maxangle 5 -fslmat "$WD"/Scout2T1w.mat
  
  ${FSLDIR}/bin/convert_xfm -omat "$WD"/T1w2Scout.mat -inverse "$WD"/Scout2T1w.mat   

  ${FSLDIR}/bin/applywarp --interp=nn -i ${WD}/${T1wBrainImageFile} -r ${WD}/Scout.nii.gz --premat="$WD"/T1w2Scout.mat -o ${WD}/Scout_brain_mask.nii.gz    
    
  fslmaths ${WD}/Scout_brain_mask.nii.gz -bin ${WD}/Scout_brain_mask.nii.gz
  fslmaths ${WD}/Scout.nii.gz -mas ${WD}/Scout_brain_mask.nii.gz ${WD}/Scout_brain.nii.gz
  
  
  fsl_rigid_register -i ${WD}/Scout_brain.nii.gz -r ${WD}/${T1wBrainImageFile}.nii.gz -o ${WD}/Scout_brain2T1w.nii.gz -maxangle 5 -fslmat "$WD"/Scout2T1w.mat  

  ${FSLDIR}/bin/applywarp --interp=nn -i ${WD}/Scout.nii.gz -r ${WD}/${T1wBrainImageFile} --premat="$WD"/Scout2T1w.mat -o ${WD}/Scout2T1w.nii.gz 
  
  fslmaths ${WD}/${T1wBrainImageFile}.nii.gz -bin ${WD}/Scout_brain_mask2T1w.nii.gz
  fslmaths ${WD}/Scout2T1w.nii.gz -mas ${WD}/Scout_brain_mask2T1w.nii.gz ${WD}/Scout_brain2T1w.nii.gz  


  ###Jacobian Volume FAKED for Regular Fieldmaps (all ones) ###
  ${FSLDIR}/bin/fslmaths ${T1wImage} -abs -add 1 -bin ${WD}/Jacobian2T1w.nii.gz

#  exit
fi


cp ${WD}/Scout_brain2T1w.nii.gz ${RegOutput}.nii.gz
cp ${WD}/Scout2T1w.mat ${OutputTransform}.mat
cp ${WD}/Jacobian2T1w.nii.gz ${JacobianOut}.nii.gz


# QA image (sqrt of EPI * T1w)
${FSLDIR}/bin/fslmaths ${T1wRestoreImage}.nii.gz -mul ${RegOutput}.nii.gz -sqrt ${QAImage}.nii.gz

echo " "
echo " END: DistortionCorrectionEpiToT1wReg_FLIRTBBRAndFreeSurferBBRBased"
echo " END: `date`" >> $WD/log.txt

########################################## QA STUFF ########################################## 

if [ -e $WD/qa.txt ] ; then rm -f $WD/qa.txt ; fi
echo "cd `pwd`" >> $WD/qa.txt
echo "# Check registration of EPI to T1w (with all corrections applied)" >> $WD/qa.txt
echo "fslview ${T1wRestoreImage} ${RegOutput} ${QAImage}" >> $WD/qa.txt
echo "# Check undistortion of the scout image" >> $WD/qa.txt
echo "fslview `dirname ${ScoutInputName}`/GradientDistortionUnwarp/Scout ${WD}/${ScoutInputFile}_undistorted" >> $WD/qa.txt

##############################################################################################

