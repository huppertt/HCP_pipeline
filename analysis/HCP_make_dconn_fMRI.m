function HCP_make_dconn_fMRI(subjid,outfolder,fileIn)

HCProot='/disk/HCP/';

if(nargin<2 || isempty(outfolder))
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<3)
    fileIn=rdir(fullfile(outfolder,subjid,'MNI*','wavelet*','Results','BOLD_REST*.dtseries.nii'));
end


if(~isstruct(fileIn))
    fileIn.name=fileIn;
end

for i=1:length(fileIn)
    fileOut = [fileIn(i).name(1:strfind(fileIn(i).name,'.dtseries')-1) '.dconn.mat'];
    disp(fileIn(i).name); tic;
    if(~exist(fileOut))
        data=ft_read_cifti(fileIn(i).name);
        
        Fs=1/mean(diff(data.time));
        modelorder = fix(30*Fs);
        robust_flag=true;
        
        [R,p,dfe]=nirs.sFC.ar_corr(data.dtseries',modelorder,true);
        
        Dconn.R =R;
        Dconn.pval=p;
        Dconn.dfe=dfe;
        
        
        
        save(fileOut,'Dconn','-MAT','-v7.3');
        disp(['time elapsed: ' num2str(toc)]);
    end
end
