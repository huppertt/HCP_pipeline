function varargout=HCP_makeCTX_stats(subjid,outfolder,force)
HCP_matlab_setenv;

if(nargin<2 || isempty(outfolder))
    outfolder='/disk/HCP/analyzed';
end
if(nargin<3)
    force=false;
end

setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'));

segfile=fullfile(outfolder,subjid,'T1w',subjid,'mri','aparc.a2009s+aseg.mgz');
outfile=fullfile(outfolder,subjid,'stats','DKT_CTX.stats');

if(~exist(outfile) || force)
system(['mri_segstats --seg ' segfile ...
    ' --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt '...
    '--subject ' subjid ' --sum ' outfile]);
end

if(nargout==1)
    tbl=[];
    try;
        tbl=HCP_stats2table(outfile);
    end
    varargout={tbl};
end