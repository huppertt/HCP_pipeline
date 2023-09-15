function HCP_resting_redo(subjid,outfolder);

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end

curdir=pwd;
hp=2000;
f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','*','*.ica'));
for i=1:length(f)
    cd(curdir);
    disp(f(i).name);
    cd(f(i).name);
    fix_3_clean('.fix',0,true,hp,true);
    name=fileparts(f(i).name)
    name=name(max(strfind(name,filesep))+1:end)
    system(['cp -v Atlas_clean.dtseries.nii ../' name '_Atlas_hp' num2str(hp) '.dtseries.nii']);	
    system(['cp -v filtered_func_data_clean.nii.gz ../' name '_hp' num2str(hp) '_clean.nii.gz']);	
end

 cd(curdir);