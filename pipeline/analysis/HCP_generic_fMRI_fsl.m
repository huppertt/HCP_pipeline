function HCP_generic_fMRI_fsl(subjid,outfolder,filename)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;

LevelOneTasks='ep2d_bold_MN1@ep2d_bold_MN2@ep2d_bold_MN3@ep2d_bold_MN4';
LevelOneFSFs='ep2d_bold_MN1@ep2d_bold_MN2@ep2d_bold_MN3@ep2d_bold_MN4';

LevelTwoTask='ep2d_bold_MN';
LevelTwoFSF='ep2d_bold_MN';


SmoothingList='2'; %#Space delimited list for setting different final smoothings.  2mm is no more smoothing (above minimal preprocessing pipelines grayordinates smoothing).  Smoothing is added onto minimal preprocessing smoothing to reach desired amount
LowResMesh='32'; % #32 if using HCP minimal preprocessing pipeline outputs
GrayOrdinatesResolution='2'; % #2mm if using HCP minimal preprocessing pipeline outputs
OriginalSmoothingFWHM='2'; % #2mm if using HCP minimal preprocessing pipeline outputes
Confound='NONE'; %#File located in ${SubjectID}/MNINonLinear/Results/${fMRIName} or NONE
TemporalFilter='200'; %#Use 2000 for linear detrend, 200 is default for HCP task fMRI
VolumeBasedProcessing='NO'; % #YES or NO. CAUTION: Only use YES if you want unconstrained volumetric blurring of your data, otherwise set to NO for faster, less biased, and more senstive processing (grayordinates results do not use unconstrained volumetric blurring and are always produced).
RegNames='NONE'; % # Use NONE to use the default surface registration
Parcellation='NONE'; %# Use NONE to perform dense analysis, non-greyordinates parcellations are not supported because they are not valid for cerebral cortex.  Parcellation superseeds smoothing (i.e. smoothing is done)
ParcellationFile='NONE'; % # Absolute path the parcellation dlabel file

HCPPIPEDIR='/disk/HCP/pipeline/projects/Pipelines';

str=[HCPPIPEDIR '/TaskfMRIAnalysis/TaskfMRIAnalysis.sh '...
    ' --path=' outfolder ' --subject=' subjid ...
    ' --lvl1tasks=' LevelOneTasks ...
    ' --lvl1fsfs=' LevelOneFSFs ...
    ' --lvl2task=' LevelTwoTask ...
    ' --lvl2fsf=' LevelTwoFSF ...
    ' --lowresmesh=' LowResMesh ...
    ' --grayordinatesres=' GrayOrdinatesResolution ...
    ' --origsmoothingFWHM=' OriginalSmoothingFWHM ...
    ' --confound=' Confound ...
    ' --finalsmoothingFWHM=' SmoothingList ...
    ' --temporalfilter=' TemporalFilter ...
    ' --vba=' VolumeBasedProcessing ...
    ' --regname=' RegNames ...
    ' --parcellation=' Parcellation ...
    ' --parcellationfile=' ParcellationFile];