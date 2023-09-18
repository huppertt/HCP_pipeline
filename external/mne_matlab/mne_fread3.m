function [retval] = mne_fread3(fid)
%
% [retval] = mne_fread3(fid)
% read a 3 byte integer out of a file
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
% $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_fread3.m,v 1.3 2006/04/23 15:29:40 msh Exp $
% $Log: mne_fread3.m,v $
% Revision 1.3  2006/04/23 15:29:40  msh
% Added MGH to the copyright
%
% Revision 1.2  2006/04/10 23:26:54  msh
% Added fiff reading routines
%
% Revision 1.1  2005/11/21 02:15:51  msh
% Added more routines
%
%

b1 = fread(fid, 1, 'uchar') ;
b2 = fread(fid, 1, 'uchar') ;
b3 = fread(fid, 1, 'uchar') ;
retval = bitshift(b1, 16) + bitshift(b2,8) + b3 ;

