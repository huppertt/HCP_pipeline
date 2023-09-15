function HCP_redo_tracula_FS732(subjid,outfolder,force)

if nargin < 3
    force = 0;
end

if ~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri'))
    disp([subjid ' is missing cleaned DWI data. Returning.'])
    return;
end

%Set appropriate environment vars
setenv('FREESURFER_HOME', '/disk/HCP/pipeline/external/freesurfer73x')
setenv('FREESURFER', '/disk/HCP/pipeline/external/freesurfer73x')
setenv('FSFAST_HOME', '/disk/HCP/pipeline/external/freesurfer73x/fsfast')
setenv('FSF_OUTPUT_FORMAT', 'nii.gz')
setenv('MNI_DIR', '/disk/HCP/pipeline/external/freesurfer73x/mni')
setenv('FSL_DIR', '/disk/HCP/pipeline/external/fslnew')
setenv('ANTSPATH', '/disk/HCP/pipeline/external/ANTs-2.1.0-Linux/bin/') % This path needs to be changed/updated!
pathold = getenv('PATH');
pathold = strrep(pathold, '/disk/HCP/pipeline/external/freesurfer73x/bin:', '');
setenv('PATH', [ '/disk/HCP/pipeline/external/freesurfer73x/bin:' pathold])
system(['source $FREESURFER_HOME/SetUpFreeSurfer.sh'])
setenv( 'SUBJECTS_DIR', fullfile(outfolder, subjid, 'T1w'))

currdir = pwd;
cd( fullfile(outfolder, subjid, 'T1w'))

% If config file dmrirc doesn't exist, write it
if ~exist(fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt')) | force
    disp([subjid ': creating dmrirc config file.'])
    write_to_file = {};

    % Set subjects_dir
    write_to_file = [write_to_file;...
        ['setenv SUBJECTS_DIR ' fullfile(outfolder,subjid,'T1w')] ];

    % Set output dir for new tracula tracts (don't overwrite old)
    write_to_file = [write_to_file;...
        ['set dtroot = ' fullfile(outfolder,subjid,'T1w',subjid,'tracula_new') ] ];

    % Set subject name
    write_to_file = [write_to_file;...
        ['set subjlist = (' subjid ')'] ];

    % Set subject DWI directory
    write_to_file = [write_to_file;...
        ['set dcmroot = ' fullfile(outfolder,subjid,'T1w',subjid,'dmri')] ];

    % Set input DWI data
    write_to_file = [write_to_file;...
        ['set dcmlist = (dwi.nii.gz)'] ];

    % Set input bvecs input
    write_to_file = [write_to_file;...
        ['set bveclist = (bvecs)'] ];

    % Set input bvals input
    write_to_file = [write_to_file;...
        ['set bvallist = (bvals)'] ];

    % Perform correction for B0 inhomogeneities? No, data already cleaned
    write_to_file = [write_to_file;...
        ['set dob0 = 0'] ];

    % Use eddy? No, data already prepped
    write_to_file = [write_to_file;...
        ['set doeddy = 0'] ];

    % Register to T1? Yes, with BBR
    write_to_file = [write_to_file;...
        ['set intrareg = 3'] ];

    % Use 6DOF for T1 registration
    write_to_file = [write_to_file;...
        ['set intradof = 6'] ] ;

    % Rotation max angle for registration
    write_to_file = [write_to_file;...
        ['set intrarot = 90']];

    % Whole-brain segmentation used to extract the anatomical neighborhood priors
    write_to_file = [write_to_file;...
        ['set segname = aparc+aseg'] ];

    % Use thalamic segmentation? No
    write_to_file = [write_to_file;...
        ['set usethalnuc = 0'] ];

    %writecell(write_to_file , fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt'))
    fID = fopen(fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt') ,'w');
    for i = 1:length(write_to_file)
        fprintf(fID,'%s\n',[write_to_file{i}]);
    end
    fclose(fID)
end

% Run TRACULA with dmrirc config file
disp([subjid ': Beginning TRACULA run'])

disp([subjid ': beginning trac-all -prep'])
system(['trac-all -prep -c ' fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt')])

disp([subjid ': beginning trac-all -bedp'])
system(['trac-all -bedp -c ' fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt')])

disp([subjid ': beginning trac-all -path'])
system(['trac-all -path -c ' fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt')])

disp([subjid ': beginning trac-all -stat'])
system(['trac-all -stat -c ' fullfile(outfolder, subjid, 'T1w', subjid, 'dmri', 'dmrirc.7.3.config.txt')])

cd(currdir)