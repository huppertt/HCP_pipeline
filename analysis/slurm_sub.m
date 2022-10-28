function varagout=slurm_sub(jobs,queue,dependency)

uname=datestr(now,30);

if(nargin<2)
    queue = 'defq';
end

if(nargin<3)
    dependency=[];
end

if(length(jobs)>12)
    for idx=1:12:length(jobs)
        lst=[(idx-1)*12+1:idx*12];
        lst(find(lst>length(jobs)))=[];
        slurm_sub({jobs{lst}},queue,dependency);
    end
    return;
end

[~,uname2]=system('whoami');
uname2(double(uname2)<65 | double(uname2)>122)=[];
% tmpdir = fullfile('/disk','HCP','tmp',uname2,'slurmlogs/');
tmpdir = fullfile('/home',uname2,'slurmlogs/');

if(~exist(tmpdir))
  %  mkdir(['/disk/HCP/tmp']);
    mkdir(['/home/' uname2  '/slurmlogs']);
  %  mkdir(tmpdir)
    system(['chmod 777 ' tmpdir]);
end

fid=fopen([tmpdir uname '_tmp.sh'],'w');
fprintf(fid,'#!/bin/bash\n')


for idx=1:length(jobs)
    file=[tmpdir uname 'tmp_job' num2str(idx)];
    fid2=fopen([file '.sh'],'w');
    fprintf(fid2,'#!/bin/bash\n');
    fprintf(fid2,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
    fprintf(fid2,'#SBATCH --N=1\n');  % Freesurfer will use the cores
    fprintf(fid2,'#SBATCH --cpu-per-task=12\n');  % Freesurfer will use the cores
    fprintf(fid2,'#SBATCH --exclude=node[02,04-20]\n');  % Freesurfer will use the cores
    if(~isempty(queue))
        fprintf(fid2,'#SBATCH --partition=%s\n',queue);
    end
    fprintf(fid2,'%s \n',jobs{idx});
    fclose(fid2);

    fprintf(fid,'srun -Q -o %s %s &\n',[file '.log'],[file '.sh']);
end
fprintf(fid,'wait\n exit');
fclose(fid);

fid=fopen([tmpdir uname '_tmp2.sh'],'w');
if(~isempty(dependency))
    fprintf(fid,'#!/bin/bash\nsbatch --exclude=node[02,04-20] --dependency=afterok:%s --output=%s %s',dependency,fullfile(tmpdir,'slurm-%j.out'),fullfile(tmpdir,[uname '_tmp.sh']));
else
    fprintf(fid,'#!/bin/bash\nsbatch --exclude=node[02,04-20] --output=%s %s',fullfile(tmpdir,'slurm-%j.out'),fullfile(tmpdir,[uname '_tmp.sh']));
end
fclose(fid);

system(['chmod 777 ' tmpdir '*.sh']);

[~,msg]=system(['source ' tmpdir uname '_tmp2.sh']);
if(nargout==1)
    varagout=msg(strfind(msg,'job')+4:end);
end
return
