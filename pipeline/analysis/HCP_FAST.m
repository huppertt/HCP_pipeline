function HCP_FAST(subjid,outfolder)


HCProot='/disk/HCP';
if(nargin<2)
    outfolder=fullfile(HCProot,'analyzed');
end

T1wfile = fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_brain_1mm.nii.gz');
outroot = fullfile(outfolder,subjid,'T1w','fast','T1fast');
mkdir( fullfile(outfolder,subjid,'T1w','fast'));
system(['fast -t 1 -v -b -p -o ' outroot ' ' T1wfile])

if(~exist(fullfile(outfolder,subjid,'T1w','BiasField_acpc_dc.nii.gz')))
    system(['cp -v ' outroot '_bias.nii.gz ' fullfile(outfolder,subjid,'T1w','BiasField_acpc_dc.nii.gz')]);
end