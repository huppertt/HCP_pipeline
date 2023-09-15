function HCP_split_ME_BOLD(filename,TEs)
% TEs=[13.2 38.7 64.2]

a=load_untouch_nii(filename);

rootname=filename(1:min(strfind(filename,'.'))-1);
i=1;
s=num2str(TEs(i)) ;
s(strfind(s,'.'))='p';
name=[rootname '_TE' s '.nii.gz'];

system(['mv ' filename ' ' rootname '_ME.nii.gz']);

if(~exist(name))
    f={};
    for i=1:length(TEs)
        s=num2str(TEs(i)) ;
        s(strfind(s,'.'))='p';
        name=[rootname '_TE' s '.nii.gz'];
        
        b=a;
        b.hdr.dime.dim(5)=b.hdr.dime.dim(5)/length(TEs);
        b.img=b.img(:,:,:,i:length(TEs):end);
        disp(['saving : ' name]);
        save_untouch_nii(b,name);
        f{i}=name;
    end
    
%     s=num2str(TEs(1)) ;
%     s(strfind(s,'.'))='p';
%     name=[rootname '_TE' s '.nii.gz'];
%     system(['cp -v ' name ' ' filename]);
%     
    HCP_ME_combine(f,TEs,[],filename);
    
end