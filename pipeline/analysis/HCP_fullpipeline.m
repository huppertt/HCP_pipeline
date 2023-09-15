folder=pwd;
tbl=HCP_check_analysis([],folder);

for i=1:height(tbl)
    HCP_runall(tbl.Subjid{i},1,folder,true);
    HCP_subcortical(tbl.Subjid{i},folder);
    HCP_sMRI_QC(tbl.Subjid{i},folder);
end
HCP_GroupLevel(folder);
 
for i=1:height(tbl)
    HCP_ASL_perfusion_scaling(tbl.Subjid{i},folder);
    HCP_TRUST_fitting_noPCA(tbl.Subjid{i},folder);   
    HCP_WMH_GPNnew(tbl.Subjid{i},folder);
    HCP_WMH_analysis(tbl.Subjid{i},folder);
end

for i=1:height(tbl)
    try
    stbl{i}=HCP_LPA_WMH_stats(tbl.Subjid{i},folder);
    end
end
HCP_WMHstats(folder);
for i=1:height(tbl)
     HCP_runall(tbl.Subjid{i},3,folder);
    HCP_runall(tbl.Subjid{i},4,folder);
   
%     HCP_resting_state(tbl.Subjid{i},folder);
%     HCP_MSM(tbl.Subjid{i},folder);
%     HCP_make_MSMall_volume_mapping(tbl.Subjid{i},folder);
%     HCP_make_MMPconnectivity(tbl.Subjid{i},folder);
    HCP_HBP_analysis(tbl.Subjid{i},folder);
    
%     HCP_atlas_surface_to_volume_conversion(tbl.Subjid{i},folder);
%     HCP_rfMRI_extract_MMP_tc(tbl.Subjid{i},folder);
%     HCP_rfMRI_MMP_conn_matrix_alldays_clean(tbl.Subjid{i},folder);
%     HCP_characterize_rfMRI_connectivity_alldays_wmh(tbl.Subjid{i},folder);
    
    %HCP_dsistudio_ROSMOVE(tbl.Subjid{i},folder);
    %HCP_characterize_wmh_dti_tables_multi_network(tbl.Subjid{i},folder);
    ROSMOVE_excel_gen2(tbl.Subjid{i},folder);
end
 
ROS369_report_scaninfo_new(folder);
HCP_MakeSummary(folder);
HCP_MMP_statsAll(folder);


			


