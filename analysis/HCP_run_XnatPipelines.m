

 [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
    
    
tbl = Xnat_get_SessionInfo(jsess);


tbl(~ismember(tbl.xsiType,'xnat:mrSessionData'),:)=[];


tbl=Xnat_get_SubjectInfo('HCP201',jsess);
tbl(~ismember(tbl.xsiType,'xnat:mrSessionData'),:)=[];

for i=1:height(tbl)
    system(['XnatDataClientCerebro -s ' jsess ' -m GET -r http://10.48.86.212:8080' tbl.URI{i} '/files?format=zip']);
    system('unzip download.zip')
    f=rdir([tbl.label{i} '**/*.dcm']);    
    system(['dcm2nii ' f(1).name]);

    ff=rdir([tbl.label{i} '/**/*.nii.gz']); 

    system(['XnatDataClientCerebro -s ' jsess ' -m PUT -r http://10.48.86.212:8080' tbl.URI{i} '/files?format=zip']);
    
    [~,f,ex]=fileparts(ff(1).name);
      system(['./Xnat_AddMRI_NIFTI.sh ' tbl.project{i} ' ' tbl.SubjID{i} ' ' tbl.label{i} ' ' ...
               '1' ' ' tbl.type{i} ' ' f ex ' ' ff(i).name ' ' jsess]);
    
end
