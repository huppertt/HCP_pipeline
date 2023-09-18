function [res] = mne_transform_source_space_to(src,dest,trans)
%
% [res] = mne_transform_source_space_to(src,dest,trans)
%
% Transform source space data to the desired coordinate system
%
% fname      - The name of the file
% include    - Include these channels (optional)
% exclude    - Exclude these channels (optional)
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_transform_source_space_to.m,v 1.3 2006/05/03 18:53:06 msh Exp $
%   $Log: mne_transform_source_space_to.m,v $
%   Revision 1.3  2006/05/03 18:53:06  msh
%   Approaching Matlab 6.5 backward compatibility
%
%   Revision 1.2  2006/04/23 15:29:41  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/18 23:21:22  msh
%   Added mne_transform_source_space_to and mne_transpose_named_matrix
%
%
%

me='MNE:mne_transform_source_space_to';

FIFF=fiff_define_constants;

if nargin ~= 3
    error(me,'Incorrect number of arguments');
end

if src.coord_frame == dest
    res = src;
    return;
end

if trans.to == src.coord_frame && trans.from == dest
    trans = fiff_invert_transform(trans);
elseif trans.from ~= src.coord_frame || trans.to ~= dest
    error(me,'Cannot transform the source space using this coordinate transformation');
end

t = trans.trans(1:3,:);
res    = src;
res.rr = (t*[ res.rr ones(res.np,1) ]')';
res.nn = (t*[ res.nn zeros(res.np,1) ]')';

return;

end


