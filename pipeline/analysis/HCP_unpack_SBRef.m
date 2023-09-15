function HCP_unpack_SBRef(subjid,dcmfolder)

f=dir(fullfile(dcmfolder,'*SB*'));

for i=1:length(f)
    n=f(i).name(1:strfind(f(i).name,'_SB')-1);
    if(~isempty(strfind(n,'dMRI')))
        n2='Diffusion';
    else
        n2=n;
    end
    fout=fullfile('/disk/HCP/analyzed',subjid,'unprocessed','3T',...
        n2,[subjid '_3T_' n '_SBRef.nii.gz']);
    m=rdir(fullfile(dcmfolder,f(i).name,'MR*'));
    if(exist(fout)~=2)
        system(['mri_convert ' m(1).name ' ' fout]);
    end
end