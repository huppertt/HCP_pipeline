function HCP_HBP_analysis(subjid,outfolder);

curfolder=pwd;
if(nargin<2)
    outfolder= '/disk/HCP/analyzed';
end
try;
cd(outfolder);

HCP_matlab_setenv;

if(isempty(which('HBP_00_unpack_data')))
    path(path,genpath('/disk/HCP/pipeline/external/spm12/'));
    rmpath(genpath('/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox-extra/spm8'));
    path(path,'/aionraid/huppertt/XnatDB/ROS-HBP/HBP_preprocessing/')
end



% warning('off','MATLAB:dispatcher:nameConflict')
% setenv('FSLDIR','/disk/HCP/pipeline/external/fsl/');
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') '/bin/']);
% setenv('PATH',[getenv('PATH') ':' getenv('FSLDIR') filesep 'bin']);

   
      HBP_00_unpack_data(subjid,outfolder);
      HBP_01_coreg_est_reslice(subjid,outfolder);
      HBP_02_segmentation(subjid,outfolder);
      HBP_03_ICV_mask(subjid,outfolder);
      HBP_04_apply_ICV_mask(subjid,outfolder);
      HBP_05_slice_time(subjid,outfolder);
      HBP_06_realign_mc(subjid,outfolder);
      HBP_07_brain_extract_functional(subjid,outfolder);
      HBP_08_coreg_functional(subjid,outfolder);
      HBP_09_warp_to_MNI(subjid,outfolder);
      HBP_09b_warp_to_MNI(subjid,outfolder);
      HBP_09c_warp_to_MNI_FSLwarp(subjid,outfolder);
      HBP_10_smooth_functional(subjid,outfolder);
      HBP_10b_smooth_functional(subjid,outfolder);
      HBP_11_subcortical(subjid,outfolder);
        HBP_11b_subcortical_FSLwarp(subjid,outfolder);
        HBP_12_ventricle_mask(subjid,outfolder);
        HBP_12b_whitematter_mask(subjid,outfolder);
        
        HBP_13_atlas_to_native(subjid,outfolder,0);
        HBP_13b_conn_atlas_to_native(subjid,outfolder);
        HBP_13c_hcp_atlas_to_native(subjid,outfolder);
        HBP_14_extract_timeseries(subjid,outfolder,0);
        HBP_14b_extract_timeseries_conn(subjid,outfolder);
        HBP_14c_extract_timeseries_hcp(subjid,outfolder)       
        HBP_15_calculate_regressors(subjid,outfolder,0)
        HBP_15b_calculate_regressors_conn(subjid,outfolder);
        HBP_15c_calculate_regressors_hcp(subjid,outfolder);
        HBP_16_connectivity(subjid,outfolder);
        HBP_16b_connectivity_conn(subjid,outfolder);
        HBP_16c_connectivity_hcp(subjid,outfolder);
        HBP_17_subnetwork_connectivity(subjid,outfolder);
        HBP_17b_subnetwork_connectivity_conn(subjid,outfolder);
        HBP_17c_subnetwork_connectivity_hcp(subjid,outfolder);
catch
    1
end
cd(curfolder);