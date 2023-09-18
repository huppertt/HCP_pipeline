function fiff_write_dig_point(fid,dig)
%
% fiff_write_dig_point(fid,dig)
% 
% Writes a digitizer data point into a fif file
%
%     fid           An open fif file descriptor
%     dig           The point to write
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_write_dig_point.m,v 1.4 2006/04/23 15:29:40 msh Exp $
%   $Log: fiff_write_dig_point.m,v $
%   Revision 1.4  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.3  2006/04/12 10:29:02  msh
%   Made evoked data writing compatible with the structures returned in reading.
%
%   Revision 1.2  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%   Revision 1.1  2005/12/05 16:01:04  msh
%   Added an initial set of fiff writing routines.
%
%
%

me='MNE:fiff_write_dig_point';

if nargin ~= 2
        error(me,'Incorrect number of arguments');
end

FIFF_DIG_POINT=213;
FIFFT_DIG_POINT_STRUCT=33;
FIFFV_NEXT_SEQ=0;

%?typedef struct _fiffDigPointRec {
%  fiff_int_t kind;               /*!< FIFF_POINT_CARDINAL,
%                                  *   FIFF_POINT_HPI, or
%                                  *   FIFF_POINT_EEG */
%  fiff_int_t ident;              /*!< Number identifying this point */
%  fiff_float_t r[3];             /*!< Point location */
%} *fiffDigPoint,fiffDigPointRec; /*!< Digitization point description */

datasize=5*4;
count = fwrite(fid,int32(FIFF_DIG_POINT),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(FIFFT_DIG_POINT_STRUCT),'int32');
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
%
%   Start writing fiffDigPointRec
%
count = fwrite(fid,int32(dig.kind),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,int32(dig.ident),'int32');
if count ~= 1
    error(me,'write failed');
end
count = fwrite(fid,single(dig.r(1:3)),'single');
if count ~= 3
    error(me,'write failed');
end

return;


