#!/bin/bash 
set -e

echo " "
echo " START: T2w2T1Reg"

WD="$1"
T1wImage="$2"
T1wImageBrain="$3"
T2wImage="$4"
T2wImageBrain="$5"
OutputT2wImage="$6"
OutputT2wTransform="$7"
OutputT1wTransform="$8"

T1wImageBrainFile=`basename "$T1wImageBrain"`

cp "$T1wImageBrain".nii.gz "$WD"/"$T1wImageBrainFile".nii.gz
# ${FSLDIR}/bin/epi_reg --epi="$T2wImageBrain" --t1="$T1wImage" --t1brain="$WD"/"$T1wImageBrainFile" --out="$WD"/T2w2T1w

${FSLDIR}/bin/flirt -v -in "$T2wImageBrain" -ref "$WD"/"$T1wImageBrainFile" -omat "$WD"/T2w2T1w.mat 

${FSLDIR}/bin/applywarp --rel --interp=spline --in="$T2wImage" --ref="$T1wImage" --premat="$WD"/T2w2T1w.mat --out="$WD"/T2w2T1w
#${FSLDIR}/bin/applywarp --rel --interp=spline --in="$WD"/T2w2T1w --ref="$T1wImage" --premat="$WD"/T2w2T1w_second.mat --out="$WD"/T2w2T1w

${FSLDIR}/bin/fslmaths "$WD"/T2w2T1w -add 1 "$WD"/T2w2T1w -odt float

cp "$WD"/T2w2T1w.nii.gz "$OutputT2wImage".nii.gz

${FSLDIR}/bin/convertwarp --relout --rel -r "$OutputT2wImage".nii.gz -w $OutputT1wTransform --postmat="$WD"/T2w2T1w.mat --out="$OutputT2wTransform"


FREESURFER_HOME=/disk/HCP/pipeline/external/freesurfer-beta
source $FREESURFER_HOME/SetUpFreeSurfer.sh

${FREESURFER_HOME}/bin/mri_coreg --mov "$OutputT2wImage".nii.gz --ref "$WD"/"$T1wImageBrainFile".nii.gz --reg "$WD"/mricoreg.lta

${FREESURFER_HOME}/bin/lta_convert --inlta "$WD"/mricoreg.lta --outfsl "$WD"/mricoreg.mat

${FREESURFER_HOME}/bin/mri_convert -rt nearest -rl "$WD"/"$T1wImageBrainFile".nii.gz "$OutputT2wImage".nii.gz --apply_transform "$WD"/mricoreg.lta "$OutputT2wImage".nii.gz
${FSLDIR}/bin/convertwarp --relout --rel -r "$OutputT2wImage".nii.gz -w $OutputT2wTransform --postmat="$WD"/mricoreg.mat --out="$OutputT2wTransform"


echo " "
echo " END: T2w2T1Reg"
