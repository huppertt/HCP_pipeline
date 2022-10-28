function HCP_resting_state_MAC(subjid,force)

if(nargin<2)
    force=false;
end

HCProot='/Users/theodorehuppert/Desktop/';
outfolder='/Users/theodorehuppert/Desktop/HCP2';


HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

setenv('FSLDIR','/usr/local/fsl');
setenv('FSL_FIX_WBC','/Users/theodorehuppert/Desktop/workbench/bin_macosx64/wb_command');
setenv('FSL_FIXDIR','/users/theodorehuppert/Desktop/fix-master');
setenv('PATH',[getenv('PATH') ':' getenv('FSLDIR') filesep 'bin']);
setenv('HCPPIPEDIR','/Users/theodorehuppert/Desktop//pipeline/HCPpipelines-master');
setenv('FSL_FIX_MATLAB','/Applications/MATLAB_R2018b.app/bin/matlab');
setenv('FSL_FIX_MATLAB_MODE','1');
setenv('FSL_FIX_R_CMD','/usr/local/bin/R');
path(path,getenv('FSL_FIXDIR'))
setenv('PATH',[getenv('PATH') ':/usr/local/bin'])
path(path,'/Users/theodorehuppert/Desktop/pipeline/HCPpipelines-master/global/matlab/')

files=dir(fullfile(outfolder,subjid,'BOLD_*'));
lst=[];
for i=1:length(files)
    if(files(i).isdir)
        lst=[lst i];
    end
end
files=files(lst);

curdir=pwd;


for i=1:length(files)  
    hp= 2000;
    try
        if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '_Atlas_hp' num2str(hp) '.dtseries.nii']))==0 & ~force)
            cd(fullfile(outfolder,subjid,'MNINonLinear','Results'))
            
            fileIn=fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '.nii.gz']);
            trainingfiles=fullfile(getenv('FSL_FIXDIR'),'training_files','HCP_hp2000.RData');
            trainingfiles='HCP_hp2000.RData';
            
            cd(fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name));
            system([HCProot '/pipeline/HCPpipelines-master/ICAFIX/hcp_fix ' fileIn ' 2000 TRUE ' trainingfiles]);
            
            
            filen=fullfile(outfolder,subjid,files(i).name,[files(1).name '_orig.nii.gz']);
            system(['mkdir -p ' fileIn '.ica']);
            cd([fileIn '.ica']);
%             [~,tr]=system([getenv('FSLDIR') '/bin/fslval ' filen ' pixdim4']);
%             tr = str2num(tr);
%              hp= 2000;
%             functionmotionconfounds(hp,tr);
            
             fileIn=fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '_hp' num2str(hp)]);
             
%              system('mkdir -p reg');
%             cd('reg');
%             system('$FSLDIR/bin/imln ../../../../T1w_restore_brain highres');
%             system('$FSLDIR/bin/imln ../../../../wmparc wmparc');
%             system('$FSLDIR/bin/imln ../mean_func example_func');
%             system('$FSLDIR/bin/makerot --theta=0 > highres2example_func.mat');
%             
%             [s,r]=system('$FSLDIR/bin/imtest ../../../../T2w');
%             if(r)
%                 system('$FSLDIR/bin/fslmaths ../../../../T1w -div ../../../../T2w veins -odt float');
%                 system('$FSLDIR/bin/flirt -in ${FSL_FIXDIR}/mask_files/hcp_0.7mm_brain_mask -ref veins -out veinbrainmask -applyxfm');
%                 system('$FSLDIR/bin/fslmaths veinbrainmask -bin veinbrainmask');
%                 system('$FSLDIR/bin/fslmaths veins -div `$FSLDIR/bin/fslstats veins -k veinbrainmask -P 50` -mul 2.18 -thr 10 -min 50 -div 50 veins');
%                 system('$FSLDIR/bin/flirt -in veins -ref example_func -applyxfm -init highres2example_func.mat -out veins_exf');
%                 system('$FSLDIR/bin/fslmaths veins_exf -mas example_func veins_exf');
%             end
             
             thres=10;
             domot=true;
             
             MELOUT=[fileIn '_hp2000.ica'];

%              % Mode 1
%             disp(['FIX Feature extraction for Melodic output directory: ' MELOUT])
%             system(['mkdir -p '  MELOUT '/fix']);
%             cd([MELOUT '/fix']);
%             disp('create edge masks')
%             system(['${FSL_FIXDIR}/fix_0a_create_edge_masks ' MELOUT])
%             disp(' run FAST')
%             system(['${FSL_FIXDIR}/fix_0b_apply_fast ' MELOUT]);
%             disp(' registration of standard space masks')
%             system(['${FSL_FIXDIR}/fix_0c_reg_masks ' MELOUT ' ${FSL_FIXDIR}']);
%             disp(' extract features');
%             
%             fix_1a_extract_features(MELOUT,false);
%             
            
            trainingfiles=fullfile(getenv('FSL_FIXDIR'),'training_files','HCP_hp2000.RData');
            
            disp(['FIX Classifying components in Melodic directory: ' MELOUT ' using training file: ' trainingfiles ' and threshold ' num2str(thres) ]);
            %     CheckFeatures $MELOUT
            system(['R CMD BATCH --no-save --no-restore ''--args ' getenv('FSL_FIXDIR') ' ' MELOUT ' ' trainingfiles ' ' num2str(thres) '''' ' ${FSL_FIXDIR}/fix_2b_predict.R '  MELOUT '/.fix_2b_predict.log'])
            
            
            disp(['FIX Applying cleanup using cleanup file: ' MELOUT ' and motion cleanup'])
            
            cd(MELOUT)
            setenv('WBC',[getenv('CARET7DIR') '/wb_command'])
            
            fix='fix4melview_HCP_hp2000_thr10.txt'
            system([' tail -n 1 ' fix ' | sed ''s/\[//g'' | sed ''s/\]//g'' | sed ''s/,//g'' > .fix'])
            
            system(['ln -s ../' files(i).name '_Atlas.dtseries.nii ./Atlas.dtseries.nii'])
            
            aggressive=0;
            fix_3_clean('.fix',aggressive,domot,-1);
            
            
            system(['mv Atlas_clean.dtseries.dtseries.nii ../' files(i).name '_Atlas_hp' num2str(hp) '.dtseries.nii']);
            system(['mv Atlas_clean_vn.dscalar.dscalar.nii ../' files(i).name '_Atlas_hp_' num2str(hp) '_vn.dscalar.nii']);

        end
    end
    
end

cd(curdir)
%  
% system([fullfile(HCProot,'pipeline','projects','Pipelines','Examples','Scripts','IcaFixProcessingBatch_post.sh') ...
%     ' --StudyFolder=' outfolder ' --Subjlist=' subjid ' --runlocal'])