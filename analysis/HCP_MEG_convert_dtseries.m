function HCP_MEG_preprocessing(subjid,outfolder,J)
% This function copys the MEG data from raw/subjid into the analyzed folder

HCProot='/disk/HCP/';
if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    J=5;
end

HCP_matlab_setenv;
setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'T1w'))
setenv('SUBJECT',subjid);

HCP_makeMNIsourcespace(subjid,J,outfolder);

files=rdir(fullfile(outfolder,subjid,'MEG*/stc/*_preproc-lh.stc'));
for i=1:length(files)
    fileOut=files(i).name;
%     fileOut = [fileIn(1:strfind(fileIn,'.fif')-5) '*prep*.fif'];
%     fileOut=rdir(fileOut);
%     fileOut=fileOut.name;
%     HCP_FIFF2HPI(subjid,outfolder,fileIn);
% %     system(['python3.5 ' fullfile(HCProot,'pipeline','analysis','HCP_megpipe.py')...
% %         ' prep ' fileIn ' ' fileOut]);
% 
%     subj_dir=fullfile(outfolder,subjid,'T1w');
%     subj=subjid;
%     trans=[fileIn(1:strfind(fileIn,'.fif')-1) '-trans.fif'];
%     src=fullfile(outfolder,subjid,'MNINonLinear',...
%         ['waveletJ' num2str(J)],[subjid '-ico' num2str(J) '-src.fif']);
%     fwd='''None''';
%     inv='''None''';
%     pp=fileparts(fileIn);
%     empty=dir(fullfile(pp,'*empty*.fif'));
%     if(isempty(empty))
%         empty='''None''';
%     else
%         empty=fullfile(pp,empty(1).name);
%     end
%     system(['python3.5 ' fullfile(HCProot,'pipeline','analysis','HCP_megpipe.py')...
%          ' source ' fileOut ' ' subj_dir ' ' trans ' ' subj ' ' ...
%          src ' ' fwd ' ' inv ' ' empty]);
%      
     fOut=fileOut(1:end-7);
     
     template = fullfile(outfolder,subjid,'MNINonLinear',['waveletJ' num2str(J)],[subjid '.LR.pial_MSMSulc.dscalar.nii']);
     c=ft_read_cifti(template);
     c.dimord='pos_time';
     
     c=rmfield(c,'x_coordinate');
     c=rmfield(c,'y_coordinate');
     c=rmfield(c,'z_coordinate');
     
     l=mne_read_stc_file(fullfile([fOut '-lh.stc']));
     r=mne_read_stc_file(fullfile([fOut '-rh.stc']));
     c.time = l.tmin+[0:size(l.data,2)-1]*l.tstep;
     c.dtseries=[l.data; r.data];
     fileo=[fOut 'J' num2str(J) '.dscalar.nii'];
     ft_write_cifti(fileo,c,'parameter','dtseries','writesurface',true);
     disp(['Write MEG data to : ' fileo]);
end
