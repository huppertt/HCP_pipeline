function Xnat_addPETSession(subjid,jsess)


setenv('DYLD_LIBRARY_PATH','/Users/huppert/abin')
Project = 'COBRA';

if(nargin<3)
    [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
end

sessionname=[subjid '_PET'];

PETfiles=rdir(fullfile('/disk','HCP','raw','PET',[subjid '*.nii']));

date='1-1-0000';

tbl2=Xnat_get_SubjectInfo(subjid,jsess);
if(isempty(tbl2))
    system(['./CreateSubject.sh ' Project ' ' subjid ' ' jsess]);
    system(['./CreateSessionPET.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);
elseif(isempty(find(ismember(tbl2.project,Project) & ismember(tbl2.label,sessionname))))
    system(['./CreateSessionPET.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);
end

scan='1';
name = 'PET_PIB';
type='PiB';


if(isempty(tbl2) ||  (isempty(find(ismember(tbl2.type,type) & ismember(tbl2.ID,str2num(scan))))))
    system(['./CreateScanPET.sh ' Project ' ' subjid ' ' sessionname ' ' scan ' ' name ' ' jsess]);
    
    for j=1:length(PETfiles)
        disp(PETfiles(j).name);
       % [~,name]=fileparts(PETfiles(j).name);
        system(['./AddPETDICOMXnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
            scan ' ' type ' ' PETfiles(j).name ' ' name ' ' jsess]);
    end
end