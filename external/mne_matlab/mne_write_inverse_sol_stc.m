function mne_write_inverse_sol_stc(stem,inv,sol,tmin,tstep)
%
% function mne_write_inverse_sol_stc(stem,inv,sol,tmin,tstep)
%
% Compute the three Cartesian components of a vector together
%
% stem      - Stem for stc files
% inv       - The inverse operator structure
% sol       - A solution matrix (locations x time)
% tmin      - Time of the first data point in seconds
% tstep     - Time between data points in seconds
%

%
%
%   Copyright 2006
%
%   Matti Hamalainen
%   Athinoula A. Martinos Center for Biomedical Imaging
%   Massachusetts General Hospital
%   Charlestown, MA, USA
%
%   No part of this program may be photocopied, reproduced,
%   or translated to another program language without the
%   prior written consent of the author.
%
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_write_inverse_sol_stc.m,v 1.2 2006/09/14 22:12:48 msh Exp $
%   $Log: mne_write_inverse_sol_stc.m,v $
%   Revision 1.2  2006/09/14 22:12:48  msh
%   Added output of the files written.
%
%   Revision 1.1  2006/05/05 03:50:40  msh
%   Added routines to compute L2-norm inverse solutions.
%   Added mne_write_inverse_sol_stc to write them in stc files
%   Several bug fixes in other files
%
%
%

me='MNE:mne_write_inverse_sol_stc';
FIFF=fiff_define_constants;

if nargin ~= 5
    error(me,'Incorrect number of arguments');
end

if size(sol,1) ~= inv.nsource
    error(me,'The solution matrix cannot correspond to this inverse operator');
end

off = 0;
for k = 1:length(inv.src)
    off = off + inv.src(k).nuse;
    if (inv.src(k).id ~= FIFF.FIFFV_MNE_SURF_LEFT_HEMI && ...
            inv.src(k).id ~= FIFF.FIFFV_MNE_SURF_RIGHT_HEMI)
        error(me,'Source space hemispheres not properly assigned.');
    end
end
if off ~= inv.nsource
    error(me,'Inverse solution source spaces are inconsistent with other inverse operator data');
end
%
%   Write a separate stc file for each source space
%   
off = 0;
for k = 1:length(inv.src)
    if (inv.src(k).id == FIFF.FIFFV_MNE_SURF_LEFT_HEMI)
        outname = sprintf('%s-lh.stc',stem);
    elseif (inv.src(k).id == FIFF.FIFFV_MNE_SURF_RIGHT_HEMI)
        outname = sprintf('%s-rh.stc',stem);
    end
    stc.tmin     = tmin;
    stc.tstep    = tstep;
    stc.vertices = inv.src(k).vertno - 1;
    stc.data     = sol(off+1:off+inv.src(k).nuse,:);
    mne_write_stc_file(outname,stc);
    off = off + inv.src(k).nuse;
    fprintf(1,'Wrote %s\n',outname);
end

return;



