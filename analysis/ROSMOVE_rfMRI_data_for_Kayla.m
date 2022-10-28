function ROSMOVE_rfMRI_data_for_Kayla(outfolder)

subs = dir(outfolder);
subjids = {};
for i = 1:length(subs)
    if subs(i).isdir
        subjids = [subjids ; subs(i).name];
    end
end


stack_superregion = [];
subjectID_superregion= {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix_superregions.mat']))
        load(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix_superregions.mat']))
        stack_superregion = cat(3,stack_superregion, r_pearson_res);
        subjectID_superregion = [subjectID_superregion ; subjids{i}];
    end
end

ROIs_superregion = {'cSM_L' 'cSM_R' 'cEX_L' 'cEX_R' 'cLM_L' 'cLM_R' 'scSM_L' 'scSM_R' 'scEX_L' 'scEX_R' 'scLM_L' 'scLM_R' 'HIP_L' 'HIP_R' 'THA_L' 'THA_R'};

stack_full = [];
subjectID_full= {};
for i = 1:length(subjids)
    if exist(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix.mat']))
        load(fullfile(outfolder,subjids{i},'MNINonLinear','Results',[subjids{i} '_rfMRI_conn_matrix.mat']))
        stack_full = cat(3,stack_full, r_pearson_res);
        subjectID_full = [subjectID_full ; subjids{i}];
    end
end

ROIs_full = {'L_V1'	'L_MST'	'L_V6'	'L_V2'	'L_V3'	'L_V4'	'L_V8'	'L_4'	'L_3b'	'L_FEF'	'L_PEF'	'L_55b'	'L_V3A'	'L_RSC'	'L_POS2'	'L_V7'	'L_IPS1'	'L_FFC'	'L_V3B'	'L_LO1'	'L_LO2'	'L_PIT'	'L_MT'	'L_A1'	'L_PSL'	'L_SFL'	'L_PCV'	'L_STV'	'L_7Pm'	'L_7m'	'L_POS1'	'L_23d'	'L_v23ab'	'L_d23ab'	'L_31pv'	'L_5m'	'L_5mv'	'L_23c'	'L_5L'	'L_24dd'	'L_24dv'	'L_7AL'	'L_SCEF'	'L_6ma'	'L_7Am'	'L_7PL'	'L_7PC'	'L_LIPv'	'L_VIP'	'L_MIP'	'L_1'	'L_2'	'L_3a'	'L_6d'	'L_6mp'	'L_6v'	'L_p24pr'	'L_33pr'	'L_a24pr'	'L_p32pr'	'L_a24'	'L_d32'	'L_8BM'	'L_p32'	'L_10r'	'L_47m'	'L_8Av'	'L_8Ad'	'L_9m'	'L_8BL'	'L_9p'	'L_10d'	'L_8C'	'L_44'	'L_45'	'L_47l'	'L_a47r'	'L_6r'	'L_IFJa'	'L_IFJp'	'L_IFSp'	'L_IFSa'	'L_p9-46v'	'L_46'	'L_a9-46v'	'L_9-46d'	'L_9a'	'L_10v'	'L_a10p'	'L_10pp'	'L_11l'	'L_13l'	'L_OFC'	'L_47s'	'L_LIPd'	'L_6a'	'L_i6-8'	'L_s6-8'	'L_43'	'L_OP4'	'L_OP1'	'L_OP2-3'	'L_52'	'L_RI'	'L_PFcm'	'L_PoI2'	'L_TA2'	'L_FOP4'	'L_MI'	'L_Pir'	'L_AVI'	'L_AAIC'	'L_FOP1'	'L_FOP3'	'L_FOP2'	'L_PFt'	'L_AIP'	'L_EC'	'L_PreS'	'L_H'	'L_ProS'	'L_PeEc'	'L_STGa'	'L_PBelt'	'L_A5'	'L_PHA1'	'L_PHA3'	'L_STSda'	'L_STSdp'	'L_STSvp'	'L_TGd'	'L_TE1a'	'L_TE1p'	'L_TE2a'	'L_TF'	'L_TE2p'	'L_PHT'	'L_PH'	'L_TPOJ1'	'L_TPOJ2'	'L_TPOJ3'	'L_DVT'	'L_PGp'	'L_IP2'	'L_IP1'	'L_IP0'	'L_PFop'	'L_PF'	'L_PFm'	'L_PGi'	'L_PGs'	'L_V6A'	'L_VMV1'	'L_VMV3'	'L_PHA2'	'L_V4t'	'L_FST'	'L_V3CD'	'L_LO3'	'L_VMV2'	'L_31pd'	'L_31a'	'L_VVC'	'L_25'	'L_s32'	'L_pOFC'	'L_PoI1'	'L_Ig'	'L_FOP5'	'L_p10p'	'L_p47r'	'L_TGv'	'L_MBelt'	'L_LBelt'	'L_A4'	'L_STSva'	'L_TE1m'	'L_PI'	'L_a32pr'	'L_p24'	'R_V1'	'R_MST'	'R_V6'	'R_V2'	'R_V3'	'R_V4'	'R_V8'	'R_4'	'R_3b'	'R_FEF'	'R_PEF'	'R_55b'	'R_V3A'	'R_RSC'	'R_POS2'	'R_V7'	'R_IPS1'	'R_FFC'	'R_V3B'	'R_LO1'	'R_LO2'	'R_PIT'	'R_MT'	'R_A1'	'R_PSL'	'R_SFL'	'R_PCV'	'R_STV'	'R_7Pm'	'R_7m'	'R_POS1'	'R_23d'	'R_v23ab'	'R_d23ab'	'R_31pv'	'R_5m'	'R_5mv'	'R_23c'	'R_5L'	'R_24dd'	'R_24dv'	'R_7AL'	'R_SCEF'	'R_6ma'	'R_7Am'	'R_7PL'	'R_7PC'	'R_LIPv'	'R_VIP'	'R_MIP'	'R_1'	'R_2'	'R_3a'	'R_6d'	'R_6mp'	'R_6v'	'R_p24pr'	'R_33pr'	'R_a24pr'	'R_p32pr'	'R_a24'	'R_d32'	'R_8BM'	'R_p32'	'R_10r'	'R_47m'	'R_8Av'	'R_8Ad'	'R_9m'	'R_8BL'	'R_9p'	'R_10d'	'R_8C'	'R_44'	'R_45'	'R_47l'	'R_a47r'	'R_6r'	'R_IFJa'	'R_IFJp'	'R_IFSp'	'R_IFSa'	'R_p9-46v'	'R_46'	'R_a9-46v'	'R_9-46d'	'R_9a'	'R_10v'	'R_a10p'	'R_10pp'	'R_11l'	'R_13l'	'R_OFC'	'R_47s'	'R_LIPd'	'R_6a'	'R_i6-8'	'R_s6-8'	'R_43'	'R_OP4'	'R_OP1'	'R_OP2-3'	'R_52'	'R_RI'	'R_PFcm'	'R_PoI2'	'R_TA2'	'R_FOP4'	'R_MI'	'R_Pir'	'R_AVI'	'R_AAIC'	'R_FOP1'	'R_FOP3'	'R_FOP2'	'R_PFt'	'R_AIP'	'R_EC'	'R_PreS'	'R_H'	'R_ProS'	'R_PeEc'	'R_STGa'	'R_PBelt'	'R_A5'	'R_PHA1'	'R_PHA3'	'R_STSda'	'R_STSdp'	'R_STSvp'	'R_TGd'	'R_TE1a'	'R_TE1p'	'R_TE2a'	'R_TF'	'R_TE2p'	'R_PHT'	'R_PH'	'R_TPOJ1'	'R_TPOJ2'	'R_TPOJ3'	'R_DVT'	'R_PGp'	'R_IP2'	'R_IP1'	'R_IP0'	'R_PFop'	'R_PF'	'R_PFm'	'R_PGi'	'R_PGs'	'R_V6A'	'R_VMV1'	'R_VMV3'	'R_PHA2'	'R_V4t'	'R_FST'	'R_V3CD'	'R_LO3'	'R_VMV2'	'R_31pd'	'R_31a'	'R_VVC'	'R_25'	'R_s32'	'R_pOFC'	'R_PoI1'	'R_Ig'	'R_FOP5'	'R_p10p'	'R_p47r'	'R_TGv'	'R_MBelt'	'R_LBelt'	'R_A4'	'R_STSva'	'R_TE1m'	'R_PI'	'R_a32pr'	'R_p24'	'AnteriorVentralStriatum_L'	'PreDorsalCaudate_L'	'PostDorsalCaudate_L'	'AnteriorPutamen_L'	'PosteriorPutamen_L'	'Thalamus_L'	'Amygdala_L'	'Hippocampus_L'	'AnteriorVentralStriatum_R'	'PreDorsalCaudate_R'	'PostDorsalCaudate_R'	'AnteriorPutamen_R'	'PosteriorPutamen_R'	'Thalamus_R'	'Amygdala_R'	'Hippocampus_R'};

save(fullfile(outfolder,'ROSMOVE_resting_state_for_KB.mat'), 'stack_full','subjectID_full','ROIs_full','stack_superregion','subjectID_superregion','ROIs_superregion')