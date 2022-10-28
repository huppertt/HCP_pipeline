function HCP_WMH_GPNnew(subjid,outfolder,force)

if(nargin<2)
    outfolder='/disk/HCP/analyzed';
end
if(nargin<3)
    force=false;
end
tic;
HCP_matlab_setenv;

FLAIR=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc.nii.gz']);

if(~exist(FLAIR))
    disp([subjid ' missing T2FLAIR. Skipping.'])
    return
end

HiRES=fullfile(outfolder,subjid,'T1w','T1w_acpc.nii.gz');
WMH=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_WMH_kmeans_acpc.nii.gz']);
WMH2=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_WMH_fuzzy_acpc.nii.gz']);
Znorm=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc_N4_Znorm.nii.gz']);

if(exist(WMH2)==2 && ~force)
    disp(['skipping ' subjid]);
    return
end

setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'fsfast' filesep 'bin']);
setenv('PATH',[getenv('PATH') ':' getenv('FREESURFER_HOME') filesep 'mni' filesep 'bin']);

FLAIRN4=HCP_N4filter(FLAIR,force);

system(['mri_convert -i ' outfolder '/' subjid '/T1w/' subjid '/mri/wmparc.mgz '...
    '-rl ' FLAIRN4 ' -rt nearest -o ' outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz']);


system(['mri_convert -i ' outfolder '/' subjid '/T1w/' subjid '/mri/aseg.mgz '...
    '-rl ' FLAIRN4 ' -rt nearest -o ' outfolder filesep subjid '/T2FLAIR/aseg_acpc.nii.gz']);


fileOut={};

T2flair=load_nii(FLAIRN4);
wmparc=load_nii([outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz']);




% 7   Left-Cerebellum-White-Matter            220 248 164 0
% 46  Right-Cerebellum-White-Matter           220 248 164 0
lstCERWM=find(ismember(wmparc.img,[7 46]));

% 
% 3   Left-Cerebral-Cortex                    205 62  78  0
% 4   Left-Lateral-Ventricle                  120 18  134 0
% 5   Left-Inf-Lat-Vent                       196 58  250 0
% 14  3rd-Ventricle                           204 182 142 0
% 15  4th-Ventricle                           42  204 164 0
% 24  CSF                                     60  60  60  0
% 25  Left-Lesion                             255 165 0   0
% 30  Left-vessel                             160 32  240 0
% 42  Right-Cerebral-Cortex                   205 62  78  0
% 43  Right-Lateral-Ventricle                 120 18  134 0
% 44  Right-Inf-Lat-Vent                      196 58  250 0
% 57  Right-Lesion                            255 165 0   0
% 62  Right-vessel                            160 32  240 0
% 72  5th-Ventricle                           120 190 150 0
% 1000's - left cortex
% 2000's - right cortex

lstWM = find(~ismember(wmparc.img,[0 3 4 5 6 7 8 14 15 24 25 30 42 43 44 45 46 47 57 62 72 1000:2999]));
mask=wmparc;
mask.img(:)=0;
mask.img(lstWM)=1;
% mask.img(lstCERWM)=2;


% calculate mean and standard deviation
M = nanmean(T2flair.img(lstCERWM));
S = nanstd(T2flair.img(lstCERWM));

% normalize intensities
Z = T2flair;
Z.img = ((double(T2flair.img) - M) ./ S).*(mask.img>0);

save_nii(Z,Znorm);

thr=1:.5:4;
for tI=1:length(thr)
    fileOut{end+1}=fullfile(outfolder,subjid,'T2FLAIR',[subjid '_3T_T2FLAIR_acpc_N4_std' num2str(thr(tI)) '_Znorm_th.nii.gz']);
    disp(['saving ' fileOut{end}]);
    system(['fslmaths ' Znorm ' -thr ' num2str(thr(tI)) ' -bin ' fileOut{end}]);
end


disp('Running K-means WMH estimate');
nclust=2;
[IDX,centroids]=imsegkmeans3(int16(Z.img.*(Z.img>1)),3);

mask2=zeros(size(Z.img));
[~,idx]=max(centroids);
mask2(find(IDX==idx))=1;

CC = bwconncomp(mask2>0);
for idx = 1:length(CC.PixelIdxList)
    if length(CC.PixelIdxList{idx}) < 2
        mask2(CC.PixelIdxList{idx}) = 0;
    end
end

WM=T2flair;
WM.img=Z.img.*mask2;
disp(['saving WMH file: ' WMH]);
save_nii(WM,WMH);
fileOut{end+1}=WMH;


disp('Running FCM WMH estimate');
[a,b,c]=size(Z.img);
lst=find(Z.img>1);

[U,center]=stepfcm(Z.img(lst),[tcdf(Z.img(lst),1) 1-tcdf(Z.img(lst),1)]', 2,2);
for iter=1:30
    [Unew,centernew]=stepfcm(Z.img(lst),U, 2,1.1);
    if(any(isnan(centernew)))
        break;
    end
    U=Unew; center=centernew;
end

[~,id]=sort(center);
for j=1:length(center)
    m=zeros(a,b,c);
    m(lst)=U(id(j),:);
    C(:,:,:,j)=m;
end
WM.img=C(:,:,:,2);
disp(['saving WMH file: ' WMH2]);
save_nii(WM,WMH2);
fileOut{end+1}=WMH2;





for i=1:length(fileOut)
    maskOut=strrep(fileOut{i},'.nii.gz','_mask.nii.gz');
    system(['fslmaths ' fileOut{i} ' -thr .5 -bin ' maskOut ]);
    
    statsOut=strrep(fileOut{i},'.nii.gz','_stats.dat');
    disp(['Running stats: ' statsOut]);
    system(['mri_segstats --i ' fileOut{i} ...
        ' --mask ' maskOut ...
        ' --seg ' outfolder filesep subjid '/T2FLAIR/wmparc_acpc.nii.gz --excludeid 0'...
        ' --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --sum ' statsOut]);
end

disp(['DONE: time elapsed ' num2str(toc) 's']);