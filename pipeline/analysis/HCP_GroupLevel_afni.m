function HCP_GroupLevel_afni(outfolder,groupfolder,files)

curdir=pwd;

system(['mkdir -p ' fullfile(outfolder,groupfolder)]);

if(nargin<3)
    files=rdir(fullfile(outfolder,'**','*_afniStats_REML+tlrc.HEAD'));
end

for i=1:length(files)
    [p,f]=fileparts(files(i).name);
    mask{i}=fullfile(p,'brainmask_fs.2.0.nii.gz');
    T1{i}=fullfile(p,'..','..','MNINonLinear','T1w_restore.nii.gz');
    dset{i}=fullfile(p,f);
        
end

cd(fullfile(outfolder,groupfolder));
cmd = afni_secondlevel(dset,mask,T1);


%for some reason the system command has troubles is the cmd is too long
fid=fopen('afni_group.sh','w');
fprintf(fid,'#bash\n');
fprintf(fid,'%s/n',cmd);
fclose(fid);
system('chmod 777 afni_group.sh');
system('source afni_group.sh');


system('mv group_results_ANOVA/n+tlrc.BRIK GroupStats+tlrc.BRIK');
system('mv group_results_ANOVA/n+tlrc.HEAD GroupStats+tlrc.HEAD');
system('rm -rf group_results_ANOVA');

cd(curdir);