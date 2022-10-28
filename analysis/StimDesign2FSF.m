function StimDesign2FSF(outfolder,subjid,task,StimDesign)

feat_files=fullfile(outfolder,subjid,'MNINonLinear','Results',task,[task '.nii.gz']);
if(~exist(feat_files))
    warning(['cannot find file: ' feat_files])
    return
end   


[p,f,e]=fileparts(feat_files);
f=f(1:min(strfind(f,'.'))-1);

a = load_untouch_nii(feat_files);

TR=a.hdr.dime.pixdim(5);
npts=a.hdr.dime.dim(5);
ndelete=0;

brain_thresh=10;
critical_z=3.09;
noise=0.412671;
noisear=0.189140;

dwell= 0.47;
te=30;

signallossthresh=10;
unwarp_dir='x';
smooth=4;

prob_thresh=0.05;
z_thresh=3.29;
paradigm_hp=200;

% mkdir(fullfile(p,'LINKED_DATA'));
% mkdir(fullfile(p,'LINKED_DATA/EPRIME'));
system(['mkdir -p ' fullfile(p,'LINKED_DATA/EPRIME/EVs')]);
p=fullfile(p,'LINKED_DATA/EPRIME/EVs');

p2=fullfile(outfolder,subjid,'MNINonLinear','Results',task);

outdir=fullfile(p2,[f '_hp' num2str(paradigm_hp) '_s' num2str(smooth)]);
%feat_files='../BOLD_MOTOR1_AP.nii.gz'

if(isa(StimDesign,'Dictionary'))
    for i=1:StimDesign.count
        S(i)=StimDesign(StimDesign.keys{i});
    end
    StimDesign=S;
end

for i=1:length(StimDesign)
    x = [StimDesign(i).onset(:)'; StimDesign(i).dur(:)'; StimDesign(i).amp(:)']';
    dlmwrite(fullfile(p,[StimDesign(i).name '.txt']),x,'delimiter','\t');
    
    EVs(i).name=StimDesign(i).name;
    EVs(i).shape=3;
    EVs(i).conv=3;
    EVs(i).deriv=1;
    EVs(i).file=fullfile(p,[StimDesign(i).name '.txt']);  
end

for i=1:length(EVs)
    Contrasts(i).name=EVs(i).name;
    Contrasts(i).pic=1;
    Contrasts(i).c=zeros(2*length(EVs),1);
    Contrasts(i).c(2*(i-1)+1)=1;
    Contrasts(i).includeF=1;
end

fileOut = fullfile(p,[f '_hp200_s4_level1.fsf']);


%% 
fid=fopen(fileOut,'w');

fprintf(fid,'# FEAT version number\n');
fprintf(fid,'set fmri(version) 6.00\n\n');

fprintf(fid,'# Are we in MELODIC?\n');
fprintf(fid,'set fmri(inmelodic) 0\n\n');

fprintf(fid,'# Analysis level\n');
fprintf(fid,'# 1 : First-level analysis\n');
fprintf(fid,'# 2 : Higher-level analysis\n');
fprintf(fid,'set fmri(level) 1\n\n');

fprintf(fid,'# Which stages to run\n');
fprintf(fid,'# 0 : No first-level analysis (registration and/or group stats only)\n');
fprintf(fid,'# 7 : Full first-level analysis\n');
fprintf(fid,'# 1 : Pre-Stats\n');
fprintf(fid,'# 3 : Pre-Stats + Stats\n');
fprintf(fid,'# 2 :             Stats\n');
fprintf(fid,'# 6 :             Stats + Post-stats\n');
fprintf(fid,'# 4 :                     Post-stats\n');
fprintf(fid,'set fmri(analysis) 7\n\n');

fprintf(fid,'# Use relative filenames\n');
fprintf(fid,'set fmri(relative_yn) 0\n\n');

fprintf(fid,'# Balloon help\n');
fprintf(fid,'set fmri(help_yn) 1\n\n');

fprintf(fid,'# Run Featwatcher\n');
fprintf(fid,'set fmri(featwatcher_yn) 0\n\n');

fprintf(fid,'# Cleanup first-level standard-space images\n');
fprintf(fid,'set fmri(sscleanup_yn) 0\n\n');

fprintf(fid,'# Output directory\n');
fprintf(fid,'set fmri(outputdir) "%s"\n\n',outdir);

fprintf(fid,'# TR(s)\n');
fprintf(fid,'set fmri(tr) %f\n\n',TR);

fprintf(fid,'# Total volumes\n');
fprintf(fid,'set fmri(npts) %d\n\n',npts);

fprintf(fid,'# Delete volumes\n');
fprintf(fid,'set fmri(ndelete) %d\n\n',ndelete);

fprintf(fid,'# Perfusion tag/control order\n');
fprintf(fid,'set fmri(tagfirst) 1\n\n');

fprintf(fid,'# Number of first-level analyses\n');
fprintf(fid,'set fmri(multiple) 1\n\n');

fprintf(fid,'# Higher-level input type\n');
fprintf(fid,'# 1 : Inputs are lower-level FEAT directories\n');
fprintf(fid,'# 2 : Inputs are cope images from FEAT directories\n');
fprintf(fid,'set fmri(inputtype) 1\n\n');

fprintf(fid,'# Carry out pre-stats processing?\n');
fprintf(fid,'set fmri(filtering_yn) 1\n\n');

fprintf(fid,'# Brain/background threshold\n');
fprintf(fid,'set fmri(brain_thresh) %d\n\n',brain_thresh);

fprintf(fid,'# Critical z for design efficiency calculation\n');
fprintf(fid,'set fmri(critical_z) %d\n\n',critical_z);

fprintf(fid,'# Noise level\n');
fprintf(fid,'set fmri(noise) %f\n\n',noise);

fprintf(fid,'# Noise AR(1)\n');
fprintf(fid,'set fmri(noisear) %f\n\n',noisear);

fprintf(fid,'# Post-stats-only directory copying\n');
fprintf(fid,'# 0 : Overwrite original post-stats results\n');
fprintf(fid,'# 1 : Copy original FEAT directory for new Contrasts, Thresholding, Rendering\n');
fprintf(fid,'set fmri(newdir_yn) 0\n\n');

fprintf(fid,'# Motion correction\n');
fprintf(fid,'# 0 : None\n');
fprintf(fid,'# 1 : MCFLIRT\n');
fprintf(fid,'set fmri(mc) 0\n\n');

fprintf(fid,'# Spin-history (currently obsolete)\n');
fprintf(fid,'set fmri(sh_yn) 0\n\n');

fprintf(fid,'# B0 fieldmap unwarping?\n');
fprintf(fid,'set fmri(regunwarp_yn) 0\n\n');

fprintf(fid,'# EPI dwell time (ms)\n');
fprintf(fid,'set fmri(dwell) %f\n\n',dwell);

fprintf(fid,'# EPI TE (ms)\n');
fprintf(fid,'set fmri(te) %f\n\n',te);

fprintf(fid,'# Signal loss threshold\n');
fprintf(fid,'set fmri(signallossthresh) %d\n\n',signallossthresh);

fprintf(fid,'# Unwarp direction\n');
fprintf(fid,'set fmri(unwarp_dir) %s\n\n',unwarp_dir);

fprintf(fid,'# Slice timing correction\n');
fprintf(fid,'# 0 : None\n');
fprintf(fid,'# 1 : Regular up (0, 1, 2, 3, ...)\n');
fprintf(fid,'# 2 : Regular down\n');
fprintf(fid,'# 3 : Use slice order file\n');
fprintf(fid,'# 4 : Use slice timings file\n');
fprintf(fid,'# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )\n');
fprintf(fid,'set fmri(st) 0\n\n');

fprintf(fid,'# Slice timings file\n');
fprintf(fid,'set fmri(st_file) ""\n\n');

fprintf(fid,'# BET brain extraction\n');
fprintf(fid,'set fmri(bet_yn) 0\n\n');

fprintf(fid,'# Spatial smoothing FWHM (mm)\n');
fprintf(fid,'set fmri(smooth) %d\n\n',smooth);

fprintf(fid,'# Perfusion subtraction\n');
fprintf(fid,'set fmri(perfsub_yn) 0\n\n');

fprintf(fid,'# Highpass temporal filtering\n');
fprintf(fid,'set fmri(temphp_yn) 1\n\n');

fprintf(fid,'# Lowpass temporal filtering\n');
fprintf(fid,'set fmri(templp_yn) 0\n\n');

fprintf(fid,'# MELODIC ICA data exploration\n');
fprintf(fid,'set fmri(melodic_yn) 0\n\n');

fprintf(fid,'# Carry out main stats?\n');
fprintf(fid,'set fmri(stats_yn) 1\n\n');


fprintf(fid,'# Carry out prewhitening?\n');
fprintf(fid,'set fmri(prewhiten_yn) 1\n\n');

fprintf(fid,'# Add motion parameters to model\n');
fprintf(fid,'# 0 : No\n');
fprintf(fid,'# 1 : Yes\n');
fprintf(fid,'set fmri(motionevs) 0\n');
fprintf(fid,'set fmri(motionevsbeta) ""\n');
fprintf(fid,'set fmri(scriptevsbeta) ""\n\n');

fprintf(fid,'# Robust outlier detection in FLAME?\n');
fprintf(fid,'set fmri(robust_yn) 0\n\n');

fprintf(fid,'# Higher-level modelling\n');
fprintf(fid,'# 3 : Fixed effects\n');
fprintf(fid,'# 0 : Mixed Effects: Simple OLS\n');
fprintf(fid,'# 2 : Mixed Effects: FLAME 1\n');
fprintf(fid,'# 1 : Mixed Effects: FLAME 1+2\n');
fprintf(fid,'set fmri(mixed_yn) 2\n\n');


%% Now the contrast parts
fprintf(fid,'# Number of EVs\n');
fprintf(fid,'set fmri(evs_orig) %d\n',length(EVs));
fprintf(fid,'set fmri(evs_real) %d\n',length(EVs)+length(find(vertcat(EVs.deriv))));  
fprintf(fid,'set fmri(evs_vox) 0\n\n');

fprintf(fid,'# Number of contrasts\n');
fprintf(fid,'set fmri(ncon_orig) %d\n',length(Contrasts));
fprintf(fid,'set fmri(ncon_real) %d\n\n',length(Contrasts));

fprintf(fid,'# Number of F-tests\n');
fprintf(fid,'set fmri(nftests_orig) 1\n');
fprintf(fid,'set fmri(nftests_real) 1\n\n');

fprintf(fid,'# Add constant column to design matrix? (obsolete)\n');
fprintf(fid,'set fmri(constcol) 0\n\n');

fprintf(fid,'# Carry out post-stats steps?\n');
fprintf(fid,'set fmri(poststats_yn) 1\n\n');

fprintf(fid,'# Pre-threshold masking?\n');
fprintf(fid,'set fmri(threshmask) ""\n\n');

fprintf(fid,'# Thresholding\n');
fprintf(fid,'# 0 : None\n');
fprintf(fid,'# 1 : Uncorrected\n');
fprintf(fid,'# 2 : Voxel\n');
fprintf(fid,'# 3 : Cluster\n');
fprintf(fid,'set fmri(thresh) 0\n\n');

fprintf(fid,'# P threshold\n');
fprintf(fid,'set fmri(prob_thresh) %f\n\n',prob_thresh);

fprintf(fid,'# Z threshold\n');
fprintf(fid,'set fmri(z_thresh) %f\n\n',z_thresh);

fprintf(fid,'# Z min/max for colour rendering\n');
fprintf(fid,'# 0 : Use actual Z min/max\n');
fprintf(fid,'# 1 : Use preset Z min/max\n');
fprintf(fid,'set fmri(zdisplay) 0\n\n');

fprintf(fid,'# Z min in colour rendering\n');
fprintf(fid,'set fmri(zmin) 2\n\n');

fprintf(fid,'# Z max in colour rendering\n');
fprintf(fid,'set fmri(zmax) 8\n\n');

fprintf(fid,'# Colour rendering type\n');
fprintf(fid,'# 0 : Solid blobs\n');
fprintf(fid,'# 1 : Transparent blobs\n');
fprintf(fid,'set fmri(rendertype) 1\n\n');

fprintf(fid,'# Background image for higher-level stats overlays\n');
fprintf(fid,'# 1 : Mean highres\n');
fprintf(fid,'# 2 : First highres\n');
fprintf(fid,'# 3 : Mean functional\n');
fprintf(fid,'# 4 : First functional\n');
fprintf(fid,'# 5 : Standard space template\n');
fprintf(fid,'set fmri(bgimage) 1\n\n');

fprintf(fid,'# Create time series plots\n');
fprintf(fid,'set fmri(tsplot_yn) 0\n\n');

fprintf(fid,'# Registration?\n');
fprintf(fid,'set fmri(reg_yn) 1\n\n');

fprintf(fid,'# Registration to initial structural\n');
fprintf(fid,'set fmri(reginitial_highres_yn) 0\n\n');

fprintf(fid,'# Search space for registration to initial structural\n');
fprintf(fid,'# 0   : No search\n');
fprintf(fid,'# 90  : Normal search\n');
fprintf(fid,'# 180 : Full search\n');
fprintf(fid,'set fmri(reginitial_highres_search) 90\n\n');

fprintf(fid,'# Degrees of Freedom for registration to initial structural\n');
fprintf(fid,'set fmri(reginitial_highres_dof) 3\n\n');

fprintf(fid,'# Registration to main structural\n');
fprintf(fid,'set fmri(reghighres_yn) 0\n\n');

fprintf(fid,'# Search space for registration to main structural\n');
fprintf(fid,'# 0   : No search\n');
fprintf(fid,'# 90  : Normal search\n');
fprintf(fid,'# 180 : Full search\n');
fprintf(fid,'set fmri(reghighres_search) 90\n\n');

fprintf(fid,'# Degrees of Freedom for registration to main structural\n');
fprintf(fid,'set fmri(reghighres_dof) 6\n\n');

fprintf(fid,'# Registration to standard image?\n');
fprintf(fid,'set fmri(regstandard_yn) 0\n\n');

fprintf(fid,'# Use alternate reference images?\n');
fprintf(fid,'set fmri(alternateReference_yn) 0\n\n');

fprintf(fid,'# Standard image\n');
fprintf(fid,'set fmri(regstandard) "/home/pkg/software/fsl/fsl/data/standard/MNI152_T1_2mm_brain"\n\n');

fprintf(fid,'# Search space for registration to standard space\n');
fprintf(fid,'# 0   : No search\n');
fprintf(fid,'# 90  : Normal search\n');
fprintf(fid,'# 180 : Full search\n');
fprintf(fid,'set fmri(regstandard_search) 90\n\n');

fprintf(fid,'# Degrees of Freedom for registration to standard space\n');
fprintf(fid,'set fmri(regstandard_dof) 12\n\n');

fprintf(fid,'# Do nonlinear registration from structural to standard space?\n');
fprintf(fid,'set fmri(regstandard_nonlinear_yn) 1\n\n');

fprintf(fid,'# Control nonlinear warp field resolution\n');
fprintf(fid,'set fmri(regstandard_nonlinear_warpres) 10 \n\n');

fprintf(fid,'# High pass filter cutoff\n');
fprintf(fid,'set fmri(paradigm_hp) %d\n\n',paradigm_hp);

fprintf(fid,'# Number of lower-level copes feeding into higher-level analysis\n');
fprintf(fid,'set fmri(ncopeinputs) 0\n\n');

fprintf(fid,'# 4D AVW data or FEAT directory (1)\n');
fprintf(fid,'set feat_files(1) "%s"\n\n',feat_files);

fprintf(fid,'# Add confound EVs text file\n');
fprintf(fid,'set fmri(confoundevs) 0\n\n');


for i=1:length(EVs)
    fprintf(fid,'# EV %d title\n',i);
    fprintf(fid,'set fmri(evtitle%d) "%s"\n',i,EVs(i).name);
    
    fprintf(fid,'# Basic waveform shape (EV %d)\n',i);
    fprintf(fid,'# 0 : Square\n');
    fprintf(fid,'# 1 : Sinusoid\n');
    fprintf(fid,'# 2 : Custom (1 entry per volume)\n');
    fprintf(fid,'# 3 : Custom (3 column format)\n');
    fprintf(fid,'# 4 : Interaction\n');
    fprintf(fid,'# 10 : Empty (all zeros)\n');
    fprintf(fid,'set fmri(shape%d) %d\n\n',i,EVs(i).shape);
    
    fprintf(fid,'# Convolution (EV %d)\n',i);
    fprintf(fid,'# 0 : None\n');
    fprintf(fid,'# 1 : Gaussian\n');
    fprintf(fid,'# 2 : Gamma\n');
    fprintf(fid,'# 3 : Double-Gamma HRF\n');
    fprintf(fid,'# 4 : Gamma basis functions\n');
    fprintf(fid,'# 5 : Sine basis functions\n');
    fprintf(fid,'# 6 : FIR basis functions\n');
    fprintf(fid,'set fmri(convolve%d) %d\n\n',i,EVs(i).conv);
    
    fprintf(fid,'# Convolve phase (EV %d)\n',i);
    fprintf(fid,'set fmri(convolve_phase%d) 0\n\n',i);
    
    fprintf(fid,'# Apply temporal filtering (EV %d)\n',i);
    fprintf(fid,'set fmri(tempfilt_yn%d) 1\n\n',i);
    
    fprintf(fid,'# Add temporal derivative (EV %d)\n',i);
    fprintf(fid,'set fmri(deriv_yn%d) 1\n\n',i,EVs(i).deriv);
    
    fprintf(fid,'# Custom EV file (EV %d)\n',i);
    fprintf(fid,'set fmri(custom%d) "%s"\n\n',i,EVs(i).file);
    
    for j=0:length(EVs)
        fprintf(fid,'# Orthogonalise EV %d wrt EV %d\n',i,j);
        fprintf(fid,'set fmri(ortho%d.%d) 0\n',i,j);
    end
    fprintf(fid,'#######################################\n');
end



for i=1:length(Contrasts)
     fprintf(fid,'# Display images for contrast_real %d\n',i);
     fprintf(fid,'set fmri(conpic_real.%d) %d\n\n',i,Contrasts(i).pic);
     
     fprintf(fid,'# Title for contrast_real %d\n',i);
     fprintf(fid,'set fmri(conname_real.%d) "%s"\n\n',i,Contrasts(i).name);
     for j=1:length(Contrasts(i).c)
         fprintf(fid,'# Real contrast_real vector %d element %d\n',i,j);
         fprintf(fid,'set fmri(con_real%d.%d) %d\n\n',i,j,Contrasts(i).c(j));
        
     end
      fprintf(fid,'set fmri(ftest_real%d.%d) %d\n\n',i,i,Contrasts(i).includeF);
     fprintf(fid,'#######################################\n');
end

fprintf(fid,'# Contrast masking - use >0 instead of thresholding?\n');
fprintf(fid,'set fmri(conmask_zerothresh_yn) 0\n\n');

for i=1:length(Contrasts)
    for j=1:length(Contrasts)
        if(i~=j)
            fprintf(fid,'# Mask real contrast/F-test %d with real contrast/F-test %d?\n',i,j);
            fprintf(fid,'set fmri(conmask%d_%d) 0\n\n',i,j);
            
        end
    end
end

fprintf(fid,'# Do contrast masking at all?\n');
fprintf(fid,'set fmri(conmask1_1) 0\n\n');

fprintf(fid,'#######################################\n');
fprintf(fid,'# Now options that dont appear in the GUI\n\n');
 

fprintf(fid,'# Alternative (to BETting) mask image\n');
fprintf(fid,'set fmri(alternative_mask) ""\n\n');

fprintf(fid,'# Initial structural space registration initialisation transform\n');
fprintf(fid,'set fmri(init_initial_highres) ""\n\n');

fprintf(fid,'# Structural space registration initialisation transform\n');
fprintf(fid,'set fmri(init_highres) ""\n\n');

fprintf(fid,'# Standard space registration initialisation transform\n');
fprintf(fid,'set fmri(init_standard) ""\n\n');

fprintf(fid,'# For full FEAT analysis: overwrite existing .feat output dir?\n');
fprintf(fid,'set fmri(overwrite_yn) 1\n\n');

fclose(fid);

system(['mkdir -p ' outfolder filesep subjid '/unprocessed/3T/' task '/LINKED_DATA/EPRIME/EVs']);
system(['cp -vR ' outfolder filesep subjid '/MNINonLinear/Results/' task '/LINKED_DATA/EPRIME/EVs/* ' outfolder filesep subjid '/unprocessed/3T/' task '/LINKED_DATA/EPRIME/EVs' ]);

