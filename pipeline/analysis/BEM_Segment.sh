export SUBJECT=Opt001
export SUBJECTS_DIR=/disk/NIRS/Connectivity_Analysis/Projects/MEG_NIRS/analyzed/$SUBJECT/T1w

export FREESURFER_HOME=/disk/HCP/pipeline/external/freesurfer-stable
export MNE_ROOT=/home/pkg/software/MNE

source $FREESURFER_HOME/SetUpFreeSurfer.sh

source $MNE_ROOT/bin/mne_setup_sh
export PATH=$PATH:$MNE_ROOT/bin

$MNE_ROOT/bin/mne_setup_mri --overwrite
$MNE_ROOT/bin/mne_watershed_bem --atlas --overwrite

cd $SUBJECTS_DIR/$SUBJECT/bem

mkheadsurf -s $SUBJECT
mne_surf2bem --surf ../surf/lh.seghead --id 4 --check --fif ${SUBJECT}-head-dense.fif

cp -v $SUBJECTS_DIR/$SUBJECT/bem/${SUBJECT}_outer_skin_surface $SUBJECTS_DIR/$SUBJECT/bem/outer_skin.surf
cp -v $SUBJECTS_DIR/$SUBJECT/bem/${SUBJECT}_outer_skul_surface $SUBJECTS_DIR/$SUBJECT/bem/outer_skull.surf
cp -v $SUBJECTS_DIR/$SUBJECT/bem/${SUBJECT}_inner_skull_surface $SUBJECTS_DIR/$SUBJECT/bem/inner_skull.surf
cp -v $SUBJECTS_DIR/$SUBJECT/bem/${SUBJECT}_brain_surface $SUBJECTS_DIR/$SUBJECT/bem/brain.surf

python3.5 HCP_mne_bem.py