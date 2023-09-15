function tbl=HCP_check_analysis(subjid,outfolder)
HCP_matlab_setenv;

HCProot='/aionraid/huppertt/raid2_BU/HCP/';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

subjid={};
if(nargin<1 || isempty(subjid))
    s=dir(outfolder);
    cnt=1;
    for i=1:length(s)
        if(s(i).isdir && ~strcmp(s(i).name(1),'.') && isempty(strfind(s(i).name,'Group')))
            if(HCP_blacklist(s(i).name))
                continue;
            end
            subjid{cnt}=s(i).name;
            cnt=cnt+1;
        end
    end
end

cdir=pwd;
cd([HCProot '/pipeline/analysis/Xnat']);
[~,jsess]=system('./CreateXnatJess.sh');
if(isempty(strfind(jsess,'not found')))
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
    tblXnat = Xnat_get_SessionInfo(jsess);
else
    tblXnat=[];
end
cd(cdir);


if(~iscellstr(subjid))
    subjid={subjid};
end

% 
%     stage = {'stage 0':[op.join(outf,subjid,'unprocessed','3T','T1w_MPR1',subjid+'_3T_T1w_MPR1.nii.gz'),
%                         ],
%              'stage 1': [op.join(outf,subjid,'MNINonLinear',subjid+'.164k_fs_LR.wb.spec'),],
%              'stage 2': [op.join(outf,subjid,'T1w',subjid,'dpath','merged_avg33_mni_bbr.mgz')],
%              'stage 3': glob.glob(op.join(outf,subjid,'MNINonLinear','Results') +'/BOLD*/*Atlas.dtseries.nii'),
%              'stage 4': [op.join(outf,subjid,'MNINonLinear','Results','BOLD_MSMconcat','BOLD_MSMconcat_Atlas_MSMSulc_prepared_nobias_vn.dtseries.nii')],
%              'stage 5': [op.join(outf,subjid,'ASL','ASL_nonlin_norm.nii.gz')],
%              'stage 6': glob.glob(op.join(outf,subjid,'MNINonLinear','Results')+'/BOLD*/BOLD*.feat/*level2_AVG_*.nii')}
tbl=[];
for i=1:length(subjid)
  %  disp(i)
   tbl.Subjid{i,1}=subjid{i};
   if(~isempty(tblXnat))
    tbl.Xnat(i,1)=ismember(subjid{i},tblXnat.SubjID)==1;
   else
       tbl.Xnat(i,1)=false;
   end
   
   tbl.Stage0(i,1)=~isempty(dir(fullfile(outfolder,subjid{i},'unprocessed','3T','T1w_MPR1',[subjid{i} '_3T_T1w_MPR1.nii.gz'])));
   tbl.Stage1(i,1)=~isempty(dir(fullfile(outfolder,subjid{i},'MNINonLinear',[subjid{i} '.164k_fs_LR.wb.spec']))) &...
       ~isempty(dir(fullfile(outfolder,subjid{i},'stats','aseg.stats')));
   tbl.Stage2(i,1)=~isempty(dir(fullfile(outfolder,subjid{i},'T1w',subjid{i},'dpath','merged_avg33_mni_bbr.mgz')));
   tbl.Stage3(i,1)=~isempty(rdir(fullfile(outfolder,subjid{i},'BOLD*','*nonlin.nii.gz')));
   tbl.Stage4(i,1)=~isempty(dir(fullfile(outfolder,subjid{i},'MNINonLinear','Results','BOLD_MSMconcat','BOLD_MSMconcat_Atlas_MSMSulc_prepared_nobias_vn.dtseries.nii')));
   tbl.Stage5(i,1)=~isempty(rdir(fullfile(outfolder,subjid{i},'ASL*','*_nonlin_norm.nii.gz')));
   tbl.Stage6(i,1)=~isempty(rdir(fullfile(outfolder,subjid{i},'MNINonLinear','Results','/BOLD*/BOLD*.feat/*dscalar.nii')));
   tbl.Stage7(i,1)=~isempty(rdir(fullfile(outfolder,subjid{i},'PET','gtmpvc.output','gtm.stats.dat')));
end

% % now check for data files
% d=readtable('/disk/HCP/raw/aligned-scans.txt');
% 
% for i=1:length(subjid)
%     lst=find(ismember(d.subjid,subjid{i}));
%     if(~isempty(lst))
%         [~,j]=unique(d(lst,:).date);
%         tbl.Physiol_MR1(i,1)=~isempty(d(lst(j(1)),:).info{1});
%         if(length(j)>1)
%             tbl.Physiol_MR2(i,1)=~isempty(d(lst(j(2)),:).info{1});
%         else
%             tbl.Physiol_MR2(i,1)=false;
%         end
%     else
%         tbl.Physiol_MR1(i,1)=false;
%         tbl.Physiol_MR2(i,1)=false;
%     end
%     
%     tbl.MEG(i,1)=(exist(fullfile('/disk','HCP','raw','MEG',subjid{i}))==7);
%     tbl.PET(i,1)=(exist(fullfile('/disk','HCP','analyzed',subjid{i},'unprocessed','PET'))==7);
%     tbl.EprimeMEG(i,1)=(exist(fullfile('/disk','HCP','raw','EPRIME_MEG',subjid{i}))==7);
%     tbl.EprimeMR(i,1)=(exist(fullfile('/disk','HCP','raw','EPRIME_fMRI',subjid{i}))==7);
% end


if(~isempty(tbl))
    tbl=struct2table(tbl);
end

if(nargout==0)
    disp(tbl);
end


