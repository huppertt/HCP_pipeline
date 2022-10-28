function HCP_subcortical(subjid,outfolder,force)

if(nargin<3)
    force=false;
end

HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

if(~force & exist(fullfile(outfolder,subjid,'MNINonLinear','subcortical_seg_4D.nii.gz'))==2)
    disp(['Skipping: ' subjid]);
    return;
end

% setenv('FSLDIR','/disk/HCP/pipeline/external/fsl');
mkdir(fullfile(outfolder,subjid,'T1w','subcortical'));
copyfile(fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_1mm.nii.gz'),...
    fullfile(outfolder,subjid,'T1w','subcortical','T1w_acpc_dc_restore_1mm.nii.gz'));

curdir=pwd;
cd(fullfile(outfolder,subjid,'T1w','subcortical'));
if(isempty(dir('*.vtk')))
    system('/disk/HCP/pipeline/external/fsl/bin/run_first_all -v -i T1w_acpc_dc_restore_1mm.nii.gz -o subcortical');
end
% T=dlmread('T1w_acpc_dc_restore_1mm_to_std_sub.mat');
a=load_nifti('T1w_acpc_dc_restore_1mm.nii.gz');
T=a.vox2ras;


files=dir('*.vtk');
for idx=1:length(files)
    [v,f]=read_vtk(files(idx).name);
    v=v';
    v(:,4)=1;
    v=v*T';
    v=v(:,1:3);
    s=struct;
    s.vertices=v;
    s.faces=f';
    s=gifti(s);
    f=[strtok(files(idx).name,'.') '.surf.gii'];
    save(s,f);
end

gii{1,1}='BrStem_first.surf.gii';
gii{1,2}='BRAIN_STEM';
gii{2,1}='L_Accu_first.surf.gii';
gii{2,2}='ACCUMBENS_LEFT';
gii{3,1}='L_Amyg_first.surf.gii';
gii{3,2}='AMYGDALA_LEFT';
gii{4,1}='L_Caud_first.surf.gii';
gii{4,2}='CAUDATE_LEFT';
gii{5,1}='L_Hipp_first.surf.gii';
gii{5,2}='HIPPOCAMPUS_LEFT';
gii{6,1}='L_Pall_first.surf.gii';
gii{6,2}='PALLIDUM_LEFT';
gii{7,1}='L_Puta_first.surf.gii';
gii{7,2}='PUTAMEN_LEFT';
gii{8,1}='L_Thal_first.surf.gii';
gii{8,2}='THALAMUS_LEFT';

gii{9,1}='R_Accu_first.surf.gii';
gii{9,2}='ACCUMBENS_RIGHT';
gii{10,1}='R_Amyg_first.surf.gii';
gii{10,2}='AMYGDALA_RIGHT';
gii{11,1}='R_Caud_first.surf.gii';
gii{11,2}='CAUDATE_RIGHT';
gii{12,1}='R_Hipp_first.surf.gii';
gii{12,2}='HIPPOCAMPUS_RIGHT';
gii{13,1}='R_Pall_first.surf.gii';
gii{13,2}='PALLIDUM_RIGHT';
gii{14,1}='R_Puta_first.surf.gii';
gii{14,2}='PUTAMEN_RIGHT';
gii{15,1}='R_Thal_first.surf.gii';
gii{15,2}='THALAMUS_RIGHT';
 

for i=1:size(gii,1)
    f = fullfile(pwd,['subcortical-' gii{i,1}]);
    stru = gii{i,2};
    f2=fullfile(outfolder,subjid,'MNINonLinear',[subjid '.' gii{i,2} '.surf.gii']);
    system(['cp ' f ' ' f2]);
    
    system(['${CARET7DIR}/wb_command -set-structure ' f2 ' '...
        stru ' -surface-type ANATOMICAL -surface-secondary-type INVALID']);

%     system(['${CARET7DIR}/wb_command -surface-apply-affine ' f2 ' '...
%     fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc2MNILinear.mat') ' ' f2]);
   
    system(['${CARET7DIR}/wb_command -surface-apply-warpfield ' f2 ' '...
    fullfile(outfolder,subjid,'MNINonLinear','xfms','standard2acpc_dc.nii.gz') ' ' f2 ...% Note this function requires the inverse warp field
    ' -fnirt ' fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz')]); % It also requires header info from the forward field

    spec=fullfile(outfolder,subjid,'MNINonLinear',[ subjid '.164k_fs_LR.wb.spec']);
    
    system(['${CARET7DIR}/wb_command -add-to-spec-file '...
       spec ' ' gii{i,2} ' ' f2]);
        
end
    
% Transform volumetric segmentation w nn interp, copy to MNINonLinear, add to spec file (NOTE: this is one file with multiple masks)
system(['applywarp  --rel --interp=nn ' ...
    ' -i   subcortical_all_fast_firstseg.nii.gz'...
    ' -r ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz') ...
    ' -w ' fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz') ...
    ' -o ' fullfile(outfolder,subjid,'MNINonLinear','subcortical_seg.nii.gz')  ]);
% 
%     system(['${CARET7DIR}/wb_command -add-to-spec-file '...
%        spec ' INVALID ' fullfile(outfolder,subjid,'MNINonLinear','subcortical_seg.nii.gz') ])
   
% Note that volume labels are as follows (fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST/UserGuide#Labels):

nii = ...
{'10' 'L_thalamus'
'11' 'L_caudate'
'12' 'L_putamen'
'13' 'L_pallidum'
'16' 'Brainstem'
'17' 'L_hippocampus'
'18' 'L_amygdala'
'26' 'L_accumbens'
'49' 'R_thalamus'
'50' 'R_caudate'
'51' 'R_putamen'
'52' 'R_pallidum'
'53' 'R_hippocampus'
'54' 'R_amygdala'
'58' 'R_accumbens'};

% Write individual mask files for subcortical structures (this method is
% not guaranteed to be overlap-free):

for i = 1:length(nii)
    system(['fslmaths '...
        'subcortical_all_fast_firstseg.nii.gz '...                                                      % Write separate binarized masks for each structure
        '-thr ' nii{i,1} ' -mul -1 -thr -' nii{i,1} ' -mul -1 -bin ' ...  
        fullfile(outfolder,subjid,'MNINonLinear', ['mask_'  nii{i,2} '.nii.gz'] ) ]);
    
    system(['applywarp  --rel --interp=trilinear '...
        ' -i ' fullfile(outfolder,subjid,'MNINonLinear', ['mask_'  nii{i,2} '.nii.gz'] )  ...           % Warp each binarized mask to MNI space
        ' -r ' fullfile(outfolder,subjid,'MNINonLinear','T1w_restore.nii.gz') ...
        ' -w ' fullfile(outfolder,subjid,'MNINonLinear','xfms','acpc_dc2standard.nii.gz') ...
        ' -o ' fullfile(outfolder,subjid,'MNINonLinear', ['mask_'  nii{i,2} '.nii.gz'] )  ]);
    
    system(['fslmaths ' fullfile(outfolder,subjid,'MNINonLinear', ['mask_'  nii{i,2} '.nii.gz'] ) ...   % Rethreshold and binarize each warped mask
        ' -thr 0.5 -bin ' fullfile(outfolder,subjid,'MNINonLinear', ['mask_'  nii{i,2} '.nii.gz']) ]);
end

system([ 'fslmerge -t ' fullfile(outfolder,subjid,'MNINonLinear','subcortical_seg_4D.nii.gz') ...       % Merge resulting masks in 4D file
    ' `imglob -oneperimage ' fullfile(outfolder,subjid,'MNINonLinear','mask_*') ' `'  ])

system(['rm ' fullfile(outfolder,subjid,'MNINonLinear','mask_*')]);                                     % Clean up temp mask files

 system(['${CARET7DIR}/wb_command -add-to-spec-file '...                                                % Add to spec file
       spec ' INVALID ' fullfile(outfolder,subjid,'MNINonLinear','subcortical_seg_4D.nii.gz') ])

cd(curdir);
