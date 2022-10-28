function HCP_make_MMPconnectivity(subjid,outfolder)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

BOLDnii=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results',...
        'BOLD_REST*','BOLD_REST*_hp2000.nii.gz'));

AtlasTransform=fullfile(outfolder,subjid,'MNINonLinear','xfms','standard2acpc_dc.nii.gz');
T1 =fullfile(outfolder,subjid,'T1w','T1w_acpc_dc_restore_1mm.nii.gz');

for i=1:length(BOLDnii)
    [~,BOLDname]=fileparts(BOLDnii(i).name);
    BOLDname=BOLDname(1:13);
    fout=fullfile(outfolder,subjid,BOLDname,[BOLDname '_hp2000_acpc_dc_restore_1mm.nii.gz']);
    tic;
    system(['applywarp --rel --interp=nn -i ' BOLDnii(i).name ' -r ' T1 ' -w ' AtlasTransform ' -o ' fout]);
    disp(toc);
end

    