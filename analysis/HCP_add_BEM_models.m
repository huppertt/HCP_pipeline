function HCP_add_BEM_models(subjid,outdir,force)

if(nargin<3)
    force=false;
end

% TODO- for FS_Basic folder struct
flag=false;

HCProot='/disk/HCP';
if(nargin<2)
    outdir=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

if(~force & exist(fullfile(outdir,subjid,'T1w',subjid,'bem',[ subjid '-head-dense.fif'])))
    disp(['exists '  subjid '-head-dense.fif']);
    return;
end


language='bash';  %which scripting language
setenv('MNE_ROOT','/home/pkg/software/MNE');

            
%Run any setup files
if(strcmp(language,'bash'))
    if(exist(fullfile(getenv('FREESURFER_HOME'),'SetUpFreeSurfer.sh'))~=0)
        system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
    end
    if(exist(fullfile(getenv('MNE_ROOT'),'bin','mne_setup_sh'))~=0)
        system(['source ' getenv('MNE_ROOT') filesep 'bin' filesep 'mne_setup_sh']);
    end
elseif(strcmp(language,'csh'))
    if(exist(fullfile(getenv('FREESURFER_HOME'),'SetUpFreeSurfer.csh'))~=0)
        system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.csh']);
    end
    if(exist(fullfile(getenv('FREESURFER_HOME'),'mne_setup_csh'))~=0)
        system(['source ' getenv('MNE_ROOT') filesep 'bin' filesep 'mne_setup_csh']);
    end
end
if(~flag)
setenv('SUBJECTS_DIR',fullfile(outdir,subjid,'T1w'));
else
setenv('SUBJECTS_DIR',fullfile(outdir,subjid,'T1w','FS_basic'));
end

setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('MNE_ROOT') filesep filesep 'bin']);

setenv('SUBJECT',subjid);

%RUn the MEG BEM model generation (I use this for the NIRS model as well)
str=[getenv('MNE_ROOT') filesep 'bin' ];
system([str filesep 'mne_setup_mri --overwrite']);
system([str filesep 'mne_watershed_bem --atlas --overwrite']);

curdir=pwd;

cd(fullfile(getenv('SUBJECTS_DIR'),subjid,'bem'));
system(['mkheadsurf -s ' subjid])
system(['mne_surf2bem --surf ../surf/lh.seghead --id 4 --check --fif ' subjid '-head-dense.fif'])


%setenv('SUBJECTS_DIR',fullfile(outdir,subjid,'T1w'))
setenv('SUBJECT',subjid);
FSfold=fullfile(getenv('SUBJECTS_DIR'),subjid);

copyfile(fullfile(FSfold,'bem','watershed',[subjid '_outer_skin_surface']),fullfile(FSfold,'bem','outer_skin.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_outer_skull_surface']),fullfile(FSfold,'bem','outer_skull.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_inner_skull_surface']),fullfile(FSfold,'bem','inner_skull.surf'));
copyfile(fullfile(FSfold,'bem','watershed',[subjid '_brain_surface']),fullfile(FSfold,'bem','brain.surf'));

cd(fullfile(FSfold,'bem'))
system(['rm -v ' subjid '-ico-4-src.fif'])
system(['python3.5 ' fullfile(HCProot,'pipeline','analysis','HCP_mne_bem.py')])


cd(curdir);



HCP_matlab_setenv;  % Resets the FSL, Freesurfer, etc folders 

