global HCPpathset;

if(HCPpathset)
    return
end

if(~exist('HCProot'))
    HCProot='/aionraid/huppertt/raid2_BU/HCP/';
end

warning('off','MATLAB:dispatcher:nameConflict');

if(~isempty(getenv('HCPenvset'))  && strcmp(getenv('HCPenvset'),'TRUE'))
    return
end

                                setenv('HCPenvset','TRUE');

setenv('FREESURFER_HOME',[HCProot '/pipeline/external/freesurfer-stable']);
%setenv('FREESURFER_HOME','/home/pkg/software/freesurfer/');

setenv('FSLDIR',[HCProot '/pipeline/external/fsl/']);
%setenv('FSLDIR','/home/pkg/software/fsl/fsl');
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') '/bin/']);

%setenv('FSLDIR','/home/pkg/software/fsl/fsl');
setenv('FSLDIR',[HCProot '/pipeline/external/fslnew/']);

system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);

setenv('PATH',[getenv('PATH') ':' HCProot '/pipeline/external/fslnew/bin/'])
setenv('PATH',[getenv('PATH') ':' HCProot '/pipeline/external/fslnew/'])
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);

setenv('PATH',[fullfile(HCProot,'pipeline','external','Python-3.9.9','bin','bin') ':' getenv('PATH')])
setenv('PATH',[fullfile(HCProot,'pipeline','external','Python-3.9.9','bin','bin') ':' getenv('PATH')])
setenv('PATH',[fullfile(HCProot,'pipeline','external','gradunwarp','bin') ':' getenv('PATH')])

setenv('PATH',[fullfile(HCProot,'pipeline','analysis') ':' getenv('PATH')])

setenv('PYTHONPATH',[getenv('PYTHONPATH') ':' HCProot '/pipeline/external/Python-3.9.9/lib/python3.9/site-packages']);

setenv('PERL5LIB',[getenv('FREESURFER_HOME') '/mni/lib/perl5/5.8.5/'])   
setenv('HCPPIPEDIR',fullfile(HCProot,'pipeline/projects/Pipelines'))
setenv('FSLOUTPUTTYPE','NIFTI_GZ')
setenv('HOME',fullfile(HCProot));

setenv('HCPPIPEDIR_dMRI',fullfile(HCProot,'/pipeline/projects/Pipelines/DiffusionPreprocessing/scripts'));
setenv('HCPPIPEDIR_fMRIVol',fullfile(HCProot,'/pipeline/projects/Pipelines/fMRIVolume/scripts'));
setenv('HCPPIPEDIR_Global',fullfile(HCProot,'/pipeline/projects/Pipelines/global/scripts'));
setenv('HCPPIPEDIR_Config',fullfile(HCProot,'pipeline/projects/Pipelines/global/config'));
setenv('CARET7DIR',[fullfile(HCProot,'pipeline') '/workbench/bin_linux64'])

setenv('HCPPIPEDIR_PreFS',fullfile(HCProot,'/pipeline/projects/Pipelines/PreFreeSurfer/scripts'));
setenv('HCPPIPEDIR_tfMRIAnalysis',fullfile(HCProot,'/pipeline/projects/Pipelines/TaskfMRIAnalysis/scripts'));

system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/SetUpHCPPipeline.sh']);


path(path,fullfile(getenv('FREESURFER_HOME'),'matlab'))

%setenv('LD_LIBRARY_PATH','');
setenv('DYDL_LIBRARY_PATH',[getenv('DYDL_LIBRARY_PATH') ':/opt/X11/lib'])
setenv('DYDL_LIBRARY_PATH',[getenv('DYDL_LIBRARY_PATH') ':/cm/local/apps/gcc/5.2.0/lib/gcc/5/'])
setenv('LD_LIBRARY_PATH',['/usr/lib64:' HCProot '/pipeline/workbench/libs_linux64:' getenv('LD_LIBRARY_PATH') ':/usr/lib64']);

% The following checks if we are running on device theodore-MacPro. If so,
% it prepends qt5 and blas lib locations to LD_LIBRARY_PATH
if isunix & ~ismac
   [~,OSstring]=system('uname -a');
   machineName = strsplit(OSstring,' ');
   machineName = machineName{2};
   if strcmp(machineName, 'theodore-MacPro' )
       setenv('LD_LIBRARY_PATH', ['/usr/lib/x86_64-linux-gnu:/usr/lib/qt5:',getenv('LD_LIBRARY_PATH')]);
       setenv('LD_LIBRARY_PATH', ['/usr/local/bin/Slicer/lib/Slicer-4.11/:',getenv('LD_LIBRARY_PATH')]);
       setenv('FREESURFER_HOME', '/usr/local/bin/freesurfer')
       setenv('PATH',[getenv('FREESURFER_HOME') filesep 'bin' ':' getenv('PATH')]);
       setenv('PATH',[getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin' ':' getenv('PATH')]);
       setenv('PATH',[ getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin' ':' getenv('PATH')]);
       system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']); 
       disp('Running Ubuntu!')
   end
end

                                                            
setenv('PATH',[getenv('PATH') ':/abin'])
setenv('PATH',[getenv('PATH') ':/home/pkg/software/afni/linux_xorg7_64/'])


path(path,[HCProot '/pipeline/external/fix1.06/'])
path(path,'/home/pkg/software/fsl/fsl/etc/matlab/')
path(path,[HCProot '/pipeline/external/mne_matlab/'])
path(path,[HCProot '/pipeline/projects/Pipelines/global/matlab/'])

setenv('PATH',[getenv('PATH') ':/disk/NIRS/nirs-toolbox'])
path(path,'/disk/NIRS/nirs-toolbox')
path(path,genpath('/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox/external/'));
path(path,genpath('/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox-extra/'));
path('/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox/',path);
path(genpath([HCProot '/pipeline/analysis']),path);
setenv('PATH',[getenv('PATH') ':' HCProot '/pipeline/external/R-3.3.1/bin'])

setenv('FSL_FIXDIR',fullfile(HCProot,'pipeline','external','fix1.06'));
setenv('HCPPIPEDIR_Templates',[HCProot '/pipeline/projects/Pipelines/global/templates/'])

setenv('PATH',[getenv('PATH') ':' HCProot '/pipeline/analysis/xnat_remote/xnat-tools/']);
setenv('DYLD_LIBRARY_PATH',[getenv('DYLD_LIBRARY_PATH') ':/Users/huppert/abin:' HCProot '/pipeline/analysis/xnat_remote/lib'])



HCPpathset=true;
