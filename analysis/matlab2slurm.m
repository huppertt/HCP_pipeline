function cmd = matlab2slurm(cmd,queue)
% This function converts a matlab command to run as a matlab -r "cmd"
% command for slurm

if(nargin<2)
    queue = 'defq';
end
curdir=pwd;
p=userpath;
save('/disk/HCP/tmp/tmppath.mat','p');

for i=1:length(cmd)
  %  cmd{i}=['/home/pkg/`hostname`/MATLAB/R2014a/bin/matlab -nosplash -nodesktop -nojvm -nodisplay -r "try; system(''rm -rf /tmp/*.nii''); '...
     cmd{i}=['/home/pkg/`hostname`/MATLAB/R2014a/bin/matlab -nosplash -nodesktop -nodisplay -r "try; system(''rm -rf /tmp/*.nii''); '...
    'load(''/disk/HCP/tmp/tmppath.mat''); addpath(p); cd(''' curdir '''); '...
    ' path(genpath(''/disk/HCP/pipeline/analysis''),path); ' ,...
    ' path(path,''/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox''); ' ,...
    ' path(path,genpath(''/aionraid/huppertt/raid2_BU/NIRS/nirs-toolbox/extenal'')); ' ...
    ' HCP_matlab_setenv; ' ,...
        cmd{i} '; catch; disp(lasterr); end; exit;"'];
end

if(nargout==0)
    % submit the job
    e=length(cmd);
    for i=1:12:length(cmd)
        slurm_sub({cmd{i:min(i+11,e)}},queue);
        pause(1);
    end
end