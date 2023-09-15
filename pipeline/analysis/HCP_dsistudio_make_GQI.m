function HCP_dsistudio_make_GQI_only(subjid, outfolder, force)

if(nargin<3)
    force=false;
end

if(~exist(fullfile(outfolder,subjid,'T1w',subjid,'dmri','dwi.nii.gz')))
    warning(['Stage 2 not run yet: ' subjid]);
    return
end
curdr=pwd;
cd(fullfile(outfolder,subjid,'T1w',subjid,'dmri'));

dsiroot = ['/home/jhengenius/dsi-studio/'];

HCP_matlab_setenv
fsldir=getenv('FSLDIR');

%Copy brain mask to dirr
system(['cp -v ' fullfile(outfolder,subjid,'T1w','T1w_acpc_brain_mask.nii.gz') ' ./brain_mask.nii.gz']);       % ACPC brain mask
%Resample to DWI resolution
system('fslmaths ./dwi.nii.gz -Tmean ./dataMean.nii.gz');   % Compute mean of DWI image to use as reference for resampling
system(['flirt -in ./brain_mask.nii.gz -ref ./dataMean.nii.gz -out ./brain_mask_dsi.nii.gz -nosearch -applyxfm -init ' fsldir '/etc/flirtsch/ident.mat -interp nearestneighbour']); % Downsample mask to dMRI res
system('fslmaths brain_mask_dsi.nii.gz -kernel sphere 3 -dilM -fillh -bin brain_mask_dsi.nii.gz'); % added dilation to capture missing cortex
    


if(~exist([ subjid '_dsistudio.gqi.fib.gz']) || force)
    disp([subjid ' beginning GQI'])
    if(~exist([subjid '_dsistudio.src.gz']))
        %system(['rm ' subjid '_dsistudio.src.gz']);
        % Generate source file
        system([ dsiroot filesep 'dsi_studio ' ...
            ' --action=src ' ...
            ' --source=dwi.nii.gz '...
            ' --bval=bvals --bvec=bvecs '...
            ' --output=' subjid '_dsistudio.src.gz']);
    end

    if(exist([ subjid '_dsistudio.gqi.fib.gz']))
        delete([ subjid '_dsistudio.gqi.fib.gz'])
    end
    system([dsiroot filesep 'dsi_studio --action=rec --source=' subjid '_dsistudio.src.gz '...   % ' --mask=brain_mask_dsi.nii.gz '...
        ' --method=4 '...
        ' --param0=1.25 --record_odf=1 --check_btable=1 '...
        ' --mask=brain_mask_dsi.nii.gz '...
        ' --param1=1 --thread_count=16 ']); % ' --other_image=t1w:T1w_brain.nii.gz'


    f=dir([ subjid '_dsistudio*.gqi.1.25.fib.gz']);
    movefile(f(1).name,[ subjid '_dsistudio.gqi.fib.gz']); 
end

cd(curdr)
