function [proj,nproj] = mne_make_projector_info(info)
%
% [proj,nproj] = mne_make_projector_info(info)
%
% Make an SSP operator using the meas info
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
%
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_make_projector_info.m,v 1.1 2006/05/05 10:52:33 msh Exp $
%   $Log: mne_make_projector_info.m,v $
%   Revision 1.1  2006/05/05 10:52:33  msh
%   Added missing file.
%
%
%

me='MNE:mne_make_projector_info';

if nargin ~= 1
   error(me,'Incorrect number of arguments');
end

[ proj, nproj ] = mne_make_projector(info.projs,info.ch_names,info.bads);

return;

end
