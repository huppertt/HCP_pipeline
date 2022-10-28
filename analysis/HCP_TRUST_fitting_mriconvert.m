function HCP_TRUST_fitting(subjid,outfolder,force)

% NOTE: This is currently hardcoded assuming the TRUST protocol in Caterina
% Rosano's ROS-MOVE study. Using as-is with other TRUST data will likely break it!

if nargin < 3
    force = 0;
end

if force == 0 & exist(fullfile(outfolder,subjid,'TRUST', [subjid '_TRUST_fit_mriconvert.mat']),'file')
    disp([subjid ' TRUST output exists. Skipping.'])
    return
end
    
HCProot='/disk/HCP';

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

% Try old fsl
setenv('FSLDIR','/disk/HCP/pipeline/external/fsl/');
setenv('PATH',[getenv('PATH') ':/disk/HCP/pipeline/external/fsl/bin/'])
setenv('PATH',[getenv('PATH') ':/disk/HCP/pipeline/external/fsl/'])

fsldir = getenv('FSLDIR');



if exist( fullfile(outfolder,subjid,'unprocessed','3T','TRUST' ) , 'dir' ) & exist( fullfile(outfolder,subjid,'unprocessed','3T','PCA' ) , 'dir' )% Check if TRUST and PCA data are available in unprocessed folder
    
    disp(['Processing TRUST data from subject ' subjid '.'])
    
    % Make TRUST dir in main subject dir
    system([ 'mkdir -p -m 777 ' fullfile(outfolder,subjid,'TRUST')]);
    
    % Copy unprocessed TRUST data into new dir
    file = dir(fullfile(outfolder,subjid,'unprocessed','3T','TRUST' ));
    for i = 3:length(file)
        copyfile( fullfile(outfolder,subjid,'unprocessed','3T','TRUST', file(i).name ) ,...
            fullfile(outfolder,subjid,'TRUST', file(i).name ) );
    end
    
    % Copy phase contrast angio image into new dir
    copyfile( fullfile(outfolder,subjid,'unprocessed','3T','PCA', [subjid  '_3T_flow_pc3d_sag_venc10_sinus_MSUM.nii.gz'] ) ,...
        fullfile(outfolder,subjid,'TRUST', [subjid '_3T_PCA_MSUM.nii.gz'] ) );
    
    % Resample PCA into TRUST space
    system(['mri_convert '...
        ' --like ' fullfile(outfolder,subjid,'TRUST',[subjid '_3T_TRUST.nii.gz'])...
        '   ' fullfile(outfolder,subjid,'TRUST',[subjid '_3T_PCA_MSUM.nii.gz'])...
        '   ' fullfile(outfolder,subjid,'TRUST',[subjid '_3T_PCA_MSUM_slice.nii.gz'])  ...
        ]);
    
    
    % Load data from TRUST and PCA niftis
    nii = load_nifti( fullfile(outfolder,subjid,'TRUST', [subjid , '_3T_TRUST.nii.gz'] ) ) ;
    niipca = load_nifti( fullfile(outfolder,subjid,'TRUST', [subjid , '_3T_PCA_MSUM_slice.nii.gz'] ) ) ;
    
    % Compute TRUST signal difference (Control - Label)
    Diff = [];
    for i = 1:2:23
        Diff = cat(3 , Diff , (nii.vol(:,:,i+1)-nii.vol(:,:,i)) );
    end
    
    % Compute PCA signal difference (locate veins)
%     DiffPCA = (niipca.vol(:,:,:,4)-nifipca.vol(:,:,:,3));
    DiffPCA = niipca.vol;
    
    % Mask to hide all regions with low intensity in (quite selective - voxels must by >9SD for inclusion)
    %     Signal_mask = Diff(:,:,1) > 9*std( reshape(Diff(:,:,1),[],1) );
    Signal_mask = [Diff(:,:,1)./max(reshape(Diff(:,:,1),[],1 ) )] .* [DiffPCA./max(DiffPCA(:))];
    Signal_mask = Signal_mask > 4*std(Signal_mask(:));
    Signal_mask = bwareaopen(Signal_mask,2);
    % Compute total signal in ROI defined by mask
    Signal =[];
    for i = 1:12
        Signal(i) = sum( reshape(Signal_mask.*Diff(:,:,i),[],1 ) );%  ./sum(Signal_mask(:));
    end
    Signal = reshape(Signal, 4,3)'; % Rows are replicates, columns are eTEs
    
    % Fit exponential curve to mean difference signal
    % (Alternatively, fit individually to each replicate?)
    eTE_s = [0 40 80 160]/1000; % Echo times in seconds
    S_mean = mean(Signal); % Average across 3 replicates
    [xData, yData] = prepareCurveData( eTE_s, S_mean );
    ft = fittype( 'exp1' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [S_mean(1) -10];
    [fitresult, gof] = fit( xData, yData, ft, opts );
    T2inv = -fitresult.b;
    
    % Use parameters from Lu et al. [Magn Reson Med 2012 Jan: 67(1): 42-49]
    % to find Y_v;  Table 1 coefficients using tau_cpmg = 10 ms (all units s^-1)
    a1 = -13.5;	a2 = 80.2;  a3 = -75.9;
    b1 = -0.5 ; b2 = 3.4;
    c1 = 247.4;
    Hct = 0.4;
    A = a1 + a2*Hct + a3*Hct^2;
    B = b1*Hct + b2*Hct^2;
    C = c1*Hct*(1-Hct);
    Y_v = 1-(-B + sqrt(B^2 - 4*C*(A-T2inv))) / (2*C);
    T2 = 1000/T2inv; % in ms
    R2 = gof.rsquare;
    
    save(fullfile(outfolder,subjid,'TRUST', [subjid '_TRUST_fit_mriconvert.mat']), 'Y_v', 'T2','Signal_mask','R2');
    
    
    disp([ 'Subject ' subjid ' Yv: ' num2str(Y_v) ', T2: ' num2str(T2) ', exponential R^2: ' num2str(R2) ])
    if R2 < 0.99
        disp(['WARNING exponential R^2 < 0.99; R^2: ' num2str(R2)])
    end
    
%     
%         figure
%         subplot(1,5,1)
%         imagesc(nii.vol(:,:,1));title('TRUST Control')
%         axis square
%         subplot(1,5,2)
%         imagesc(Diff(:,:,1)); title('TRUST Difference eTE=0ms')
%         axis square
%         subplot(1,5,3)
%         imagesc(DiffPCA(:,:,1));title('PCA')
%         axis square
%         subplot(1,5,4)
%         imagesc(Signal_mask);title('Signal Mask')
%         axis square
% %         MyBox = uicontrol('style','text');
% %         set(MyBox,'aString',[subjid ':' num2str(Y_v)]);
%         subplot(1,5,5)
%         plot(fitresult,eTE_s,S_mean);title('Exp Fit')
%         axis square
    
    % TODO: Appropriate statistics?  Save Y_v, T2, other variables of interest in
    % preferred format.
    
else
    disp('Missing TRUST or PCA data in unprocessed folder')
end