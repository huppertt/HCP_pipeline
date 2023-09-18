function fiff_write_double_complex_matrix(fid,kind,mat)
%
% fiff_write_double_complex_matrix(fid,kind,mat)
% 
% Writes a double-precision complex matrix tag
%
%     fid           An open fif file descriptor
%     kind          The tag kind
%     mat           The data matrix
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_write_double_complex_matrix.m,v 1.1 2006/09/23 14:43:56 msh Exp $
%   $Log: fiff_write_double_complex_matrix.m,v $
%   Revision 1.1  2006/09/23 14:43:56  msh
%   Added routines for writing complex and double complex matrices.
%   Added routine for writing double-precision real matrix.
%
%
%

me='MNE:fiff_write_double_complex_matrix';

if nargin ~= 3
        error(me,'Incorrect number of arguments');
end

FIFFT_DOUBLE_COMPLEX = 26;
FIFFT_MATRIX  = bitshift(1,30);
FIFFT_MATRIX_DOUBLE_COMPLEX = bitor(FIFFT_DOUBLE_COMPLEX,FIFFT_MATRIX);
FIFFV_NEXT_SEQ=0;

datasize = 2*8*prod(size(mat)) + 4*3;

count = fwrite(fid,int32(kind),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_MATRIX_DOUBLE_COMPLEX),'int32');
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
nrow = size(mat,1);
ncol = size(mat,2);
for j = 1:nrow
   for k = 1:ncol
      count = fwrite(fid,real(mat(j,k)),'double');
      if count ~= 1
	 error(me,'write failed');
      end
      count = fwrite(fid,imag(mat(j,k)),'double');
      if count ~= 1
	 error(me,'write failed');
      end
   end
end
dims(1) = size(mat,2);
dims(2) = size(mat,1);
dims(3) = 2;
count = fwrite(fid,int32(dims),'int32');
if count ~= 3
    error(me,'write failed');
end

return;
