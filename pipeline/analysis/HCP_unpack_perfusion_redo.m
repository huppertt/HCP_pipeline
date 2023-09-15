function HCP_unpack_perfusion_redo(subjid,dcmfolder,outfolder)
% setenv('FREESURFER_HOME','/disk/HCP/pipeline/external/freesurfer-beta');
% system(['source ' getenv('FREESURFER_HOME') filesep 'SetUpFreeSurfer.sh']);
% setenv('PATH',[getenv('FREESURFER_HOME') filesep 'bin:' getenv('PATH')]);
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
% setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);


if(nargin<3)
    outfolder='/disk/HCP/analyzed';
end

f=dir(fullfile(dcmfolder,'Perfusion*'));
for i=1:length(f)
    system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo')]);
    
    fout=fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo',[subjid '_3T_Perfusion.nii.gz']);
    m=rdir(fullfile(dcmfolder,f(i).name,'MR*'));
    setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo'))
    system(['mri_convert --no-rescale-dicom ' m(1).name ' ' fout]);
end

f=dir(fullfile(dcmfolder,'Perfusion*'));
for i=1:length(f)
    system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo')]);
    
    fout=fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo',[subjid '_3T_Perfusion.nii.gz']);
    m=rdir(fullfile(dcmfolder,f(i).name,'MR*'));
    setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo'))
    system(['mri_convert --no-rescale-dicom ' m(1).name ' ' fout]);
end

f=dir(fullfile(dcmfolder,'relCBF*'));
for i=1:length(f)
    system(['mkdir -p ' fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo')]);
    
    fout=fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo',[subjid '_3T_relCBF.nii.gz']);
    m=rdir(fullfile(dcmfolder,f(i).name,'MR*'));
    setenv('SUBJECTS_DIR',fullfile(outfolder,subjid,'unprocessed','3T',...
        'Perfusion_Redo'))
    system(['mri_convert --no-rescale-dicom ' m(1).name ' ' fout]);
end