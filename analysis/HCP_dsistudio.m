function HCP_dsistudio(subjid,outfolder,force)


HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    force=false;
end

if(isempty(rdir(fullfile(outfolder,subjid,'T1w',subjid,'dmri','data.nii.*'))))
    warning(['Stage 2 not run yet: ' subjid]);
    return
end




if(ismac)
    [~,whoami]=system('whoami');
     dsiroot = ['/Applications/dsi_studio.app/Contents/MacOS/'];
    % dsiroot = ['/Applications/dsi_studio_Feb2020.app/Contents/MacOS/'];
    %dsiroot = ['/Applications/dsi_studio_Mar2020.app/Contents/MacOS/'];
    
end

HCP_matlab_setenv

if~(exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri',[subjid '_dsistudio.trk.gz']),'file') & ~force)

    %% Data copying and resampling
    % Copy relevant images to local dir
    system('cp ../T1w_acpc_dc_restore_brain.nii.gz ./T1w_brain.nii.gz');
    system('cp ../T2w_acpc_dc_restore_brain.nii.gz ./T2w_brain.nii.gz');
    system('cp ../T1w_acpc_brain_mask.nii.gz ./brain_mask.nii.gz');
    system('cp ../subcortical/subcortical_all_fast_firstseg.nii.gz ./subcortical_seg.nii.gz');
    
    if(~exist('data.nii.gz'))
        return
    end
    
    %  Resample the images to dMRI resolution
    system('fslmaths ./data.nii.gz -Tmean ./dataMean.nii.gz');
    system('/usr/local/fsl/bin/flirt -in ./T2w_brain.nii.gz -ref ./dataMean.nii.gz -out ./T2w_brain_dsi.nii.gz -nosearch  -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat');  % Downsample T2 to dMRI res
    system('/usr/local/fsl/bin/flirt -in ./brain_mask.nii.gz -ref ./dataMean.nii.gz -out ./brain_mask_dsi.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat'); % Downsample mask to dMRI res
    system('/usr/local/fsl/bin/flirt -in ./T1w_brain.nii.gz -ref ./dataMean.nii.gz -out ./T1w_brain_dsi.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat');   % Downsample T1 to dMRI res
    system('/usr/local/fsl/bin/flirt -in ./subcortical_seg.nii.gz -ref ./dataMean.nii.gz -out ./subcortical_seg_dsi.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat -interp nearestneighbour');
%     system('/usr/local/fsl/bin/fslmaths brain_mask_dsi.nii.gz -kernel sphere 3 -dilM -fillh -bin brain_mask_dsi.nii.gz'); % added dilation to capture missing cortex
    
    % Alternatively, resample dMRI data to T1 res
    system('/usr/local/fsl/bin/flirt -in ./dataMean.nii.gz -ref ./T1w_brain.nii.gz -out ./dataMean_hires.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat'); % Upsample dMRI data to T1 res
    system('/usr/local/fsl/bin/flirt -in ./data.nii.gz -ref ./T1w_brain.nii.gz -out ./data_hires.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat'); % Upsample dMRI data to T1 res
%     system('/usr/local/fsl/bin/fslmaths brain_mask.nii.gz -kernel sphere 3 -dilM -fillh -bin brain_mask.nii.gz'); % added dilation to capture missing cortex
    system('/usr/local/fsl/bin/flirt -in ./subcortical_seg.nii.gz -ref ./T1w_brain.nii.gz -out ./subcortical_seg.nii.gz -nosearch -applyxfm -init /usr/local/fsl/etc/flirtsch/ident.mat -interp nearestneighbour');
    
    
    
    
    
    
    
    
    %% Atlas preparation
    % Warp MNI subcortical and AAL atlases to native space
    system(['applywarp'...
        ' --ref=' fullfile(outfolder,subjid,'T1w',subjid,'dmri','T1w_brain.nii.gz')...
        ' --in='  fullfile(dsiroot,'atlas','ICBM152','AAL2.nii.gz')...
        ' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'standard2acpc_dc.nii.gz')...
        ' --out=' fullfile(outfolder,subjid,'T1w',subjid,'dmri','AAL2_native.nii.gz')...
        ' --interp=nn'
        ]);
    
%     system(['applywarp'...
%         ' --ref=' fullfile(outfolder,subjid,'T1w',subjid,'dmri','T1w_brain.nii.gz')...
%         ' --in='  fullfile(dsiroot,'atlas','HarvardOxfordSub.nii.gz')...
%         ' --warp=' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'standard2acpc_dc.nii.gz')...
%         ' --out=' fullfile(outfolder,subjid,'T1w',subjid,'dmri','HarvardOxfordSub_native.nii.gz')...
%         ' --interp=nn'
%         ]);
    
    % Create blank nii file my_ROIs.nii.gz
    system(['fslmaths '...
        fullfile(outfolder,subjid,'T1w',subjid,'dmri','T1w_brain.nii.gz')...
        ' -thr 0 -uthr 0 '...
        fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz')
        ]);
    
    % Regions we want from AAL2 atlas:
    AAL2ROI = {
        '1' 'Precentral_L'          '1'
        '2' 'Precentral_R'          '2'
        '15' 'Supp_Motor_Area_L'    '3'
        '16' 'Supp_Motor_Area_R'    '4'
        '61' 'Postcentral_L'        '5'
        '62' 'Postcentral_R'        '6'}; 
    
    for i = 1:length(AAL2ROI) % This loop generates native space my_ROI.nii.gz
        system(['fslmaths '...
            fullfile(outfolder,subjid,'T1w',subjid,'dmri','AAL2_native.nii.gz')...
            ' -thr ' AAL2ROI{i,1} ' -uthr '  AAL2ROI{i,1} ' -bin -mul ' AAL2ROI{i,3}...
            ' -add ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz')...
            ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz')...
            ]);
    end

    
    % Regions we want from HarvardOxfordSub:
    
%     SubCortROI = {
%         '10' 'Left_Thalamus'        '7'
%         '11' 'Left_Caudate'         '8'
%         '12' 'Left_Putamen'         '9'
%         '13' 'Left_Pallidum'        '10'
%         '26' 'Left_Accumbens'       '11'
%         '49' 'Right_Thalamus'       '12'
%         '50' 'Right_Caudate'        '13'
%         '51' 'Right_Putamen'        '14'
%         '52' 'Right_Pallidum'       '15'
%         '58' 'Right_Accumbens'      '16'};
%     
%     for i = 1:length(SubCortROI) % This loop generates native space my_ROI.nii.gz
%         system(['fslmaths '...
%             fullfile(outfolder,subjid,'T1w',subjid,'dmri','HarvardOxfordSub_native.nii.gz')...
%             ' -thr ' SubCortROI{i,1} ' -uthr '  SubCortROI{i,1} ' -bin -mul ' SubCortROI{i,3}...
%             ' -add ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','my_ROIs.nii.gz')...
%             ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','my_ROIs.nii.gz')...
%             ]);
%     end


    
    % Regions from personal segmentation
    
        SegROI = {
        '10' 'Left_Thalamus'        '7'
        '11' 'Left_Caudate'         '8'
        '12' 'Left_Putamen'         '9'
        '13' 'Left_Pallidum'        '10'
        '26' 'Left_Accumbens'       '11'
        '49' 'Right_Thalamus'       '12'
        '50' 'Right_Caudate'        '13'
        '51' 'Right_Putamen'        '14'
        '52' 'Right_Pallidum'       '15'
        '58' 'Right_Accumbens'      '16'};
    
        for i = 1:length(SegROI)
        system(['fslmaths '...
            fullfile(outfolder,subjid,'T1w',subjid,'dmri','subcortical_seg.nii.gz')...
            ' -thr ' SegROI{i,1} ' -uthr '  SegROI{i,1} ' -bin -mul ' SegROI{i,3}...
            ' -add ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz')...
            ' ' fullfile(outfolder,subjid,'T1w',subjid,'dmri','HCP-MMP_subcort_atlas.nii.gz')...
            ]);
        end

    
        
        
        text = [AAL2ROI(:,3) AAL2ROI(:,2);SegROI(:,3) SegROI(:,2)];
        writecell(text,'HCP-MMP_subcort_atlas.txt', 'Delimiter', 'tab')
        
        
        
    if(~ismac)
        return
    end
    
  %% DSI Studio execution  
    if(~exist([ subjid '_dsistudio.fib.gz']) || force)
        
        if(exist([subjid '_dsistudio.src.gz']))
            system(['rm ' subjid '_dsistudio.src.gz']);
        end
        
        %         system([ dsiroot filesep 'dsi_studio --action=src ' ...
        %             '--source=data.nii.gz --bval=bvals --bvec=bvecs --output=' subjid '_dsistudio.src.gz']);
        
        system([ dsiroot filesep 'dsi_studio --action=src ' ...
            '--source=data_hires.nii.gz --bval=bvals --bvec=bvecs --output=' subjid '_dsistudio.src.gz']);
        
        if(exist([ subjid '_dsistudio.fib.gz']))
            delete([ subjid '_dsistudio.fib.gz'])
        end
        %         system([dsiroot filesep 'dsi_studio --action=rec --source=' subjid '_dsistudio.src.gz --mask=brain_mask_dsi.nii.gz '...
        %             '--method=7 --deconvolution=1 --param0=1.25 --record_odf=1 --reg_method=2 --param1=1 --thread_count=12 --output_jac=1 --output_mapping=1 ']);  % --output_mapping=1 for mapping of data to MNI space?
        
        %This version of action=rec tajes the hi-res upsampled dMRI data.
        system([dsiroot filesep 'dsi_studio --action=rec --source=' subjid '_dsistudio.src.gz  --mask=brain_mask.nii.gz '...
            '--method=7 --deconvolution=1 --param0=1.25 --record_odf=1 --reg_method=2 --param1=1 --thread_count=8 --output_jac=1 --output_mapping=1 '...
            '--other_image=T1w_brain.nii.gz,T2w_brain.nii.gz ']);
        %
        
        f=dir([ subjid '_dsistudio*.fib.gz']);
        movefile(f(1).name,[ subjid '_dsistudio.fib.gz']);
        
    end
    
    if(~exist([subjid '_dsistudio.trk.gz'],'file') || force)
        system([dsiroot filesep 'dsi_studio --action=trk --source=' subjid '_dsistudio.fib.gz '...
            '--method=0 --seed_count=1000000 --thread_count=12 --output=' subjid '_dsistudio.trk']);  % 10000000 = ~ 1hour 25000000
    end
else
    disp(['skipping tracking ' subjid]);
end

if(~exist([subjid '_dsistudio.trk.gz.stat.txt'],'file') || force)
    system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
        '--tract=' subjid '_dsistudio.trk.gz --export=stat,tdi,tdi2,qa,gfa']);
end

if(~exist([subjid '_dsistudio.fib.gz.FreeSurferDKT.qa.pass.network_measures.txt'],'file') || force)
    system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
        '--tract=' subjid '_dsistudio.trk.gz --connectivity=ICBM152/FreeSurferDKT,ICBM152/HCP-MMP --connectivity_value=qa,count,ncount '...
        '--connectivity_type=pass,end']);
end

if(~exist([subjid '_dsistudio.fib.gz.aal.qa.pass.network_measures.txt'],'file') || force)
    system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
        '--tract=' subjid '_dsistudio.trk.gz --connectivity=ICBM152/AAL2,ICBM152/Gordan_rsfMRI333,ICBM152/HarvardOxfordSub --connectivity_value=qa,count,ncount '...
        '--connectivity_type=pass,end']);
end


if(~exist([subjid '_dsistudio.fib.gz.HCP-MMP_subcort_atlas.qa.pass.network_measures.txt'],'file') || force)
    system([dsiroot filesep 'dsi_studio --action=ana --source=' subjid '_dsistudio.fib.gz '...
        '--tract=' subjid '_dsistudio.trk.gz --connectivity=HCP-MMP_subcort_atlas.nii.gz --connectivity_value=qa,count,ncount '...
        '--connectivity_type=pass,end']);
end

%,WaveletROI.nii.gz
