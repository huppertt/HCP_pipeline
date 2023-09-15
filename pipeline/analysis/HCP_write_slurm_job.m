function HCP_write_slurm_job(subjid,stage,outfolder,force)

[~,uname]=system('whoami');
uname=strtrim(uname);
switch(uname)
    case('santosah')
        myemail='hendrik.santosa@pitt.edu';
    case('chend')
        myemail='chend5@upmc.edu';
    otherwise
        myemail='huppertt@upmc.edu';
end

qname='defq';

HCProot='/disk/HCP';
if(nargin<3 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<4)
    force=false;
end

if(~exist(fullfile(outfolder,subjid)))
    mkdir(fullfile(outfolder,subjid));
end

if(~exist(fullfile(outfolder,subjid,'scripts')))
    mkdir(fullfile(outfolder,subjid,'scripts'));
end

cd('/disk/HCP');

curdir=pwd;
cd(fullfile(outfolder,subjid,'scripts'))

if(stage==999)
    % run everything
   stageAll=[1:9];
else
    stageAll=stage;
    
end

lastdep=[];


if(exist(fullfile(outfolder,subjid,'skip_processing.log')))
    a=importdata(fullfile(outfolder,subjid,'skip_processing.log'));
    if(~isempty(strfind(a,'*')))
        disp(['skipping ' subjid ' STAGE-' num2str(stage)]);
    end
end


for idx=1:length(stageAll)
    stage=stageAll(idx);
    
%     
%     
%     if(exist(fullfile(outfolder,subjid,'scripts',[subjid '_stage' num2str(stage) '.log']),'file'))
%         disp(['skipping ' subjid ' STAGE-' num2str(stage)]);
%         continue;
%     end
    
    cmd=matlab2slurm({['HCP_runall(''' subjid ''',' num2str(stage) ',''' outfolder ''',' num2str(force) ');']});
    %
    % slurm_sub(cmd);
    % return;
    system(['mkdir -p ' fullfile(outfolder,subjid,'scripts')]);
    cd(fullfile(outfolder,subjid,'scripts'));
    switch(abs(floor(stage)))
        case(0)
            
            if(force)
                cd(curdir);
                system(['rm -rf ' fullfile(outfolder,subjid) ]);
                mkdir(fullfile(outfolder,subjid,'scripts'));
                cd(fullfile(outfolder,subjid,'scripts'));
            end
            
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage0.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_0']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage0.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch  ./' subjid '_stage0.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage0.sh']);
            end
        case(1)
            if(force)
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid) ]);
            end
            
            % Freesurfer
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage1.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_1']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage1.log']));
            fprintf(fid,'#SBATCH --ntasks=4\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
             fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage1.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage1.sh']);
            end
        case(-1)
            if(force)
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid) ]);
            end
            
            % Freesurfer
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage1.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_1']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage1.log']));
            fprintf(fid,'#SBATCH --ntasks=4\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage1.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage1.sh']);
            end
        case(2)
            
            if(force)
                system(['rm -rf ' fullfile(outfolder,subjid,'Diffusion') ]);
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'dmri')]);
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'dlabel')]);
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'dmri.bedpostX')]);
                system(['rm -rf ' fullfile(outfolder,subjid,'T1w',subjid,'dpath')]);
            end
            
            
            % DTI analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage2.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_2']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage2.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage2.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage2.sh']);
            end
        case(3)
            if(force)
                system(['rm -rf ' fullfile(outfolder,subjid,'BOLD_*')]);
            end
            
            % fMRI analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage3.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_3']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage3.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage3.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage3.sh']);
            end
            if(force)
                system(['rm -rf ' fullfile(outfolder,subjid,'BOLD_*')]);
            end
        case(4)
            % fMRI analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage4.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_4']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage4.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
           if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage4.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage4.sh']);
            end
        case(5)
            % fMRI analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage5.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_5']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage5.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage5.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage5.sh']);
            end
        case(6)
            % fMRI analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage6.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_6']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage6.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage6.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage6.sh']);
            end
        case(7)
            %PET analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage7.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_7']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage7.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage7.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage7.sh']);
            end
        case(8)
            %PET analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage8.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_8']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage8.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage8.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage8.sh']);
            end
        case(9)
            %PET analysis
            fid=fopen(fullfile(outfolder,subjid,'scripts',[subjid '_stage9.sh']),'w');
            fprintf(fid,'#!/bin/bash\n');
            fprintf(fid,'#SBATCH --job-name=%s\n',[subjid '_9']);
            fprintf(fid,'#SBATCH --output=%s\n',fullfile(outfolder,subjid,'scripts',[subjid '_stage9.log']));
            fprintf(fid,'#SBATCH --ntasks=1\n');  % Freesurfer will use the cores
            fprintf(fid,'#SBATCH --mail-type=end\n');
            fprintf(fid,'#SBATCH --mail-user=%s\n',myemail);
            fprintf(fid,'#SBATCH --partition=%s\n',qname);
            fprintf(fid,'%s \n',cmd{1});
            fclose(fid);
            if(isempty(lastdep))
                system(['sbatch ./' subjid '_stage9.sh']);
            else
                 system(['sbatch --dependency=afterany:' lastdep ' ./' subjid '_stage9.sh']);
            end
    end
end
cd(curdir);
