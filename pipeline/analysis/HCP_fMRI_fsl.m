function HCP_fMRI_fsl(subjid,outfolder,force)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end


HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

HCP_copy_eprime(subjid,outfolder);
% 
f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD*','EVs','*.fsf'));
%
 if(isempty(f))
     f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD*','LINKED_DATA','EPRIME','EVs','*.fsf'));
         
     for i=1:length(f)
         [p,f2,e]=fileparts(f(i).name);
         system(['cp -v ' f(i).name ' ' p '/../../../' f2 e]);
     end
     f=rdir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD*','*.fsf'));
 
 end
 
% 
% for i=1:length(f)
%     str=f(i).name(length(fullfile(outfolder,subjid,'MNINonLinear','Results'))+2:end);
%     str=str(1:min(strfind(str,filesep))-1);
%     
%     system(['/disk/HCP/pipeline/projects/Pipelines/TaskfMRIAnalysis/scripts/TaskfMRILevel1.v2.0.sh ' subjid ' ' ...
%         fullfile(outfolder,subjid,'MNINonLinear/Results') ' ' fullfile(outfolder,subjid,'MNINonLinear/ROIs') ' '...
%         fullfile(outfolder,subjid,'/MNINonLinear/fsaverage_LR32k') ' ' str ' ' str ' 32 2 2 NONE 2 200 NO NONE NONE NONE']);
% end

system(['source ' HCProot '/pipeline/projects/Pipelines/Examples/Scripts/TaskfMRIAnalysisBatch.sh --runlocal --StudyFolder=' ...
    outfolder ' --Subjlist="' subjid '"'])
