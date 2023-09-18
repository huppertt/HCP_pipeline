function fiff_write_double_complex(fid,kind,data)
%
% fiff_write_double_complex(fid,kind,data)
% 
% Writes a double-precision complex tag to a fif file
%
%     fid           An open fif file descriptor
%     kind          Tag kind
%     data          The data
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_write_double_complex.m,v 1.1 2006/09/23 14:43:56 msh Exp $
%   $Log: fiff_write_double_complex.m,v $
%   Revision 1.1  2006/09/23 14:43:56  msh
%   Added routines for writing complex and double complex matrices.
%   Added routine for writing double-precision real matrix.
%
%
%

me='MNE:fiff_write_double_complex';

if nargin ~= 3
        error(me,'Incorrect number of arguments');
end

FIFFT_DOUBLE_COMPLEX=26;
FIFFV_NEXT_SEQ=0;
nel=prod(size(data));
datasize=2*nel*8;
count = fwrite(fid,int32(kind),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_DOUBLE_COMPLEX),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(datasize),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFV_NEXT_SEQ),'int32');
if count ~= 1
   error(me,'write failed');
end
for k = 1:nel
   count = fwrite(fid,real(data(k)),'double');
   if count ~= 1
      error(me,'write failed');
   end
   count = fwrite(fid,imag(data(k)),'double');
   if count ~= 1
      error(me,'write failed');
   end
end
return;

