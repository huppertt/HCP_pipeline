function TRUST_fitting(subjid,outfolder)

% NOTE: This is currently hardcoded assuming the TRUST protocol in Caterina
% Rosano's ROS-MOVE study. Using as-is with other TRUST data will likely break it!

HCProot='/disk/HCP';

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

if ~exist( fullfile(outfolder,subjid,'TRUST',[subjid '_3T_TRUST.nii.gz'] ) ) | ~exist( fullfile(outfolder,subjid,'TRUST','PCA_atlas_slice_dilated.nii.gz' ) )% Check if TRUST and PCA data are available in unprocessed folder
    disp([subjid ' is missing TRUST data or PCA atlas. Make sure data is present and TRUST_analysis.m has been run.'])
    return
end

disp(['Processing TRUST data from subject ' subjid '.'])



% Load data from TRUST and PCA niftis
nii = load_nifti( fullfile(outfolder,subjid,'TRUST', [subjid , '_3T_TRUST.nii.gz'] ) ) ;
niipca = load_nifti( fullfile(outfolder,subjid,'TRUST', 'PCA_atlas_slice_dilated.nii.gz' ) ) ;

% Compute TRUST signal difference (Control - Label)
Diff = [];
for i = 1:2:23
    Diff = cat(3 , Diff , (nii.vol(:,:,i+1)-nii.vol(:,:,i)) );
end

% Locate index of highest magnitude TRUST difference
Diff1 = ([Diff(:,:,1)./max(reshape(Diff(:,:,1),[],1 ) )]);
[xMax,yMax] = find(Diff1 == max(Diff1(:)));
atlasVal = niipca.vol(xMax,yMax);

% Binarize PCA atlas as mask
DiffPCA = double(niipca.vol>0);

% Uncomment to mask to hide all regions outside of PCA atlas
% Signal_mask = DiffPCA;

% Alternatively, uncomment to hide all except brightest TRUST voxel +
% 8 nearest neighbors
Signal_mask = zeros(size(Diff(:,:,1)));
Signal_mask(xMax-1:xMax+1 , yMax-1:yMax+1) = 1;

% Compute total signal in ROI defined by mask
Signal =[];
for i = 1:12
    Signal(i) = sum( reshape(Signal_mask.*Diff(:,:,i),[],1 ) ); % Sum signal within mask
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

save(fullfile(outfolder,subjid,'TRUST', [subjid '_TRUST_fit_atlas.mat']), 'Y_v', 'T2','Signal_mask','R2','atlasVal');


disp([ 'Subject ' subjid ' Yv: ' num2str(Y_v) ', T2: ' num2str(T2) ', exponential R^2: ' num2str(R2) ', Atlas: ' num2str(atlasVal)])
if R2 < 0.98
    disp(['WARNING exponential R^2 < 0.98; R^2: ' num2str(R2)])
end


%     figure
%     subplot(1,5,1)
%     imagesc(nii.vol(:,:,1));title('TRUST Control')
%     axis square
%     subplot(1,5,2)
%     imagesc(Diff(:,:,1)); title('TRUST Difference eTE=0ms')
%     axis square
%     subplot(1,5,3)
%     imagesc(DiffPCA(:,:,1));title('PCA')
%     axis square
%     subplot(1,5,4)
%     imagesc(Signal_mask);title('Signal Mask')
%     axis square
%     MyBox = uicontrol('style','text');
%     set(MyBox,'aString',[subjid ':' num2str(Y_v)]);
%     subplot(1,5,5)
%     plot(fitresult,eTE_s,S_mean);title('Exp Fit')
%     axis square

% TODO: Appropriate statistics?  Save Y_v, T2, other variables of interest in
% preferred format.

