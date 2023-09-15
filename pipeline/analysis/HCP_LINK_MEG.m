function HCP_LINK_MRI(subjid)

folder= '/disk/HCP/raw/EPRIME_MEG';



key{1,1}='MEG_Wrkmem_run1';
key{2,1}='MEG_Wrkmem_run2';
key{3,1}='MEG_Motort_run1';
key{4,1}='MEG_Motort_run2';
key{5,1}='MEG_StoryM_run1';
key{6,1}='MEG_StoryM_run2';

key{1,2}='MEG_WM1';
key{2,2}='MEG_WM2';
key{3,2}='MEG_MOTOR1';
key{4,2}='MEG_MOTOR2';
key{5,2}='MEG_LANGUAGE1';
key{6,2}='MEG_LANGUAGE2';

for i=1:size(key,1)
    f=rdir(fullfile(folder,subjid,['*' key{i,1} '*']));
    for j=1:length(f)
        [~,~,ext]=fileparts(f(j).name);
        f2=fullfile('/disk/HCP/analyzed',subjid,'unprocessed','MEG',key{i,2},'LINKED_DATA','EPRIME');
        system(['mkdir -p ' f2]);
        system(['rsync -vru --size-only ' f(j).name ' ' f2 filesep key{i,2} ext]);
    end
end