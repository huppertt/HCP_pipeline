function new_chs = mne_set_current_comp(chs,value)
%
% mne_set_current_comp(chs,value)
%
% Set the current compensation value in the channel info structures
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_set_current_comp.m,v 1.4 2006/04/23 15:29:41 msh Exp $
%   $Log: mne_set_current_comp.m,v $
%   Revision 1.4  2006/04/23 15:29:41  msh
%   Added MGH to the copyright
%
%   Revision 1.3  2006/04/18 20:44:46  msh
%   Added reading of forward solution.
%   Use length instead of size when appropriate
%
%   Revision 1.2  2006/04/14 15:49:49  msh
%   Improved the channel selection code and added ch_names to measurement info.
%
%   Revision 1.1  2006/04/12 10:51:19  msh
%   Added projection writing and compensation routines
%
%
%
%

me='MNE:mne_set_current_comp';

FIFF = fiff_define_constants;

new_chs = chs;

for k = 1:length(chs)
    if chs(k).kind == FIFF.FIFFV_MEG_CH
        coil_type = bitand(double(chs(k).coil_type),hex2dec('FFFF'));
        new_chs(k).coil_type = bitor(coil_type,bitshift(value,16));
    end
end

return;
