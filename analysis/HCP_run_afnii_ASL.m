function HCP_run_afni_ASL(subjid,type,outfolder,task,dosmoothing)

if(exist(fullfile(outfolder,subjid,type,'afni',[subjid '_' type '_afniStats_REML+tlrc.HEAD']),'file'))
    return
end


% Define the afni options
basis = '''GAM(8.6,.547)''';
basis = '''dmUBLOCK''';

numcpus=2;

if nargin<5 || isempty(dosmoothing)
    dosmoothing=true;
end

HCProot='/disk/HCP';
if(nargin<3)
    outfolder = fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders


rootfolder= fullfile(outfolder,subjid,type);

curdir=pwd;
%system(['rm -rf ' fullfile(rootfolder,'afni')]);
mkdir(fullfile(rootfolder,'afni'));
cd(fullfile(rootfolder,'afni'))


filein = [type '_nonlin_norm.nii.gz'];
mask = 'brainmask_fs.2.0.nii.gz';
statsfileout = [ subjid '_' type '_afniStats'];

if(~isempty(strfind(type,'ASL')))
    filein2 = [type '_flow_nonlin.nii.gz'];
     copyfile(fullfile(rootfolder,filein2),fullfile(rootfolder,'afni',filein));
     system(['cp -v ' rootfolder '/../MNINonLinear/brainmask_fs.nii.gz ' fullfile(rootfolder,'afni',mask)]);
else
    copyfile(fullfile(rootfolder,filein),fullfile(rootfolder,'afni',filein));
    copyfile(fullfile(rootfolder,mask),fullfile(rootfolder,'afni',mask));
end

copyfile(fullfile(rootfolder,'Movement_Regressors.txt'),fullfile(rootfolder,'afni','motion.1D'))

d=dlmread(fullfile(rootfolder,'afni','motion.1D'));
dlmwrite(fullfile(rootfolder,'afni','motion.1D'),d(2:2:end,:),'\t');


if(nargin<4 || isempty(task))
    taskfiles = dir(fullfile(outfolder,subjid,'MNINonLinear','Results',type,'EVs','*.txt'));
    cnt=1;
    % convert to afni AM1 stim files
    for i=1:length(taskfiles)
        if(taskfiles(i).name(1)~='.' & isempty(strfind(taskfiles(i).name,type)))
            copyfile(fullfile(outfolder,subjid,'MNINonLinear','Results',type,'EVs',taskfiles(i).name),...
                fullfile(rootfolder,'afni',taskfiles(i).name));
            if( ~strcmp(taskfiles(i).name,'Stats.txt') & ~strcmp(taskfiles(i).name,'Sync.txt'))
                d=[];
                try
                    d=dlmread(fullfile(outfolder,subjid,'MNINonLinear','Results',type,'EVs',taskfiles(i).name));
                catch
                    [a,b]=lasterr;
                    if(strcmp(b,'MATLAB:textscan:EmptyFormatString'))
                        d=[];
                        dlmwrite(taskfiles(i).name,[]);
                        
                    end
                    
                end
                if(isempty(d))
                    warning(['Condition: ' taskfiles(i).name ' is empty']);
                else
                    
                    task(cnt).file=taskfiles(i).name;
                    task(cnt).name = strtok(taskfiles(i).name,'.');
                    cnt=cnt+1;
                end
            end
        end
    end
end

if(isempty(task))
    warning(['No Eprime Task files found ' subjid ' : ' type]);
    return
end



if(dosmoothing)
    if(~exist([type '_nonlin_norm_smooth+tlrc.nii.gz'],'file'))
        FWHM=6;
        cmd='3dBlurToFWHM';
        cmd=sprintf('%s -input %s',cmd,filein);
        cmd=sprintf('%s -mask %s',cmd,mask);
        cmd=sprintf('%s -prefix %s_smooth',cmd,[type '_nonlin_norm']);
        cmd=sprintf('%s -FWHM %d',cmd,FWHM);
        system(cmd)
    end
    filein=[type '_nonlin_norm_smooth+tlrc'];
end


reg(1).name='roll';
reg(1).file='motion.1D''[0]''';
reg(2).name='pitch';
reg(2).file='motion.1D''[1]''';
reg(3).name='yaw';
reg(3).file='motion.1D''[2]''';
reg(4).name='dS';
reg(4).file='motion.1D''[3]''';
reg(5).name='dL';
reg(5).file='motion.1D''[4]''';
reg(6).name='dP';
reg(6).file='motion.1D''[5]''';

% for now
for i=1:length(task)
    contrasts(i).name=task(i).name;
    contrasts(i).string=['+' task(i).name];
end

writetable(table({task.file}',{task.name}','VariableNames',{'file','condition'}),...
    fullfile(rootfolder,'afni','Contrasts.txt'),'FileType','text');


cmd = '3dDeconvolve -allzero_OK ';
cmd = sprintf('%s -input %s',cmd,filein);
cmd = sprintf('%s -sat -local_times',cmd);
cmd = sprintf('%s -mask %s',cmd,mask);
cmd = sprintf('%s -legendre -polort 1',cmd);
cmd = sprintf('%s -num_stimts %d',cmd,length(reg)+length(task));

for i=1:length(reg)
    cmd = sprintf('%s -stim_file %d %s',cmd,i,reg(i).file);
    cmd = sprintf('%s -stim_label %d %s',cmd,i,reg(i).name);
    cmd = sprintf('%s -stim_base %d',cmd,i);
end
for i=1:length(task)
    if(isempty(strfind(task(i).file,'.1D')))
        cmd = sprintf('%s -stim_times_FSL %d %s %s',cmd,i+length(reg),task(i).file,basis);
        cmd = sprintf('%s -stim_label %d %s',cmd,i+length(reg),task(i).name);
    else
        cmd = sprintf('%s -stim_times_AM1 %d %s %s',cmd,i+length(reg),task(i).file,basis);
        cmd = sprintf('%s -stim_label %d %s',cmd,i+length(reg),task(i).name);
    end
end

% cmd = sprintf('%s -num_glt %d',cmd,length(contrasts));
% for i=1:length(contrasts)
%     cmd = sprintf('%s -glt_label %d',cmd,i,contrasts(i).name);
%     cmd = sprintf('%s -gltsym ''SYM:%s''',cmd,contrasts(i).string);
% end
cmd = sprintf('%s -fout -tout -vout -rout -bout -fitts rall_fitts',cmd);
cmd = sprintf('%s -bucket %s -xsave',cmd,statsfileout);
cmd = sprintf('%s -jobs %d -verb -GOFORIT 12',cmd,numcpus);

system([cmd ' -force_TR 5']);
system(['source ' statsfileout '.REML_cmd -GOFORIT 12'])

cd(curdir);