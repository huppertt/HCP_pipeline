function HCP_unpack_SBRef(subjid,dcmfolder,outfolder)

if(nargin<3)
    outfolder='/disk/HCP/analyzed';
end

f=dir(fullfile(dcmfolder,'*SB*'));

for i=1:length(f)
    n=f(i).name(1:strfind(f(i).name,'_SB')-1);
    if(~isempty(strfind(n,'dMRI')))
        n2='Diffusion';
    else
        n2=n;
    end
    n=upper(n); n2=upper(n2);
    fout=fullfile(outfolder,subjid,'unprocessed','3T',...
        n2,[subjid '_3T_' n '_SBRef.nii.gz']);
    m=rdir(fullfile(dcmfolder,f(i).name,'MR*'));
    if(exist(fout)~=2)
        system(['mri_convert ' m(1).name ' ' fout]);
    end
end