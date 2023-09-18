function [comp] = mne_get_current_comp(info)
%
% [comp] = mne_get_current_comp(info)
%
% Get the current compensation in effect in the data
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_get_current_comp.m,v 1.2 2006/04/23 15:29:40 msh Exp $
%   $Log: mne_get_current_comp.m,v $
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/12 10:51:19  msh
%   Added projection writing and compensation routines
%
%
%
%

me='MNE:mne_get_current_comp';
FIFF = fiff_define_constants;

comp = 0;
first_comp = -1;
for k = 1:info.nchan
    if info.chs(k).kind == FIFF.FIFFV_MEG_CH
        comp = bitshift(double(info.chs(k).coil_type),-16);
        if first_comp < 0
            first_comp = comp;
        elseif comp ~= first_comp
            error(me,'Compensation is not set equally on all MEG channels');
        end
    end
end

return;

