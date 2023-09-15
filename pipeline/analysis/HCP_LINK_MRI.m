function HCP_LINK_MRI(subjid)

folder= '/disk/HCP/raw/EPRIME_fMRI';



key{1,1}='WM_run1';
key{2,1}='WM_run2';
key{3,1}='MOTOR_run1';
key{4,1}='MOTOR_run2';
key{5,1}='LANGUAGE_run1';
key{6,1}='LANGUAGE_run2';

key{1,2}='BOLD_WM1_AP';
key{2,2}='BOLD_WM2_PA';
key{3,2}='BOLD_MOTOR1_AP';
key{4,2}='BOLD_MOTOR2_PA';
key{5,2}='BOLD_LANGUAGE1_AP';
key{6,2}='BOLD_LANGUAGE2_PA';

for i=1:size(key,1)
    f=rdir(fullfile(folder,subjid,['*' key{i,1} '*']));
    for j=1:length(f)
        [~,~,ext]=fileparts(f(j).name);
        f2=fullfile('/disk/HCP/analyzed',subjid,'unprocessed','3T',key{i,2},'LINKED_DATA','EPRIME');
        system(['mkdir -p ' f2]);
        system(['rsync -vru --size-only ' f(j).name ' ' f2 filesep key{i,2} ext]);
    end
end