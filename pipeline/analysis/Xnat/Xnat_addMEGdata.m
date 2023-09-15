function Xnat_addMEGdata(subjid,sessionname,scan,type,file,name,LINKEDDATA,jsess)

setenv('DYLD_LIBRARY_PATH','/Users/huppert/abin')

Project = 'COBRA';

if(~exist('jsess') || isempty(jsess))
    [~,jsess]=system('./CreateXnatJess.sh');
end
system(['./CreateSubject.sh ' Project ' ' subjid ' ' jsess]);
system(['./CreateSessionMEG.sh ' Project ' ' subjid ' ' sessionname ' ' date ' ' jsess]);

system(['./CreateScanMEG.sh ' Project ' ' subjid ' ' sessionname ' ' scan ' ' type ' ' jsess]);

if(~isempty(file))
    system(['./AddFIFFXnat.sh ' Project ' ' subjid ' ' sessionname ' ' ...
        scan ' ' type ' ' file ' ' name]);
end