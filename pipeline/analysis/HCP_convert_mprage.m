function info=HCP_convert_mprage(dicomfolder,subjid,outfolder)
HCProot='/disk/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;

f=dir(dicomfolder);

lst=ismember({f.name},{'.','..','.DS_Store'});
f(lst)=[];

StudyNameMap=fullfile('unprocessed','3T','T1w_MPR1',[subjid '_3T_T1w_MPR1.nii.gz'])


if(~exist(outfolder))
    mkdir(outfolder)
end
mkdir(fullfile(outfolder,subjid));
lst=[0 strfind(StudyNameMap,filesep)];
localfol=fullfile(outfolder,subjid);
for idx2=1:length(lst)-1;
    localfol=fullfile(localfol,StudyNameMap(lst(idx2)+1:lst(idx2+1)-1));
    if(~exist(localfol))
        mkdir(localfol);
    end
end

for i = 1:length(f)
    [path,filename,ext]=fileparts(f(i).name);
    if(strcmp(ext,'.img'))
        a = load_nii(fullfile(pwd,f(i).name));
        save_nii(a,fullfile(pwd,strcat(subjid,'.nii')));
% 	system(['mri_convert ' dicomfolder filesep f(1).name ' ' outfolder filesep subjid filesep StudyNameMap]);
        info = [];
        break;
    else 
% 	system(['mri_convert -it siemens_dicom ' dicomfolder filesep f(1).name ' ' outfolder filesep subjid filesep StudyNameMap]);
% 	info=dicominfo(fullfile( dicomfolder,f(1).name));
    end
end