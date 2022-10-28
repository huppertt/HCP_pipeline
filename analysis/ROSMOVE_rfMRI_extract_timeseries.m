function [tc_data] = ROSMOVE_rfMRI_extract_MMP_tc(subjid, outfolder, force)

if(nargin<3)
    force=false;
end

HCP_matlab_setenv
fsldir = '/disk/HCP/pipeline/external/fslnew';

if exist(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_MMP_CIC_timecourses.mat']),'file') & force==false
   disp([subjid ' alread completed and force = 0. Skipping.'])
   return
end

% This section copies the MMP-CIC atlas to resting state MNI resolution
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w',subjid))
if ~(exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz'),'file') & ~force)
    
    disp('Creating MMP-CIC atlas')
    
    % Reslice MMP atlas to subject MNI
    
    system(['mri_vol2vol '...
        ' --targ ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore_brain.nii.gz')...
        ' --regheader --interp nearest '...
        ' --mov '  fullfile('/aionraid','huppertt','XnatDB','ROS-HBP','HBP_preprocessing','atlas','HCP-MMP.nii.gz')...
        ' --o ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_resampled.nii.gz')...
        ]);
    
    mmp_labels = ...
        {'1','L_V1';'2','L_MST';'3','L_V6';'4','L_V2';'5','L_V3';'6','L_V4';'7','L_V8';'8','L_4';'9','L_3b';'10','L_FEF';'11','L_PEF';'12','L_55b';'13','L_V3A';'14','L_RSC';'15','L_POS2';'16','L_V7';'17','L_IPS1';'18','L_FFC';'19','L_V3B';'20','L_LO1';'21','L_LO2';'22','L_PIT';'23','L_MT';'24','L_A1';'25','L_PSL';'26','L_SFL';'27','L_PCV';'28','L_STV';'29','L_7Pm';'30','L_7m';'31','L_POS1';'32','L_23d';'33','L_v23ab';'34','L_d23ab';'35','L_31pv';'36','L_5m';'37','L_5mv';'38','L_23c';'39','L_5L';'40','L_24dd';'41','L_24dv';'42','L_7AL';'43','L_SCEF';'44','L_6ma';'45','L_7Am';'46','L_7PL';'47','L_7PC';'48','L_LIPv';'49','L_VIP';'50','L_MIP';'51','L_1';'52','L_2';'53','L_3a';'54','L_6d';'55','L_6mp';'56','L_6v';'57','L_p24pr';'58','L_33pr';'59','L_a24pr';'60','L_p32pr';'61','L_a24';'62','L_d32';'63','L_8BM';'64','L_p32';'65','L_10r';'66','L_47m';'67','L_8Av';'68','L_8Ad';'69','L_9m';'70','L_8BL';'71','L_9p';'72','L_10d';'73','L_8C';'74','L_44';'75','L_45';'76','L_47l';'77','L_a47r';'78','L_6r';'79','L_IFJa';'80','L_IFJp';'81','L_IFSp';'82','L_IFSa';'83','L_p9-46v';'84','L_46';'85','L_a9-46v';'86','L_9-46d';'87','L_9a';'88','L_10v';'89','L_a10p';'90','L_10pp';'91','L_11l';'92','L_13l';'93','L_OFC';'94','L_47s';'95','L_LIPd';'96','L_6a';'97','L_i6-8';'98','L_s6-8';'99','L_43';'100','L_OP4';'101','L_OP1';'102','L_OP2-3';'103','L_52';'104','L_RI';'105','L_PFcm';'106','L_PoI2';'107','L_TA2';'108','L_FOP4';'109','L_MI';'110','L_Pir';'111','L_AVI';'112','L_AAIC';'113','L_FOP1';'114','L_FOP3';'115','L_FOP2';'116','L_PFt';'117','L_AIP';'118','L_EC';'119','L_PreS';'120','L_H';'121','L_ProS';'122','L_PeEc';'123','L_STGa';'124','L_PBelt';'125','L_A5';'126','L_PHA1';'127','L_PHA3';'128','L_STSda';'129','L_STSdp';'130','L_STSvp';'131','L_TGd';'132','L_TE1a';'133','L_TE1p';'134','L_TE2a';'135','L_TF';'136','L_TE2p';'137','L_PHT';'138','L_PH';'139','L_TPOJ1';'140','L_TPOJ2';'141','L_TPOJ3';'142','L_DVT';'143','L_PGp';'144','L_IP2';'145','L_IP1';'146','L_IP0';'147','L_PFop';'148','L_PF';'149','L_PFm';'150','L_PGi';'151','L_PGs';'152','L_V6A';'153','L_VMV1';'154','L_VMV3';'155','L_PHA2';'156','L_V4t';'157','L_FST';'158','L_V3CD';'159','L_LO3';'160','L_VMV2';'161','L_31pd';'162','L_31a';'163','L_VVC';'164','L_25';'165','L_s32';'166','L_pOFC';'167','L_PoI1';'168','L_Ig';'169','L_FOP5';'170','L_p10p';'171','L_p47r';'172','L_TGv';'173','L_MBelt';'174','L_LBelt';'175','L_A4';'176','L_STSva';'177','L_TE1m';'178','L_PI';'179','L_a32pr';'180','L_p24';'181','R_V1';'182','R_MST';'183','R_V6';'184','R_V2';'185','R_V3';'186','R_V4';'187','R_V8';'188','R_4';'189','R_3b';'190','R_FEF';'191','R_PEF';'192','R_55b';'193','R_V3A';'194','R_RSC';'195','R_POS2';'196','R_V7';'197','R_IPS1';'198','R_FFC';'199','R_V3B';'200','R_LO1';'201','R_LO2';'202','R_PIT';'203','R_MT';'204','R_A1';'205','R_PSL';'206','R_SFL';'207','R_PCV';'208','R_STV';'209','R_7Pm';'210','R_7m';'211','R_POS1';'212','R_23d';'213','R_v23ab';'214','R_d23ab';'215','R_31pv';'216','R_5m';'217','R_5mv';'218','R_23c';'219','R_5L';'220','R_24dd';'221','R_24dv';'222','R_7AL';'223','R_SCEF';'224','R_6ma';'225','R_7Am';'226','R_7PL';'227','R_7PC';'228','R_LIPv';'229','R_VIP';'230','R_MIP';'231','R_1';'232','R_2';'233','R_3a';'234','R_6d';'235','R_6mp';'236','R_6v';'237','R_p24pr';'238','R_33pr';'239','R_a24pr';'240','R_p32pr';'241','R_a24';'242','R_d32';'243','R_8BM';'244','R_p32';'245','R_10r';'246','R_47m';'247','R_8Av';'248','R_8Ad';'249','R_9m';'250','R_8BL';'251','R_9p';'252','R_10d';'253','R_8C';'254','R_44';'255','R_45';'256','R_47l';'257','R_a47r';'258','R_6r';'259','R_IFJa';'260','R_IFJp';'261','R_IFSp';'262','R_IFSa';'263','R_p9-46v';'264','R_46';'265','R_a9-46v';'266','R_9-46d';'267','R_9a';'268','R_10v';'269','R_a10p';'270','R_10pp';'271','R_11l';'272','R_13l';'273','R_OFC';'274','R_47s';'275','R_LIPd';'276','R_6a';'277','R_i6-8';'278','R_s6-8';'279','R_43';'280','R_OP4';'281','R_OP1';'282','R_OP2-3';'283','R_52';'284','R_RI';'285','R_PFcm';'286','R_PoI2';'287','R_TA2';'288','R_FOP4';'289','R_MI';'290','R_Pir';'291','R_AVI';'292','R_AAIC';'293','R_FOP1';'294','R_FOP3';'295','R_FOP2';'296','R_PFt';'297','R_AIP';'298','R_EC';'299','R_PreS';'300','R_H';'301','R_ProS';'302','R_PeEc';'303','R_STGa';'304','R_PBelt';'305','R_A5';'306','R_PHA1';'307','R_PHA3';'308','R_STSda';'309','R_STSdp';'310','R_STSvp';'311','R_TGd';'312','R_TE1a';'313','R_TE1p';'314','R_TE2a';'315','R_TF';'316','R_TE2p';'317','R_PHT';'318','R_PH';'319','R_TPOJ1';'320','R_TPOJ2';'321','R_TPOJ3';'322','R_DVT';'323','R_PGp';'324','R_IP2';'325','R_IP1';'326','R_IP0';'327','R_PFop';'328','R_PF';'329','R_PFm';'330','R_PGi';'331','R_PGs';'332','R_V6A';'333','R_VMV1';'334','R_VMV3';'335','R_PHA2';'336','R_V4t';'337','R_FST';'338','R_V3CD';'339','R_LO3';'340','R_VMV2';'341','R_31pd';'342','R_31a';'343','R_VVC';'344','R_25';'345','R_s32';'346','R_pOFC';'347','R_PoI1';'348','R_Ig';'349','R_FOP5';'350','R_p10p';'351','R_p47r';'352','R_TGv';'353','R_MBelt';'354','R_LBelt';'355','R_A4';'356','R_STSva';'357','R_TE1m';'358','R_PI';'359','R_a32pr';'360','R_p24'};
    
    mmp     = load_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_resampled.nii.gz'));
    atlas = mmp; atlas.img = nan(size(atlas.img));
    
    for i  = 1:length(mmp_labels)
        idx =mmp.img == str2num(mmp_labels{i,1});
        atlas.img(idx) = str2num(mmp_labels{i,1});
    end
    
    % Reslice CIC atlas to subject MNI
    setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w',subjid))
    system(['mri_vol2vol '...
        ' --targ ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore_brain.nii.gz')...
        ' --regheader --interp nearest '...
        ' --mov '  fullfile('/aionraid','huppertt','XnatDB','ROS-HBP','HBP_preprocessing','atlas','CIC_LR_atlas.nii')...
        ' --o ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','CIC_resampled.nii.gz')...
        ]);
    
    % Load resampled CIC
    cic_atlas     = load_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','CIC_resampled.nii.gz'));
    
    cic_labels = {'5'	'AnteriorVentralStriatum_L' '361';
        '10'	'PreDorsalCaudate_L' '362';
        '15'	'PostDorsalCaudate_L' '363';
        '20'	'AnteriorPutamen_L' '364';
        '25'	'PosteriorPutamen_L' '365';
        '60'	'Thalamus_L' '366';
        '75'	'Amygdala_L' '367';
        '85'	'Hippocampus_L' '368';
        '105'	'AnteriorVentralStriatum_R' '369';
        '110'	'PreDorsalCaudate_R' '370';
        '115'	'PostDorsalCaudate_R' '371';
        '120'	'AnteriorPutamen_R' '372';
        '125'	'PosteriorPutamen_R' '373';
        '160'	'Thalamus_R' '374';
        '175'	'Amygdala_R' '375';
        '185'	'Hippocampus_R' '376'};
    
    for i  = 1:length(cic_labels)
        idx =cic_atlas.img == str2num(cic_labels{i,1});
        atlas.img(idx) = str2num(cic_labels{i,3});
    end
    
    save_nii(atlas,fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz'));
    
    
    % Create text file that has label names (DSI Studio will use this)
    text = [mmp_labels(:,1) mmp_labels(:,2) ; cic_labels(:,3) cic_labels(:,2)];
    % writecell(text,'HCP-MMP_subcort_atlas.txt', 'Delimiter', 'tab')
    writetable(cell2table(text),fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.txt'), 'Delimiter', 'tab')
end


%Check if atlas are present/output is missing.



if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz'),'file')
    disp([subjid ' atlas missing.'])
    return
end

% Create vars to store timecourses and regressors for subject
tc_data = struct;

% For each resting state scan (e.g., REST1_AP, REST1_PA, REST2_AP,...):
scans = dir(fullfile(outfolder,subjid,'MNINonLinear','Results','*REST_*/'));
scans(contains({scans.name},'_2'))=[]; % Remove multiple scans

runs = {scans.name};

% Resample atlas to BOLD resolution
system(['mri_vol2vol '...
    ' --targ ' fullfile(outfolder,subjid,'MNINonLinear','Results',runs{1},[runs{1} '_hp2000.nii.gz'])...
    ' --regheader --interp nearest '...
    ' --mov ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz') ...
    ' --o ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz') ...
    ]);

% Resample aparc to BOLD resolution
system(['mri_vol2vol '...
    ' --targ ' fullfile(outfolder,subjid,'MNINonLinear','Results',runs{1},[runs{1} '_hp2000.nii.gz'])...
    ' --regheader --interp nearest '...
    ' --mov ' fullfile(outfolder,subjid,'MNINonLinear','aparc+aseg.nii.gz') ...
    ' --o ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','aparc+aseg_resample.nii.gz') ...
    ]);

% Load atlas
atlas = load_untouch_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','MMP_CIC_atlas_MNI.nii.gz'));
atlas=atlas.img;

% Load aseg+aparc
aseg = load_untouch_nii(fullfile(outfolder,subjid,'T1w',subjid,'dmri','aparc+aseg_resample.nii.gz'));
aseg=aseg.img;


motionpars = [];
BOLD_base = [];

for r = 1:length(runs)
    
    
    if ~exist(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '_hp2000.nii.gz'])) | ...
            ~exist(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},'Movement_Regressors.txt'),'file')
        disp('Missing data or motion regressors.')
        return;
    end
    
    BOLD = load_untouch_nii(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},[runs{r} '_hp2000.nii.gz']));
    BOLD_base = cat(4,BOLD_base,BOLD.img);
    
    motionpars = [motionpars ; load(fullfile(outfolder,subjid,'MNINonLinear','Results',runs{r},'Movement_Regressors.txt'))];
    
end


    
    disp([subjid ' beginning tc extraction'])
    tc_data.subjid = subjid;
    
        tc_data.motionregs = motionpars;
    
    
    % Extract data from these images by comparing with atlas
    % CURRENTLY HARD-CODED FOR 376 ROIS
            
        if size(BOLD_base,4) ~= 170*2
            disp(['Number of raw TRs different than expected: ' num2str(size(BOLD_base,4))])
        end
        
        % Loop over all voxels, storing coord and value for each label
        display(['Collecting raw tc' ])
        tic
        max_size = floor(numel(atlas)/20);
        % Loop over 376 Cortical + subcortical regions
        for l = 1:376
            dat_matrix_raw = NaN(max_size,size(BOLD_base,4)); % Prealloc to save time
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if atlas(i,j,k) == l
                            dat_matrix_raw(d,:)   = squeeze(BOLD_base(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_raw(any(isnan(dat_matrix_raw),2),:) = [];
            tc_data.raw_tc(l).dat = mean(dat_matrix_raw,1);
            %toc
            
            % Regress out motion for raw data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).raw_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).raw_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).raw_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        % Loop over WM and ventricles
        
        for l = 377:380
            idx = [2 41 4 43];
            %disp(['Collecting data for run ' num2str(r) ' ROI number ' num2str(l) ])
            %tic
            dat_matrix_raw = NaN(max_size,size(BOLD_base,4)); % Prealloc to save time
            d = 1;
            for i = 1:size(BOLD_base,1)
                for j = 1:size(BOLD_base,2)
                    for k = 1:size(BOLD_base,3)
                        if aseg(i,j,k) == idx(l-376)
                            dat_matrix_raw(d,:)   = squeeze(BOLD_base(i,j,k,:))';
                            d = d+1;
                            if d > max_size
                                display('Index higher than max num voxels?')
                            end
                        end
                    end
                end
            end
            
            dat_matrix_raw(any(isnan(dat_matrix_raw),2),:) = [];
            tc_data.raw_tc(l).dat = mean(dat_matrix_raw,1);
            %toc
            
            % Regress out motion for raw data
%             if ~isempty(tc_data(r).motionregs)
%                 y = tc_data(r).raw_tc(l).dat'; % data equals t-by-n BOLD values (discard first few TRs)
%                 regs = [ones(length(tc_data(r).motionregs),1) tc_data(r).motionregs];
%                 betas = inv(regs'*regs)*regs'*y;
%                 resids = y - regs*betas; % Compute residuals
%                 tc_data(r).raw_tc(l).resids = mean(resids',1); % Store residuals for analysis
%             else
%                 tc_data(r).raw_tc(l).resids = []; % Store residuals for analysis
%             end
            
        end
        
        toc

   


disp([subjid ' saving file'])
tic
save(fullfile(outfolder,subjid,'MNINonLinear','Results',[subjid '_MMP_CIC_timecourses.mat']),'-v7.3','tc_data')
toc