function [cov] = mne_read_noise_cov(fname)
%
% [cov] = mne_read_noise_cov(fname)
%
% Reads a noise-covariance matrix from a fiff file
%
% fname      - The name of the file
%
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_read_noise_cov.m,v 1.5 2006/05/03 19:09:03 msh Exp $
%   $Log: mne_read_noise_cov.m,v $
%   Revision 1.5  2006/05/03 19:09:03  msh
%   Fixed even more compatibility issues.
%
%   Revision 1.4  2006/04/23 15:29:41  msh
%   Added MGH to the copyright
%
%   Revision 1.3  2006/04/20 21:49:38  msh
%   Added mne_read_inverse_operator
%   Changed some of the routines accordingly for more flexibility.
%
%   Revision 1.2  2006/04/18 20:44:46  msh
%   Added reading of forward solution.
%   Use length instead of size when appropriate
%
%   Revision 1.1  2006/04/12 17:09:28  msh
%   Added routines for reading noise-covariance matrices
%
%
%

me='MNE:mne_read_noise_cov';

FIFF=fiff_define_constants;
%
%   Open the file, create directory
%
[ fid, tree ] = fiff_open(fname);
try
   cov = mne_read_cov(fid,tree,FIFF.FIFFV_MNE_NOISE_COV);
catch
   fclose(fid);
   error(me,'%s',mne_omit_first_line(lasterr));
end

return;

end