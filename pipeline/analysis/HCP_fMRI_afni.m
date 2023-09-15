function HCP_fMRI_afni(subjid,outfolder,runslurm,dosmoothing)
curdir=pwd;

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3 || isempty(runslurm))
    runslurm=false;
end

if(nargin<4)
    dosmoothing=true;
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

str={'BOLD_MOTOR1_RL','BOLD_MOTOR1_LR','BOLD_MOTOR2_RL','BOLD_MOTOR2_LR',...
    'BOLD_LANGUAGE1_RL','BOLD_LANGUAGE1_LR','BOLD_LANGUAGE2_RL','BOLD_LANGUAGE2_LR',...
    'BOLD_WM1_RL','BOLD_WM1_LR','BOLD_WM2_RL','BOLD_WM2_LR',...
    'BOLD_MOTOR1_AP','BOLD_MOTOR1_PA','BOLD_MOTOR2_AP','BOLD_MOTOR2_PA',...
    'BOLD_LANGUAGE1_AP','BOLD_LANGUAGE1_PA','BOLD_LANGUAGE2_AP','BOLD_LANGUAGE2_PA',...
    'BOLD_WM1_AP','BOLD_WM1_PA','BOLD_WM2_AP','BOLD_WM2_PA',...
    'BOLD_MN1_AP','BOLD_MN1_PA','BOLD_MN2_AP','BOLD_MN2_PA',...
    'BOLD_MN3_AP','BOLD_MN3_PA','BOLD_MN4_AP','BOLD_MN4_PA',...
    'BOLD_IMAGINE1','BOLD_IMAGINE2'};


f=rdir(fullfile(outfolder,subjid,'unprocessed','3T','*','LINKED_DATA','EPRIME'));
for i=1:length(f)
    s{i}=f(i).name(length(fullfile(outfolder,subjid,'unprocessed','3T'))+2:end);
    s{i}=s{i}(1:min(strfind(s{i},filesep))-1);
end
if(~isempty(f))
    str=unique({str{:} s{:}});
end

if(~isempty(strfind(subjid,'HCP')))
    HCP_copy_eprime(subjid,outfolder);
else
    s=unique(s);
    
    for i=1:length(s)
        system(['mkdir -p ' fullfile(outfolder,subjid,s{i},'afni')]);
        system(['mkdir -p ' fullfile(outfolder,subjid,'MNINonLinear','Results',s{i})]);
        system(['cp -v ' fullfile(outfolder,subjid,'/unprocessed/3T',s{i},'LINKED_DATA/EPRIME/EVs','*.txt') ' '  fullfile(outfolder,subjid,s{i},'afni')]);
        system(['cp -vr ' fullfile(outfolder,subjid,'/unprocessed/3T',s{i},'LINKED_DATA/EPRIME/EVs') ' '  fullfile(outfolder,subjid,'MNINonLinear','Results',s{i})]);

    end
end


jobs={};
for idx=1:length(str)
    if(exist(fullfile(outfolder,subjid,str{idx}))==7)
       jobs{end+1}=['HCP_run_afni_level1(''' subjid ''',''' str{idx} ''',''' outfolder ''',[],' num2str(dosmoothing) ')'];
       
    end
end


if(runslurm)
    matlab2slurm(jobs);
else
    for i=1:length(jobs)
        try
            eval(jobs{i});
        end
    end
end

cd(curdir);

