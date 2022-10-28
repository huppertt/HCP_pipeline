function HCP_Xnat_unpack(project,subjid)

disp(project);
disp(subjid);

% This function will unpack the converted NII files created by Xnat and
% move to a HCP_like data format

tmpfolder=fullfile('/disk','sulcus',project,subjid);

HCP_matlab_setenv;

scans=rdir(fullfile(tmpfolder,'temp','*_MR1','scans'));
if(~isempty(scans))
    system(['mkdir -p ' fullfile(tmpfolder,'unprocessed','3T')]);
    remap=HCP_sort_Xnat_Nifti(scans,1);
    
    for i=1:length(remap)
        fold=fullfile(tmpfolder,'unprocessed','3T',remap(i).outfolder);
        system(['mkdir -p ' fold]);
        for j=1:size(remap(i).files,1)
            f1=remap(i).files{j,1};
            f2=fullfile(fold,[subjid '_3T' remap(i).files{j,2}]);
            if(~exist(f2,'file'))
                system(['cp -v ' f1 ' ' f2]);
            end
        end
    end
end

scans=rdir(fullfile(tmpfolder,'temp','*_MR2','scans'));
if(~isempty(scans))
    system(['mkdir -p ' fullfile(tmpfolder,'unprocessed','3T')]);
    remap=HCP_sort_Xnat_Nifti(scans,2);
    
    for i=1:length(remap)
        fold=fullfile(tmpfolder,'unprocessed','3T',remap(i).outfolder);
        system(['mkdir -p ' fold]);
        for j=1:size(remap(i).files,1)
            f1=remap(i).files{j,1};
            f2=fullfile(fold,[subjid '_3T' remap(i).files{j,2}]);
            if(~exist(f2,'file'))
                system(['cp -v ' f1 ' ' f2]);
            end
        end
    end
end


scans=rdir(fullfile(tmpfolder,'temp',subjid,'scans'));
if(~isempty(scans))
    system(['mkdir -p ' fullfile(tmpfolder,'unprocessed','3T')]);
    remap=HCP_sort_Xnat_Nifti(scans,1);
    
    for i=1:length(remap)
        fold=fullfile(tmpfolder,'unprocessed','3T',remap(i).outfolder);
        system(['mkdir -p ' fold]);
        for j=1:size(remap(i).files,1)
            f1=remap(i).files{j,1};
            f2=fullfile(fold,[subjid '_3T' remap(i).files{j,2}]);
            if(~exist(f2,'file'))
                system(['cp -v ' f1 ' ' f2]);
            end
        end
    end
end