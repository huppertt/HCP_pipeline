function HCP_TRUST_fitting(subjid,outfolder)

% NOTE: This is currently hardcoded assuming the TRUST protocol in Caterina
% Rosano's ROS-MOVE study. Using as-is with other TRUST data will likely break it! 

HCProot='/disk/HCP';

HCP_matlab_setenv;  % Sets the FSL, Freesurfer, etc folders

if exist( fullfile(outfolder,subjid,'unprocessed','3T','TRUST' ) , 'dir' ) % Check if TRUST data is available in unprocessed folder
    
    % Make TRUST dir in main subject dir
    system([ 'mkdir -p -m 777 ' fullfile(outfolder,subjid,'TRUST')]);
    
    % Copy unprocessed TRUST data into new dir
    file = dir(fullfile(outfolder,subjid,'unprocessed','3T','TRUST' ));
    for i = 3:length(file)
        copyfile( fullfile(outfolder,subjid,'unprocessed','3T','TRUST', file(i).name ) ,...
            fullfile(outfolder,subjid,'TRUST', file(i).name ) );
    end
    
    % Load data from TRUST nifti
    nii = load_nifti( fullfile(outfolder,subjid,'TRUST', [subjid , '_3T_TRUST.nii.gz'] ) ) ;
    
    % Compute signal difference (Control - Label)
    Diff = [];
%     SNR = [];
    for i = 1:2:23
        Diff = cat(3 , Diff , (nii.vol(:,:,i+1)-nii.vol(:,:,i)) );
%         SNR = cat(3 , SNR , max( (nii.vol(:,:,i+1)-nii.vol(:,:,i))./nii.vol(:,:,i+1) ,0) );
    end
    % Find sagittal sinus voxel (where Diff is highest) in eTE=0 contrast
    % (This seems to work; is there a more robust way to do this?)
    [~,idx_x] = max(max( Diff(:,:,1) ,[], 2));
    [~,idx_y] = max(max( Diff(:,:,1) ,[], 1));
    

    % Compute mean signal in ROI of +/- 1 voxel around sag sinus voxel
    Signal =[];
    for i = 1:12
        Signal(i) = mean( reshape( Diff(idx_x-1:idx_x+1 , idx_y-1:idx_y+1 ,i) , [] , 1) );
%         Signal(i) = mean( reshape( SNR(:,:,i).*Diff(:,: ,i)./sum(sum(SNR(:,:,i))) , [] , 1) );

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
    [fitresult] = fit( xData, yData, ft, opts );
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
    
    save(fullfile(outfolder,subjid,'TRUST', [subjid '_TRUST_fit.mat']), 'Y_v', 'T2','idx_x','idx_y');
    
    
    figure
    subplot(1,3,1)
    imagesc(nii.vol(:,:,1))
    axis square
    subplot(1,3,2)
    imagesc(Diff(:,:,1))
    axis square
    subplot(1,3,3)
    imagesc(Diff(:,:,1) == Diff(idx_x,idx_y,1))
    axis square
    MyBox = uicontrol('style','text');
    set(MyBox,'String',[subjid ':' num2str(Y_v)]);
    
    
    % TODO: Appropriate statistics?  Save Y_v, T2, other variables of interest in
    % preferred format.
    
else
    disp('No TRUST data in unprocessed folder')
end