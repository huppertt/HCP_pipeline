function [] = GPN_SeedSelector_singlesub(image_subj,roi_subj,tissue_subj,mask_subj,thr)
%% -------- DESCRIPTION --------
% [[THIS VERSION MODIFIED BY MINJIE & BECKY FOR USE WITH WMHv3 PIPELINE: orig received 1/23/2019, last modified 2/18/2020]]
% Performs relative regional intensity normalization and seed selection.
% Due to lesions,it is difficult to normalize images similarly. However,
% some regions (in certain types of lesions) are relatively low in lesions.
% This region can thus be used to normalize the entire image and then
% choose seeds based off a relatively consistent threshold (default 4).

%% -------- INPUTS --------
% study_dir = study directory [string, full path]
% subjID & scanID = [strings]
% image = image to normalize [string, partial path]
% roi = region of interest to normalize data [string, partial path]
% tissue = tissue class probability map (only uses this area within the roi to normalize by, e.g. White matter) [string, partial path]
% mask = mask of areas to normalize [string, partial path]
% thr = threshold to use to extract seeds

%% -------- OUTPUTS --------
% A intensity normalized image and a mask are output.

%% -------- EXAMPLE --------
% study_dir = '/Volumes/Minjie/MSBrain/data/';
% subjID = '900001';
% scanID = '800001';
% proc_dir = '/step03_WMHv3/';
% image = [proc_dir '*FLAIR.nii'];
% roi = [proc_dir 'rrwmask_ICV_cerebellum.nii'];    %OR rCerebellarWM_mask.nii
% tissue = [proc_dir 'rc2*Hires.nii'];              %OR rCerebellarWM_mask.nii
% mask = [proc_dir 'rmask_ICV_auto.nii'];           %OR rWM+Vents+Subcort_mask_nocer_nobrainstem.nii
% thr = various #s (ex: 2.5 or 4)
% GPN_SeedSelector_singlesub(study_dir,subjID,scanID,image,roi,tissue,mask,thr);

%% -------- FUNCTION --------
% subjlist = importdata(subject_list);
% for subj = 1:length(subjlist)
%     % Get subject and scan ID
%     m = strsplit(subjlist{subj}) 
%     subjID = m{1};
%     c = strsplit(m{2},'/')
%     subjmprage = c{3}; 
%     c = strsplit(m{3},'/')
%     subjflair = c{3};     
%     % get subject specific paths
%     image_subj = [study_dir subjID '/flair/' subjflair];
%     roi_subj = [study_dir subjID '/flair/' roi];
%     tissue_subj = [study_dir subjID '/flair/' tissue subjmprage];
%     mask_subj = [study_dir subjID '/flair/' mask];
%     
    % load images
    image_hdr = load_untouch_nii(image_subj);
    roi_hdr = load_untouch_nii(roi_subj);
    tissue_hdr = load_untouch_nii(tissue_subj);
    mask_hdr = load_untouch_nii(mask_subj);
    
    % calculate mean and standard deviation
    M = nanmean(image_hdr.img(roi_hdr.img > 0 & tissue_hdr.img == tissue_hdr.hdr.dime.glmax));
    S = nanstd(double(image_hdr.img(roi_hdr.img > 0 & tissue_hdr.img == tissue_hdr.hdr.dime.glmax)));
    
    % normalize intensities
    Zimage_hdr = image_hdr;
    Zimage_hdr.img = ((double(image_hdr.img) - M) ./ S) .* double(mask_hdr.img > 0);
    Zimage_hdr.hdr.dime.bitpix = 64;
    Zimage_hdr.hdr.dime.datatype = 64;
    save_untouch_nii(Zimage_hdr,strrep(image_subj,'.nii','_Znorm.nii'));
    
    for tI=1:length(thr)
        
        % threshold image and remove clusters less than five voxels
        CC = bwconncomp(Zimage_hdr.img > thr(tI));
        Zimage_thr_img = Zimage_hdr.img > thr(tI);
        for idx = 1:length(CC.PixelIdxList)
            if length(CC.PixelIdxList{idx}) < 2
                Zimage_thr_img(CC.PixelIdxList{idx}) = 0;
            end
        end
        
        % save threshold image
        Zimage_hdr.img = Zimage_thr_img;
        tag = ['_std' num2str(thr(tI)) '_Znorm_th.nii'];
        Zimage_hdr.hdr.dime.bitpix = 2;
        Zimage_hdr.hdr.dime.datatype = 2;
        save_untouch_nii(Zimage_hdr,strrep(image_subj,'.nii',tag));
        disp(['Done saving file: ' strrep(image_subj,'.nii',tag)]);
    end
    
%     
%     SE = strel('sphere',4);
%     mask_hdr.img = imdilate(mask_hdr.img,SE)
%     save_untouch_nii(region_hdr,strrep(mask_subj,'.nii','dilate_ball5.nii'));

% end