function HCP_T2FLAIR_registration(subjid,outfolder)


HCProot='/disk/HCP';

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

if(exist(fullfile(outfolder,subjid,'MNINonLinear',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']))~=0)
    disp(['skipping ' subjid]);
    return;
end

disp([' Beginning T2FLAIR registration for subject ' outfolder '/' subjid '.'])

if exist( fullfile(outfolder,subjid,'unprocessed','3T','T2FLAIR' ) , 'dir' ) % Check if FLAIR data is available in unprocessed folder
    
    % Make FLAIR dir in main subject dir
    system([ 'mkdir -p -m 777 ' fullfile(outfolder,subjid,'T2FLAIR')]);
    
    % Copy unprocessed FLAIR data into new dir
    file = dir(fullfile(outfolder,subjid,'unprocessed','3T','T2FLAIR' ));
    for i = 3:length(file)
        copyfile( fullfile(outfolder,subjid,'unprocessed','3T','T2FLAIR', file(i).name ) ,...
            fullfile(outfolder,subjid,'T2FLAIR', file(i).name ) );
    end
    
%     % Copy data and append _gdc
%     for i = 3:length(file)
%         if strfind(file(i).name,'T2FLAIR')
%             f = strsplit(file(i).name,'.');
%             copyfile( fullfile(outfolder,subjid,'T2FLAIR', file(i).name ) ,...
%                 fullfile(outfolder,subjid,'T2FLAIR', [f{1} '_gdc.nii.gz'] ) );
%         end
%     end
    
%     % Distortion correction if fieldmaps exist
%     if exist( fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude.nii.gz']) ,'file')...
%             & exist( fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapPhase.nii.gz']) , 'file')
%         
%         % Extract brain from magnitude image (required for fsl_prepare_fieldmap)
%         system(['bet'...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude.nii.gz'])...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain']) ...
%             ' -n -m -f 0.6 -R'
%             ]);
%         
%         % Erode resulting  mask to remove noisy edge voxels of field map
%         system(['fslmaths' ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz']) ...
%             ' -kernel box 5 -ero -fillh'  ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz'])...
%             ]);
%         
%         % Apply eroded mask to field magnitude for use in fsl_prepare_fieldmap
%         system(['fslmaths' ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain.nii.gz']) ...
%             ' -mul '  fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz'])...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain.nii.gz'])...
%             ]);
%         
%         % Convert field map to rads/s
%         system(['fsl_prepare_fieldmap SIEMENS' ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapPhase.nii.gz']) ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_FieldMapMagnitude_brain.nii.gz']) ...
%             ' ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_fmap_rads.nii.gz']) ...
%             ' 2.65 ']);
%         
%         % Correct distortion with FUGUE
%         system(['fugue ' ...
%             ' -i '          fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz'])...
%             ' --loadfmap='  fullfile(outfolder,subjid,'T2FLAIR',[subjid '_fmap_rads.nii.gz'])...
%             ' --dwell=0.0001 ' ... % Placeholder. Dwell time/echo spacing for FLAIR seq is needed
%             ' -u '          fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_gdc.nii.gz'])...
%             ]);
%         
%         
%     else  % Else make copy of FLAIR data with "_gdc" appended
%         for i = 3:length(file)
%             if strfind(file(i).name,'T2FLAIR')
%                 f = strsplit(file(i).name,'.');
%                 copyfile( fullfile(outfolder,subjid,'T2FLAIR', file(i).name ) ,...
%                     fullfile(outfolder,subjid,'T2FLAIR', [f{1} '_gdc.nii.gz'] ) );
%             end
%         end
%     end
    
    % Copy distortion-corrected T1 to FLAIR dir
    copyfile( fullfile(outfolder,subjid ,'T1w','T1w1_gdc.nii.gz') ,...
        fullfile(outfolder,subjid ,'T2FLAIR','T1w1_gdc.nii.gz'));
    
    % Linear registration of distortion-corrected FLAIR data to T1 data. 
    system( ['flirt -dof 6 -cost mutualinfo'...
        ' -in ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR.nii.gz'])...
        ' -ref ' fullfile(outfolder,subjid,'T2FLAIR','T1w1_gdc.nii.gz')...
        ' -out ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR2T1.nii.gz'])...
        ' -omat ' fullfile(outfolder,subjid,'T2FLAIR','FLAIR_2_T1.mat')...
        ] );
    
    % Apply series of transforms T1w1_gdc->T1w_restore to registered FLAIR data to get it to
    % MNI space
    system( ['flirt -applyxfm'...                                                               % Apply linear transform to acpc space
        ' -in ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR2T1.nii.gz'])...
        ' -ref ' fullfile(outfolder,subjid,'T1w','ACPCAlignment','acpc_final.nii.gz')...
        ' -out ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz'])...
        ' -init ' fullfile(outfolder,subjid,'T1w','xfms', 'acpc.mat')] );
    
    system( ['applywarp '...                                                                    % Apply warp from acpc space to MNI space
        ' -i ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz'])...
        ' -r ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz')...
        ' -o ' fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz'])...
        ' -w ' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'acpc_dc2standard.nii.gz')] );
    
    copyfile( fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) ,...% Copy aligned FLAIR to MNINonLinear folder
        fullfile(outfolder,subjid,'MNINonLinear',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) );
    
    system(['${CARET7DIR}/wb_command -add-to-spec-file '...                                     % Add to spec file
        fullfile(outfolder,subjid,'MNINonLinear',[ subjid '.164k_fs_LR.wb.spec'])...
        ' INVALID ' fullfile(outfolder,subjid,'MNINonLinear',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) ...
        ]);
    
        disp([' Completed FLAIR registration. Image ' subjid '_3T_T2FLAIR_MNINonLinear.nii.gz' ' added to spec file ' subjid '.164k_fs_LR.wb.spec' '.'])

    
else
    disp('No FLAIR data in unprocessed folder')
end