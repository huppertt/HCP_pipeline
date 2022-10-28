function HCP_SlurmRunAll(subjid,dicomfolder,outfolder)

HCProot='/disk/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

if(~iscell(dicomfolder))
    dicomfolder=cellstr(dicomfolder);
end

for i=1:length(dicomfolder)
   job(1).cmd{i}=['HCP_unpack_data(''' subjid ''',''' dicomfolder{i} ''',''' outfolder ''')'];
end

job(2).cmd{1}=['HCP_sMRI_analysis(''' subjid ''',''' outfolder ''')'];

job(3).cmd=['HCP_fMRI_analysis(''' subjid ''',''' outfolder ''')'];
job(3).cmd{end+1}=['HCP_DTI_analysis(''' subjid ''',''' outfolder ''')'];

job(4).cmd=['HCP_fMRI_surface_analysis(''' subjid ''',''' outfolder ''')'];

for i=1:length(job)
    job(i).slurm = matlab2slurm(job(i).cmd);
end

depend=[];
for i=1:length(job)
    depend=slurm_sub(job(i).slurm,[],depend);
end
