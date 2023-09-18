function [fid, tree] = fiff_open(fname)
%
% [fid,tree] = fiff_open(fname)
%
% Open a fif file and provide the directory of tags
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_open.m,v 1.5 2006/05/03 19:03:19 msh Exp $
%   $Log: fiff_open.m,v $
%   Revision 1.5  2006/05/03 19:03:19  msh
%   Eliminated the use of cast function for Matlab 6.5 compatibility
%
%   Revision 1.4  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.3  2006/04/18 20:44:46  msh
%   Added reading of forward solution.
%   Use length instead of size when appropriate
%
%   Revision 1.2  2006/04/17 15:01:34  msh
%   More small improvements.
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%
FIFF = fiff_define_constants;
FIFFT_ID_STRUCT=31;

me='MNE:fiff_open';

fid = fopen(fname,'rb','ieee-be');

if (fid < 0)
   error(me,'Cannot open file %s', fname);
end;
%
%   Check that this looks like a fif file
%
tag = fiff_read_tag_info(fid);
if tag.kind ~= FIFF.FIFF_FILE_ID 
    error(me,'file does not start with a file id tag');
end
if tag.type ~= FIFFT_ID_STRUCT 
    error(me,'file does not start with a file id tag');
end
if tag.size ~= 20
    error(me,'file does not start with a file id tag');
end
tag = fiff_read_tag(fid);
if tag.kind ~= FIFF.FIFF_DIR_POINTER
    error(me,'file does have a directory pointer');
end
if nargout == 1
    fseek(fid,0,'bof');
    return;
end
%
%   Read or create the directory tree
%
fprintf(1,'\tCreating tag directory for %s...',fname);


dirpos = double(tag.data);
if dirpos > 0 
    tag = fiff_read_tag(fid,dirpos);
    dir = tag.data;
else
    k = 0;
    fseek(fid,0,'bof');
    dir = struct('kind',{},'type',{},'size',{},'pos',{});
    while tag.next >= 0
        pos = ftell(fid);
        tag = fiff_read_tag_info(fid);
        k = k + 1;
        dir(k).kind = tag.kind;
        dir(k).type = tag.type;
        dir(k).size = tag.size;
        dir(k).pos  = pos;
    end
end
%
%   Create the directory tree structure
%
tree = fiff_make_dir_tree(fid,dir);
fprintf(1,'[done]\n');
%
%   Back to the beginning
%
fseek(fid,0,'bof');
return;
