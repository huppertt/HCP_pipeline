
f=rdir('HCP*/unprocessed/3T/BOLD_MOTOR1_AP/LINKED_DATA/EPRIME/BOLD_MOTOR1_AP_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_MOTOR1_AP/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_MOTOR1_AP/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_MOTOR1_AP/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/Motor.py EVs/BOLD_MOTOR1_AP_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end

 

f=rdir('HCP*/unprocessed/3T/BOLD_MOTOR2_PA/LINKED_DATA/EPRIME/BOLD_MOTOR2_PA_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_MOTOR2_PA/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_MOTOR2_PA/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_MOTOR2_PA/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/Motor.py EVs/BOLD_MOTOR2_PA_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end
 
 
 f=rdir('HCP*/unprocessed/3T/BOLD_WM1_AP/LINKED_DATA/EPRIME/BOLD_WM1_AP_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_WM1_AP/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_WM1_AP/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_WM1_AP/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/WM.py EVs/BOLD_WM1_AP_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end

 

f=rdir('HCP*/unprocessed/3T/BOLD_WM2_PA/LINKED_DATA/EPRIME/BOLD_WM2_PA_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_WM2_PA/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_WM2_PA/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_WM2_PA/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/WM.py EVs/BOLD_WM2_PA_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end
 
 
 
 f=rdir('HCP*/unprocessed/3T/BOLD_LANGUAGE1_AP/LINKED_DATA/EPRIME/BOLD_LANGUAGE1_AP_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_LANGUAGE1_AP/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_LANGUAGE1_AP/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_LANGUAGE1_AP/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/Language.py EVs/BOLD_LANGUAGE1_AP_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end

 

f=rdir('HCP*/unprocessed/3T/BOLD_LANGUAGE2_PA/LINKED_DATA/EPRIME/BOLD_LANGUAGE2_PA_TAB.txt')
 for i=1:length(f);
     s=f(i).name(1:min(strfind(f(i).name,'/'))-1);
     system(['mkdir -p ' s '/MNINonLinear/Results/BOLD_LANGUAGE2_PA/EVs']);
     system(['cp -rv ' f(i).name ' ' s '/MNINonLinear/Results/BOLD_LANGUAGE2_PA/EVs/']);
     cd([s '/MNINonLinear/Results/BOLD_LANGUAGE2_PA/']);
     system('python /disk/HCP/pipeline/projects/Pipelines/tfMRI/scripts/Language.py EVs/BOLD_LANGUAGE2_PA_TAB.txt EVs');
     cd('/disk/sulcus1/COBRA');
 end
 