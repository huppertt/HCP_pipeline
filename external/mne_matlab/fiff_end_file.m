function fiff_end_file(fid)
%
% fiff_end_file(fid)
% 
% Writes the closing tags to a fif file and closes the file
%
%     fid           An open fif file descriptor
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_end_file.m,v 1.3 2006/04/23 15:29:40 msh Exp $
%   $Log: fiff_end_file.m,v $
%   Revision 1.3  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.2  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%   Revision 1.1  2005/12/05 16:01:04  msh
%   Added an initial set of fiff writing routines.
%
%
%

me='MNE:fiff_end_file';

if nargin ~= 1
        error(me,'An open file id required as an argument');
end

FIFF_NOP=108;
FIFFT_VOID=0;
FIFFV_NEXT_NONE=-1;
datasize=0;
count = fwrite(fid,int32(FIFF_NOP),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_VOID),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(datasize),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFV_NEXT_NONE),'int32');
if count ~= 1
    error(me,'write failed');
end
fclose(fid);

return;

