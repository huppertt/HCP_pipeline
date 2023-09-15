function HCP_makeMNIsourcespace(subjid,J,outfolder,force)


HCProot='/disk/HCP';
if(nargin<3)
    outfolder=fullfile(HCProot,'analyzed');
end

if(nargin<2 || isempty(J))
    J=5;
end

if(nargin<4)
    force=false;
end

HCP_matlab_setenv;

if(exist(fullfile(outfolder,subjid,'MNINonLinear',...
            ['waveletJ' num2str(J)],[subjid '-ico' num2str(J) '-src.fif']),'file') & ~force)
        return
end

p=fullfile(outfolder,subjid,'MNINonLinear',['waveletJ' num2str(J)]);
if(exist(p)~=7)
    mkdir(p);
end

if(exist(fullfile(outfolder,subjid,'MNINonLinear',...
        [subjid '.R.sphere.MSMSulc.164k_fs_LR.surf.gii'])))
    
    sphereRin = fullfile(outfolder,subjid,'MNINonLinear',...
        [subjid '.R.sphere.MSMSulc.164k_fs_LR.surf.gii']);
    sphereLin = fullfile(outfolder,subjid,'MNINonLinear',...
        [subjid '.L.sphere.MSMSulc.164k_fs_LR.surf.gii']);
    
    
    %resample the surfaces into that space
    f{1}='midthickness_MSMSulc.164k_fs_LR.surf.gii';
    f{2}='pial_MSMSulc.164k_fs_LR.surf.gii';
    f{3}='white_MSMSulc.164k_fs_LR.surf.gii';
    f{4}='sphere.reg_MSMSulc.164k_fs_LR.surf.gii';
    f{5}='very_inflated_MSMSulc.164k_fs_LR.surf.gii';
    fol='MNINonLinear';
    s='_MSMSulc';
else
    sphereRin = fullfile(outfolder,subjid,'MNINonLinear','Native',...
        [subjid '.R.sphere.reg.reg_LR.native.surf.gii']);
    sphereLin = fullfile(outfolder,subjid,'MNINonLinear','Native',...
        [subjid '.L.sphere.reg.reg_LR.native.surf.gii']);
    
    
    %resample the surfaces into that space
    f{1}='midthickness.native.surf.gii';
    f{2}='pial.native.surf.gii';
    f{3}='white.native.surf.gii';
    f{4}='sphere.reg.native.surf.gii';
    f{5}='very_inflated.native.surf.gii';
    fol=fullfile('MNINonLinear','Native');
    s='';
end


T=dlmread(fullfile(outfolder,subjid,'T1w',subjid,'mri','c_ras.mat'));
dlmwrite(fullfile(p,'inv_c_ras.mat'),inv(T),'delimiter','\t');

p2=fullfile(outfolder,subjid,'MNINonLinear','xfms');

for i=1:length(f)
    f2=[f{i}(1:min(strfind(f{i},'.'))-1) '.surf.gii'];
    giftiIn=fullfile(outfolder,subjid,fol,[subjid '.R.' f{i}]);
    giftiOut=fullfile(p,[subjid '.R.' f2]);
    HCP_resample_ico(giftiIn,sphereRin,J,giftiOut);
    
    if(i<4)
        system(['${CARET7DIR}/wb_command -surface-apply-warpfield ' giftiOut '  ' p2 filesep 'acpc_dc2standard.nii.gz ' giftiOut ' -fnirt '...
            p2 filesep 'standard2acpc_dc.nii.gz']);
        system(['${CARET7DIR}/wb_command -surface-apply-affine ' giftiOut ' ' p filesep 'inv_c_ras.mat ' giftiOut]);
    end
    giftiIn=fullfile(outfolder,subjid,fol,[subjid '.L.' f{i}]);
    giftiOut=fullfile(p,[subjid '.L.' f2]);
    HCP_resample_ico(giftiIn,sphereLin,J,giftiOut);
    
    if(i<4)
        system(['${CARET7DIR}/wb_command -surface-apply-warpfield ' giftiOut '  ' p2 filesep 'acpc_dc2standard.nii.gz ' giftiOut ' -fnirt '...
            p2 filesep 'standard2acpc_dc.nii.gz']);
        system(['${CARET7DIR}/wb_command -surface-apply-affine ' giftiOut ' ' p filesep 'inv_c_ras.mat ' giftiOut]);
    end
end


%% create a template CIFTI file 
system(['${CARET7DIR}/wb_command -surface-coordinates-to-metric ' p filesep subjid '.L.pial' s '.surf.gii ' p filesep subjid '.L.pial' s '.func.gii']);
system(['${CARET7DIR}/wb_command -surface-coordinates-to-metric ' p filesep subjid '.R.pial' s '.surf.gii ' p filesep subjid '.R.pial' s '.func.gii']);
system(['${CARET7DIR}/wb_command -cifti-create-dense-scalar ' p filesep subjid '.LR.pial' s '.dscalar.nii -left-metric ' ...
    p filesep subjid '.L.pial' s '.func.gii -right-metric ' p filesep subjid '.R.pial' s '.func.gii']);



%% create the FIFF source space

Rg=gifti(fullfile(p,[subjid '.R.midthickness' s '.surf.gii']));
Lg=gifti(fullfile(p,[subjid '.L.midthickness' s '.surf.gii']));
 
r.rr=Rg.vertices/1000;
r.tris=Rg.faces-1;
r.ntri=size(r.tris,1);
r.inuse=ones(1,size(r.rr,1));
r.nuse=size(r.rr,1); 

r.use_tris=Rg.faces-1;
r.nuse_tri=size(r.tris,1);


h=plot(Rg);
r.nn=get(h,'vertexNormals');
close;



l.rr=Lg.vertices/1000;
l.tris=Lg.faces-1;
l.ntri=size(l.tris,1);
l.inuse=ones(1,size(l.rr,1));
l.nuse=size(l.rr,1); 

l.use_tris=Lg.faces-1;
l.nuse_tri=size(l.tris,1);


h=plot(Lg);
l.nn=get(h,'vertexNormals');
close;
 
% l.rr=l.rr*.98;
% r.rr=r.rr*.98;
fname=fullfile(p,[subjid s '-ico' num2str(J) '-src.fif']);
FIFF=fiff_define_constants;

FIFF.FIFFV_MNE_SPACE_SURFACE=1;
FIFF.FIFF_MNE_SOURCE_SPACE_TYPE=3518;

fid=fiff_start_file(fname);

fiff_start_block(fid,FIFF.FIFFB_MNE_SOURCE_SPACE);

fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_ID,FIFF.FIFFV_MNE_SURF_RIGHT_HEMI);
fiff_write_int(fid,FIFF.FIFF_MNE_COORD_FRAME,5);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_TYPE, FIFF.FIFFV_MNE_SPACE_SURFACE);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_NPOINTS,size(r.rr,1));
fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_POINTS,r.rr);

fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NORMALS,r.nn);

fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_SELECTION,r.inuse);
fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NUSE,r.nuse);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_NTRI,r.ntri);
fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_TRIANGLES,r.tris+1);

fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_USE_TRIANGLES,r.use_tris);
fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NUSE_TRI,r.nuse_tri);

fiff_end_block(fid,FIFF.FIFFB_MNE_SOURCE_SPACE);



fiff_start_block(fid,FIFF.FIFFB_MNE_SOURCE_SPACE);

fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_ID,FIFF.FIFFV_MNE_SURF_LEFT_HEMI);
fiff_write_int(fid,FIFF.FIFF_MNE_COORD_FRAME,5);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_TYPE, FIFF.FIFFV_MNE_SPACE_SURFACE);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_NPOINTS,size(l.rr,1));
fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_POINTS,l.rr);

fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NORMALS,l.nn);

fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_SELECTION,l.inuse);
fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NUSE,l.nuse);

fiff_write_int(fid, FIFF.FIFF_MNE_SOURCE_SPACE_NTRI,l.ntri);
fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_TRIANGLES,l.tris+1);

fiff_write_float_matrix(fid,FIFF.FIFF_MNE_SOURCE_SPACE_USE_TRIANGLES,l.use_tris);
fiff_write_int(fid,FIFF.FIFF_MNE_SOURCE_SPACE_NUSE_TRI,l.nuse_tri);

fiff_end_block(fid,FIFF.FIFFB_MNE_SOURCE_SPACE);

fiff_end_file(fid);



    

 
 
  
  