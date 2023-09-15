function HCP_DTI_analysis_fieldmap_only(subjid,outfolder)

fugue = 0; % If true, use FUGUE/epi_reg only - no eddy correction

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

disp([' Beginning DTI analysis using fieldmap distortion correction for subject '...
    outfolder '/' subjid '.'])

if exist( fullfile(outfolder,subjid,'unprocessed','3T','Diffusion' ) , 'dir' ) % Check if DTI data is available in unprocessed folder
    
    disp('Copying files to subject directory.')
    % Make Diffusion dir in main subject dir
    system([ 'mkdir -p -m 777 ' fullfile(outfolder,subjid,'Diffusion')]);
    
    % Copy unprocessed data into new dir
    file = dir(fullfile(outfolder,subjid,'unprocessed','3T','Diffusion' ));
    for i = 3:length(file)
        copyfile( fullfile(outfolder,subjid,'unprocessed','3T','Diffusion', file(i).name ) ,...
            fullfile(outfolder,subjid,'Diffusion', file(i).name ) );
    end
  

    disp('Beginning distortion correction using field map.')
    % Distortion correction if fieldmaps exists...
    if exist( fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude.nii.gz']) ,'file')...
            & exist( fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapPhase.nii.gz']) , 'file')
        
        % Prep steps for distortion correction:
        
        % Extract brain from fmap magnitude image (required for fsl_prepare_fieldmap)
        system(['bet'...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude.nii.gz'])...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain']) ...
            ' -n -m -f 0.6 -R'
            ]);
        
        % Erode resulting brain mask to remove noisy edge voxels of field map
        system(['fslmaths' ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz']) ...
            ' -kernel box 5 -ero -fillh'  ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz'])...
            ]);
        
        % Apply eroded mask to field magnitude for use in fsl_prepare_fieldmap
        system(['fslmaths' ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain.nii.gz']) ...
            ' -mul '  fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain_mask.nii.gz'])...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain.nii.gz'])...
            ]);
        
        % Convert field map to rad/s using fsl_prepare_fieldmap
        system(['fsl_prepare_fieldmap SIEMENS' ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapPhase.nii.gz']) ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain.nii.gz']) ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_rads.nii.gz']) ...
            ' 2.65 ']);
        
        %         if fugue ==1
        
                    % Correct distortion with FUGUE (field map distortion correction)
                    system(['fugue ' ...
                        ' -i '          fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.nii.gz'])...
                        ' --loadfmap='  fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_rads.nii.gz'])...
                        ' --dwell=0.000475 ' ... % Echo Spacing or Dwelltime of dMRI image, set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples).  On Siemens, iPAT/GRAPPA factors have already been accounted for.
                        ' --unwarpdir=y-' ...
                        ' -u '          fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI_dc.nii.gz'])...
                        ]);
        
        %             % Correct distortion with epi_reg (BBR-based T1 alignment and field map distortion correction)
        %             system(['epi_reg ' ...
        %                 ' --epi='       fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.nii.gz'])...
        %                 ' --t1='        fullfile(outfolder,subjid ,'Diffusion','T1w_acpc_dc.nii.gz') ...
        %                 ' --t1brain='   fullfile(outfolder,subjid ,'Diffusion','T1w_acpc_dc_brain.nii.gz') ...
        %                 ' --fmap='      fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_rads.nii.gz'])...
        %                 ' --fmapmag='   fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude.nii.gz']) ...
        %                 ' --fmapmagbrain=' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_FieldMapMagnitude_brain.nii.gz']) ...
        %                 ' --echospacing=0.000475 ' ... % Echo Spacing or Dwelltime of dMRI image, set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples).  On Siemens, iPAT/GRAPPA factors have already been accounted for.
        %                 ' --out='       fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI_dc.nii.gz'])...
        %                 ]);
        
        %         else % Use EDDY
        
        % Convert fieldmap to Hz
        system(['fslmaths' ...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_rads.nii.gz']) ...
            ' -div 6.283185 '...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_Hz.nii.gz']) ...
            ]);
        
        % Generate brain mask from DWI image for use with eddy
        system(['bet'...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.nii.gz'])...
            ' ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI_brain']) ...
            ' -n -m -f 0.35 -R'
            ]);
        
        % Generate acquisition parameter file (Note: 4th column is readout
        % time computed as Echospacing*(EPIfactor-1)*0.001s/ms
        n = load_nifti(fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.nii.gz']) );
        Echospace = 0.47; % ms  Echo Spacing or Dwelltime of dMRI image, set to NONE if not used. Dwelltime = 1/(BandwidthPerPixelPhaseEncode * # of phase encoding samples): DICOM field (0019,1028) = BandwidthPerPixelPhaseEncode, DICOM field (0051,100b) AcquisitionMatrixText first value (# of phase encoding samples).  On Siemens, iPAT/GRAPPA factors have already been accounted for.
        PEdir = -1; % Assuming AP (-1) or PA (1)
        EPIfactor = size(n.vol, 2); % Assuming AP or PA PE dir
        ROtime = Echospace*(EPIfactor-1)/1000;
        system(['echo "0 ' num2str(PEdir) ' 0  ' num2str(ROtime) '" > '...
            fullfile(outfolder,subjid,'Diffusion',[subjid '_acqpars.txt']) ])
        
        % Generate index file (all of the indices refer to the first line
        % of acqpars.txt - ie they are all ones.
        dlmwrite(fullfile(outfolder,subjid,'Diffusion',[subjid '_index.txt']) ,...
            ones(1, size(n.vol,4)) , ' ');
        
        % Correct distortion with eddy (susceptibility and eddy current correction)
        system(['eddy ' ...
            ' --imain=' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.nii.gz'])...
            ' --mask='  fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI_brain_mask.nii.gz'])...
            ' --acqp='  fullfile(outfolder,subjid,'Diffusion',[subjid '_acqpars.txt']) ...
            ' --index=' fullfile(outfolder,subjid,'Diffusion',[subjid '_index.txt']) ...
            ' --bvecs=' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.bvec'])...
            ' --bvals=' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI.bval'])...
            ' --field=' fullfile(outfolder,subjid,'Diffusion',[subjid '_fmap_Hz'])...
            ' --out='   fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_DWI_dc']) ...
            ])
    end
else  % Else report lack of fieldmap
    disp('Distortion correction failed: Field map not found.')
end


%     system( ['applywarp '...                                                                    % Apply warp from acpc space to MNI space
%         ' -i ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_T2FLAIR_acpc.nii.gz'])...
%         ' -r ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz')...
%         ' -o ' fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz'])...
%         ' -w ' fullfile(outfolder,subjid,'MNINonLinear','xfms', 'acpc_dc2standard.nii.gz')] );
%
%     copyfile( fullfile(outfolder,subjid,'Diffusion',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) ,...% Copy aligned FLAIR to MNINonLinear folder
%         fullfile(outfolder,subjid,'MNINonLinear',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) );
%     
%     system(['${CARET7DIR}/wb_command -add-to-spec-file '...                                     % Add to spec file
%         fullfile(outfolder,subjid,'MNINonLinear',[ subjid '.164k_fs_LR.wb.spec'])...
%         ' INVALID ' fullfile(outfolder,subjid,'MNINonLinear',[subjid '_3T_T2FLAIR_MNINonLinear.nii.gz']) ...
%         ]);
%     
%         disp([' Completed FLAIR registration. Image ' subjid '_3T_T2FLAIR_MNINonLinear.nii.gz' ' added to spec file ' subjid '.164k_fs_LR.wb.spec' '.'])

    
else
    disp('No diffusion data in unprocessed folder')
end