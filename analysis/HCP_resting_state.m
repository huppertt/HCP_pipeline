function HCP_resting_state(subjid,outfolder,slurmsub,types)

HCProot='/disk/HCP';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders 

dualscene='/disk/HCP/pipeline/projects/Pipelines/PostFix/PostFixScenes/ICA_Classification_DualScreenTemplate.scene';
singlescene='/disk/HCP/pipeline/projects/Pipelines/PostFix/PostFixScenes/ICA_Classification_SingleScreenTemplate.scene';




if(nargin<4)
    types=[dir(fullfile(outfolder,subjid,'MNINonLinear','Results','BOLD_REST*')); ...
        dir(fullfile(outfolder,subjid,'MNINonLinear','Results','RESTING-STATE-FMRI*'));...
        dir(fullfile(outfolder,subjid,'MNINonLinear','Results','*RFMRI_REST*'))];
        types={types.name};
else
    if(~iscell(types))
        types={types};
    end
end

if(nargin<3)
    slurmsub=false;
end

if(slurmsub)
    type=types{i};
    cmd{i}=['HCP_resting_state(''' subjid ''',''' outfolder ''',0,''' type ''');'];
else
    HCP_matlab_setenv;
    
    
    if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',types{1},[subjid '_' types{1} '_ICA_Classification_dualscreen.scene'])))
        return
    end
    
    setenv('TMP','/disk/HCP/tmp');
    setenv('FSL_FIX_WBC',[getenv('CARET7DIR') '/wb_command']);
    system(['/disk/HCP/pipeline/projects/Pipelines/Examples/Scripts/IcaFixProcessingBatch_pre.sh'...
        ' --StudyFolder=' outfolder ' --Subjlist=' subjid ...
        ' --runlocal --FixDir=/disk/HCP/pipeline/projects/Pipelines/ICAFIX']);
    
    system(['/disk/HCP/pipeline/projects/Pipelines/Examples/Scripts/IcaFixProcessingBatch.sh'...
        ' --StudyFolder=' outfolder ' --Subjlist=' subjid ...
        ' --runlocal --FixDir=/disk/HCP/pipeline/projects/Pipelines/ICAFIX']);
    
    system(['/disk/HCP/pipeline/projects/Pipelines/Examples/Scripts/IcaFixProcessingBatch_post.sh'...
        ' --StudyFolder=' outfolder ' --Subjlist=' subjid ...
        ' --runlocal --FixDir=/disk/HCP/pipeline/projects/Pipelines/ICAFIX'])
end

 
% 
% for i=1:length(types)
%    
%       
%         
%         type=types{i};
%         file=fullfile(outfolder,subjid,'MNINonLinear','Results',type,[type '.nii.gz']);
%         if(exist(file))
%            
%             cd(fullfile(outfolder,subjid,'MNINonLinear','Results',type));
%             
%             system(['/disk/HCP/pipeline/projects/Pipelines/ICAFIX/hcp_fix_pre ' file ' 2000']);
%             
%             
%             system(['/disk/HCP/pipeline/projects/Pipelines/ICAFIX/hcp_fix ' file ' 2000'])
%             
%             if(exist(fullfile(outfolder,subjid,'MNINonLinear','Results',type,[type '_Atlas_hp2000_clean.dtseries.nii']))~=2)
%                 aggressive=0;
%                 domot=1;
%                 cd(fullfile(outfolder,subjid,'MNINonLinear','Results',type,[type '_hp2000.ica']));
%                 fix_3_clean('.fix',aggressive,domot,-1);
%                 system(['mv Atlas_clean.dtseries.nii ../' files(i).name '_Atlas_hp' num2str(hp) '.dtseries.nii']);
%                 cd(fullfile(outfolder,subjid,'MNINonLinear','Results',type))
%             end
%             system(['/disk/HCP/pipeline/projects/Pipelines/ICAFIX/hcp_fix_post ' file ' 2000']);
%             
%             system(['/disk/HCP/pipeline/projects/Pipelines/PostFix/PostFix.sh --template-scene-dual-screen=' dualscene ' --template-scene-single-screen=' singlescene ' --high-pass=2000 --study-folder=' outfolder ...
%                 ' --subject=' subjid ' --fmri-name=' type]);
%         end
%     end
% end

if(slurmsub)
    matlab2slurm(cmd);
end



% 
%  % ${InputDir}/${Condition}_${Direction}.nii.gz
% % 
% % fmri=$1
% % cd `dirname $fmri`
% % fmri=`basename $fmri`
% % 
% % tr=`$FSLDIR/bin/fslval $fmri pixdim4`
% % 
% system([fullfile(HCProot,'pipeline','projects','Pipelines','Examples','Scripts','IcaFixProcessingBatch_pre.sh') ...
%     ' --StudyFolder=' outfolder ' --Subjlist=' subjid ' --runlocal'])
% 
% if(nargin<3)
%     slurmsub=false;
% end
% 
% if(slurmsub & nargin<4)
%     files=dir(fullfile(outfolder,subjid,'BOLD_*'));
%     cmd={};
%     for i=1:length(files)
%         cmd{i}=['HCP_resting_state(''' subjid ''',''' outfolder ''',0,''' files(i).name ''');'];
%     end
%     matlab2slurm(cmd);
%     return
% elseif(~slurmsub & nargin==4)
%     files=dir(fullfile(outfolder,subjid,[file '*']));
% else
%     files=dir(fullfile(outfolder,subjid,'BOLD_*'));
% end
% 
% 
% curdir=pwd;
% 
% 
% for i=1:length(files)
%     cd(fullfile(outfolder,subjid,'MNINonLinear','Results'))
%     
%     fileIn=fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '.nii.gz']);
%     system([HCProot '/pipeline/projects/Pipelines/ICAFIX/hcp_fix_pre ' fileIn ' 2000']);
%    
%     cd(fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '_hp2000.ica']));
%     filen=fullfile(outfolder,subjid,files(i).name,[files(1).name '_orig.nii.gz']);
%     [~,tr]=system([getenv('FSLDIR') '/bin/fslval ' filen ' pixdim4']);
%     tr = str2num(tr);
%     hp= 2000;
%     functionmotionconfounds(hp,tr);
%     
%     cd(fullfile(outfolder,subjid,'MNINonLinear','Results'));
%     
%     fileIn=fullfile(outfolder,subjid,'MNINonLinear','Results',files(i).name,[files(i).name '_hp' num2str(hp)]);
%     cd([fileIn '.ica']);
%     system('mkdir -p reg');
%     cd('reg');
%     system('$FSLDIR/bin/imln ../../../../T1w_restore_brain highres');
%     system('$FSLDIR/bin/imln ../../../../wmparc wmparc');
%     system('$FSLDIR/bin/imln ../mean_func example_func');
%     system('$FSLDIR/bin/makerot --theta=0 > highres2example_func.mat');
%     
%     [s,r]=system('$FSLDIR/bin/imtest ../../../../T2w');
%     if(r)
%         system('$FSLDIR/bin/fslmaths ../../../../T1w -div ../../../../T2w veins -odt float');
%         system('$FSLDIR/bin/flirt -in ${FSL_FIXDIR}/mask_files/hcp_0.7mm_brain_mask -ref veins -out veinbrainmask -applyxfm');
%         system('$FSLDIR/bin/fslmaths veinbrainmask -bin veinbrainmask');
%         system('$FSLDIR/bin/fslmaths veins -div `$FSLDIR/bin/fslstats veins -k veinbrainmask -P 50` -mul 2.18 -thr 10 -min 50 -div 50 veins');
%         system('$FSLDIR/bin/flirt -in veins -ref example_func -applyxfm -init highres2example_func.mat -out veins_exf');
%         system('$FSLDIR/bin/fslmaths veins_exf -mas example_func veins_exf');
%     end
%     cd(fullfile(outfolder,subjid,'MNINonLinear','Results'));
%     
%     trainingfiles=fullfile(getenv('FSL_FIXDIR'),'training_files','HCP_hp2000.RData');
%     thres=10;
%     domot=true;
%     
%     MELOUT=[fileIn '.ica'];
%     
%     path(path,getenv('FSL_FIXDIR'))
%     
%     % Mode 1
%     %         ${FSL_FIXDIR}/fix -f $MELOUT
%     disp(['FIX Feature extraction for Melodic output directory: ' MELOUT])
%     system(['mkdir -p '  MELOUT '/fix']);
%     
%     disp('create edge masks')
%     system(['${FSL_FIXDIR}/fix_0a_create_edge_masks ' MELOUT])
%     disp(' run FAST')
%     system(['${FSL_FIXDIR}/fix_0b_apply_fast ' MELOUT]);
%     disp(' registration of standard space masks')
%     system(['${FSL_FIXDIR}/fix_0c_reg_masks ' MELOUT ' ${FSL_FIXDIR}']);
%     disp(' extract features');
%     
%     fix_1a_extract_features(MELOUT);
%     
%     
%     % Mode 3
%     %         ${FSL_FIXDIR}/fix -c $MELOUT $TRAIND/${TRAIN}.RData $THRESH
%     
%    disp(['FIX Classifying components in Melodic directory: ' MELOUT ' using training file: ' trainingfiles ' and threshold ' num2str(thres) ]);
%     %     CheckFeatures $MELOUT
%     system(['R CMD BATCH --no-save --no-restore ''--args ' getenv('FSL_FIXDIR') ' ' MELOUT ' ' trainingfiles ' ' num2str(thres) '''' ' ${FSL_FIXDIR}/fix_2b_predict.R '  MELOUT '/.fix_2b_predict.log'])
%     %     R CMD BATCH "--no-restore --no-save --args ${FSL_FIXDIR} ${MELOUT} ${TRAIN} ${THRESH}" ${FSL_FIXDIR}/fix_2b_predict.R ${MELOUT}/.fix_2b_predict.log
%     %     ;;
%     
%     
%     % Mode 4
%     
%     %         ${FSL_FIXDIR}/fix -a ${MELOUT}/fix4melview_${TRAIN}_thr${THRESH}.txt $*
%     disp(['FIX Applying cleanup using cleanup file: ' MELOUT ' and motion cleanup'])
%     
%     cd(MELOUT)
%     setenv('WBC',[getenv('CARET7DIR') '/wb_command'])
%     
%     fix='fix4melview_HCP_hp2000_thr10.txt'
%     system([' tail -n 1 ' fix ' | sed ''s/\[//g'' | sed ''s/\]//g'' | sed ''s/,//g'' > .fix'])
%     
%     aggressive=0;
%     fix_3_clean('.fix',aggressive,domot,-1);
%     
%     
%     %/bin/mv ${fmri}.ica/Atlas_clean.dtseries.nii ${fmri_orig}_Atlas_hp${hp}_clean.dtseries.nii
%     system(['mv Atlas_clean.dtseries.nii ../' files(i).name '_Atlas_hp' num2str(hp) '.dtseries.nii']);	
%     
%     
%     %     cd `dirname $MELOUT`
%     %     MELOUT=`basename $MELOUT`
%     %     hp=-1
%     %     [ -f design.fsf ] && [ _`grep fmri\(temphp_yn\) design.fsf | awk '{print $3}'` = _1 ] && hp=`grep fmri\(paradigm_hp\) design.fsf | awk '{print $3}'`
%     %     [ _$HP = _ ] && HP=$hp
%     %     tail -n 1 $MELOUT | sed 's/\[//g' | sed 's/\]//g' | sed 's/,//g' > .fix
%     %     ${FSL_FIXDIR}/call_matlab.sh -l .fix.log -f fix_3_clean .fix $aggressive $domot $HP
%     %     ;;
%     
%     
%     %${FSL_FIXDIR}/fix ${fmri}.ica ${FSL_FIXDIR}/training_files/HCP_hp2000.RData 10 -m -h 2000
%     
%     %/bin/mv ${fmri}.ica/Atlas_clean.dtseries.nii ${fmri_orig}_Atlas_hp${hp}_clean.dtseries.nii
%     
%     
% end
% 
% 
% 
% cd(curdir)
% 
% % system([fullfile(HCProot,'pipeline','projects','Pipelines','Examples','Scripts','IcaFixProcessingBatch_post.sh') ...
% %     ' --StudyFolder=' outfolder ' --Subjlist=' subjid ' --runlocal'])