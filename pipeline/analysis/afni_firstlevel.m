function [cmd stim_labels]=afni_firstlevel(data,folder,options)
% %This function will run the first level analysis of fMRI data using AFNI
% 
% % example 1:
% % AFNI demo data #2
% data.subjid = 'ED';
% p=fileparts(which('afni_firstlevel.m'));
% data.T1 = fullfile(p,'Afni_demos/AFNI_data2/ED/EDspgr');
% data.epi = {fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r01+orig'),...
%            fullfile(p, 'Afni_demos/AFNI_data2/ED/ED_r02+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r03+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r04+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r05+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r06+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r07+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r08+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r09+orig'),...
%             fullfile(p,'Afni_demos/AFNI_data2/ED/ED_r10+orig')};
% data.stim(1).name='ToolMovie';
% data.stim(1).file=fullfile(p,'Afni_demos/AFNI_data2/misc_files/stim_times.01.1D');
% data.stim(2).name='HumanMovie';
% data.stim(2).file=fullfile(p,'Afni_demos/AFNI_data2/misc_files/stim_times.02.1D');
% data.stim(3).name='ToolPoint';
% data.stim(3).file=fullfile(p,'Afni_demos/AFNI_data2/misc_files/stim_times.03.1D');
% data.stim(4).name='HumanPoint';
% data.stim(4).file=fullfile(p,'Afni_demos/AFNI_data2/misc_files/stim_times.04.1D');
% 
% options.afni_flags =[];  % use defaults
% options.basis = 'TENT(0,14,8)';
%
% options.glt(1).name = 'FullF';
% options.glt(1).c = [1 1 1 1];
% options.glt(2).name = 'HvsT';
% options.glt(2).c = [-1 1 -1 1];
% options.glt(3).name = 'MvsP';
% options.glt(3).c = [1 1 -1 -1];
% options.glt(4).name = 'HMvHP';
% options.glt(4).c = [0 1 0 -1];
% options.glt(5).name = 'TMvsTP';
% options.glt(5).c = [1 0 -1 0];
% options.glt(6).name = 'HPvsTP';
% options.glt(6).c = [0 0 -1 1];
% options.glt(7).name = 'HMvsTM';
% options.glt(7).c = [-1 1 0 0];
%
% folder =fullfile(p,'tmp_afni');
%
% afni_firstlevel(data,folder,options)
% 
% 
%      -surf_anat      : volumed aligned with surface
%                 -surf_spec      : spec file(s) for surface

                    
subjid=data.subjid;

options.afni_flags = check_afni_options(options.afni_flags);

if(exist(folder,'dir')~=7)
    mkdir(folder);
end

%Folder to move all the MRI data to
folder=fullfile(folder,subjid);
if(exist(folder,'dir')~=7)
    mkdir(folder);
end
cd(folder);


%Folder to put all the stimulus informaiton into
miscfolder=fullfile(folder,'misc');
if(exist(miscfolder,'dir')~=7)
    mkdir(miscfolder);
end

T1 = convert_copy(data.T1,folder,'anat');
[dsets,nTRS] = convert_copy(data.epi,folder,'epi');

[stim1D stim_labels] = make1dfiles(miscfolder,data.stim,nTRS,options);
[glt glt_labels] = makegltfiles(miscfolder,stim_labels,options);


%Now make the cmd for afni_proc.py

cmd = 'afni_proc.py';
cmd = sprintf('%s -dsets %s',cmd,dsets);
cmd = sprintf('%s -subj_id %s',cmd,subjid);
cmd = sprintf('%s -copy_anat %s',cmd,T1);

cmd = sprintf('%s -do_block despike -do_block tshift -do_block blur -do_block scale',cmd);


flds=fields(options.afni_flags);
for idx=1:length(flds)
    cmd=sprintf('%s -%s %s',cmd,flds{idx},getfield(options.afni_flags,flds{idx}));
end


%Stim times
cmd = sprintf('%s -regress_stim_times',cmd);
for idx=1:length(stim1D)
    cmd = sprintf('%s %s',cmd,stim1D{idx});
end

cmd = sprintf('%s -regress_stim_types',cmd);
for idx=1:length(stim1D)
    cmd = sprintf('%s %s',cmd,'AM1');
    %cmd = sprintf('%s %s',cmd,'AM2');
end

cmd = sprintf('%s -regress_stim_labels',cmd);
for idx=1:length(stim1D)
    cmd = sprintf('%s %s',cmd,stim_labels{idx});
end

cmd = sprintf('%s -regress_opts_3dD',cmd);

    for idx=1:length(glt)
        cmd = sprintf('%s -gltsym %s -glt_label %d %s',cmd,glt{idx},idx,glt_labels{idx});
        stim_labels{end+1}=glt_labels{idx};
    end

%      
%  align_epi_anat.py -anat sb23_mpra+orig -epi epi_r03+orig      \
%                         -epi_base 5 -child_epi epi_r??+orig.HEAD    \
%                         -epi2anat -suffix al2anat
                        
                        
% setenv('PATH',[getenv('PATH') ':/home/pkg/software/fsl/fsl/bin']);
% setenv('PATH',[getenv('PATH') ':/home/pkg/software/fsl/fsl/etc/fslconf']);
% setenv('FSLDIR','/home/pkg/software/fsl/fsl')
% system('source ${FSLDIR}/etc/fslconf/fsl.sh')

setenv('FSLOUTPUTTYPE','NIFTI_GZ')
setenv('PATH',[getenv('PATH') ':/home/pkg/software/afni/linux_xorg7_64/']);
setenv('AFNI_PLUGINPATH',':/home/pkg/software/afni/linux_xorg7_64/')   

system(cmd);

cmd=['tcsh -xef ' folder filesep 'proc.' subjid ' |& tee ' folder filesep 'output.proc.' subjid];
return
   

function [dsets varargout] = convert_copy(data,folder,name)
%This function copies MRI data to folder and converts to BRIK format

if(~iscell(data))
    data={data};
end

if(strcmp(name,'anat'))
    type='spgr';
else
    type='fim';
end

dsets =[];
for idx=1:length(data)
    if(length(data)>1)
        name2=[name num2str(idx)];
    else
        name2=name;
    end
    
    % First, copy all the data in the destination folder
    system(['cp ' data{idx} '* ' folder]);

    if(~isBRIK(data{idx}))
        %Now convert to BRIK format
        curdir=pwd;
        cd(folder);
        system(['rm -fv ' name2 '+orig.*']);
        nTRS{idx}=convertDICOM2BRIK(pwd,dir('MR*'),type,name2);
        % system(['to3d -prefix ' name2 ' MR.*']);
        system('rm -f MR*');
        cd(curdir);
        data{idx}=fullfile(folder,[name2 '+orig']);
    end
    
    [~,file,ext]=fileparts(data{idx});
    dsets = sprintf('%s %s%s%s%s',dsets,folder,filesep,file,ext);
    
end

if(nargout==2)
    varargout{1}=nTRS;
end


return

function flag=isBRIK(data)

[~,data,~]=fileparts(data);

if(strcmp(data(1:2),'MR'))
    flag=false;
else
    flag=true;
end

return


function [stim1D stim_labels] = make1dfiles(miscfolder,stim,nTRS,options);
% This function converts stim to *.1D files and copies to miscfolder

stim_labels ={};
stim1D={};
flag=false;
for idx=1:length(stim)
    if(~isstruct(stim(idx).file) & is1D(stim(idx).file))
        %just copy
        flag=true;
        stim_labels{idx}=stim(idx).name;
        system(['cp ' stim(idx).file ' ' miscfolder]);
        [~,f,e]=fileparts(stim(idx).file);
        stim1D{idx}=sprintf('%s%s%s%s',miscfolder,filesep,f,e);
    end
end
if(~flag)
    stim_labels={};
    for idx=1:length(stim)
        stim_labels={stim_labels{:} stim(idx).file.name};
    end
    stim_labels=unique(stim_labels);
    
    for cond=1:length(stim_labels)
        fid=fopen([miscfolder filesep stim_labels{cond} '.1D'],'w');
       % fid2=fopen([stim_labels{cond} '_amp.1D'],'w');
        stim1D{cond}=[miscfolder filesep stim_labels{cond} '.1D'];
        for cf=1:length(stim)
            onsets=[];
            dur=[];
            amp=[];
            for c=1:length(stim(cf).file)
                if(strcmp(stim(cf).file(c).name,stim_labels{cond}));
                    onsets=[onsets stim(cf).file(c).onset];
                    dur=[dur stim(cf).file(c).dur];
                    if(~isfield(stim(cf).file(c),'amp') | isempty(stim(cf).file(c).amp))
                        stim(cf).file(c).amp=ones(size(stim(cf).file(c).onset));
                    end
                        
                    amp=[amp stim(cf).file(c).amp];
                end
            end
                                 
            if(length(amp) ~=length(onsets))
                amp=amp(1)*ones(size(onsets));
            end
            
            if(length(dur) ~=length(onsets))
                dur=dur(1)*ones(size(onsets));
            end
            
            [~,lst]=sort(onsets);
            onsets=onsets(lst);
            amp=amp(lst);
            duvr=dur(lst);
            
            for idx2=1:length(onsets)
                fprintf(fid,'%d*%d:%d\t',onsets(idx2),amp(idx2),dur(idx2));
                %fprintf(fid2,'%d\t',amp(idx2));
            end
            if(length(onsets)==0)
                fprintf(fid,'%d*%d:%d\t',-999,0,1);
            end
            fprintf(fid,'\r\n');
           % fprintf(fid2,'\r\n');
            
            
        end
        
        fclose(fid);
      %  fclose(fid2);
    end
end

return

function flag = is1D(file)

[~,~,ext]=fileparts(file);
if(strcmp(ext,'.1D'))
    flag=true;
else
    flag=false;
end

return


function [glt_files glt_labels] = makegltfiles(miscfolder,stim_labels,options);

if(isfield(options,'glt'))
    glt=options.glt;
else
    %% ???
end

glt_labels={};
glt_files={};
for idx=1:length(glt)
    glt_files{idx}=fullfile(miscfolder,['glt',num2str(idx) '.txt']);
    glt_labels{idx}=glt(idx).name;
    str=[];
    if(~isstr(glt(idx).c))
    for idx2=1:length(glt(idx).c)
        if(glt(idx).c(idx2)==1)
            str=sprintf('%s +%s',str,stim_labels{idx2});
        elseif(glt(idx).c(idx2)==-1)
            str=sprintf('%s -%s',str,stim_labels{idx2});
        end
    end
    writeglt(glt_files{idx},str);
     else
        glt_files{idx}=['''SYM: ' glt(idx).c ''''];
        
    end
    
    
end


return


function writeglt(file,str);

fid=fopen(file,'w');
fprintf(fid,'%s\n\r',str);
fclose(fid);

function afni_flags = check_afni_options(afni_flags)


if(~isfield(afni_flags,'tcat_remove_first_trs'))
    afni_flags=setfield(afni_flags,'tcat_remove_first_trs','0');
elseif(~isstr(getfield(afni_flags,'tcat_remove_first_trs')))
    setfield(afni_flags,'tcat_remove_first_trs',num2str(getfield(afni_flags,'tcat_remove_first_trs')));
end

if(~isfield(afni_flags,'volreg_align_to'))
    afni_flags=setfield(afni_flags,'volreg_align_to','third');
end

if(~isfield(afni_flags,'regress_est_blur_epits'))
    afni_flags=setfield(afni_flags,'regress_est_blur_epits','');
end


if(~isfield(afni_flags,'regress_apply_mot_types'))
    afni_flags=setfield(afni_flags,'regress_apply_mot_types','demean deriv');
end
if(~isfield(afni_flags,'regress_censor_motion'))
    afni_flags=setfield(afni_flags,'regress_censor_motion','0.3');
end
if(~isfield(afni_flags,'regress_censor_outliers'))
    afni_flags=setfield(afni_flags,'regress_censor_outliers','0.1');
end
                             
                        
if(~isfield(afni_flags,'regress_est_blur_errts'))
    afni_flags=setfield(afni_flags,'regress_est_blur_errts','');
end

if(~isfield(afni_flags,'regress_basis'))
    afni_flags=setfield(afni_flags,'regress_basis','''dmBLOCK(1)''');
end


if(~isfield(afni_flags,'regress_make_ideal_sum'))
    afni_flags=setfield(afni_flags,'regress_make_ideal_sum','sum_ideal.1D');
end


if(~isfield(afni_flags,'check_afni_version'))
    afni_flags=setfield(afni_flags,'check_afni_version','no');
end


if(~isfield(afni_flags,'tlrc_anat'))
    afni_flags=setfield(afni_flags,'tlrc_anat','');
end

if(~isfield(afni_flags,'volreg_tlrc_warp'))
    afni_flags=setfield(afni_flags,'volreg_tlrc_warp','');
end

if(~isfield(afni_flags,'regress_reml_exec'))
    afni_flags=setfield(afni_flags,'regress_reml_exec','');
end
 
if(~isfield(afni_flags,'blur_size'))
    afni_flags=setfield(afni_flags,'blur_size','4.0');
end