function HCP_submit_Xnat_slurm(dicomfolder,subjid)
% [~,flist]=system(['rsync -vru --size-only /disk/mace2/scan_data/WPC-7030/* /disk/HCP/raw/MRI']);
% f=rdir('/disk/HCP/raw/MRI/**/*BOLD*');
% n={};
% for i=1:length(f)
%     n{i}=fileparts(f(i).name);
% end
% n=unique(n); cmd={};
% for i=1:length(n)
%     [~,subjid]=fileparts(n{i});
%     subjid=['HCP' subjid];
%     cmd{i}=['HCP_submit_Xnat_slurm(''' n{i} ''',''' subjid ''')'];
% end
%         

if(~exist(dicomfolder,'dir'))
    warning([dicomfolder ' is not a DIR']);
    return
end

HCP_matlab_setenv;
% 
% cd /disk/HCP/pipeline/analysis/Xnat/
[~,jsess]=system('./CreateXnatJess.sh');
jsess=jsess(end-32:end);
jsess(double(jsess)==10)=[];



HCP_rename_CCF(dicomfolder);

id=rdir(fullfile(dicomfolder,'BOLD_REST1*'));
if(length(id)>0)
    Session=[subjid '_MR1'];
else
    Session=[subjid '_MR2'];
end
Xnat_AddMRISession(subjid,Session,dicomfolder,jsess,'COBRA',0);



