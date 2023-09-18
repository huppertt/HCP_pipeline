function [data] = fiff_setup_read_raw(fname)
%
% [data] = fiff_setup_read_raw(fname)
%
% Read information about raw dat
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_setup_read_raw.m,v 1.6 2006/05/03 18:53:05 msh Exp $
%   $Log: fiff_setup_read_raw.m,v $
%   Revision 1.6  2006/05/03 18:53:05  msh
%   Approaching Matlab 6.5 backward compatibility
%
%   Revision 1.5  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.4  2006/04/21 16:17:48  msh
%   Added handling of CTF compensation
%
%   Revision 1.3  2006/04/21 14:23:16  msh
%   Further improvements in raw data reading
%
%   Revision 1.2  2006/04/21 11:33:18  msh
%   Added raw segment reading routines
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%

FIFF = fiff_define_constants;

FIFFT_SHORT=2;
FIFFT_INT=3;
FIFFT_FLOAT=4;
FIFFT_DAU_PACK16=16;


me='MNE:fiff_setup_read_raw';

if nargin ~= 1
   error(me,'Incorrect number of arguments');
end
%
%   Open the file
%
fprintf(1,'Opening raw data file %s...\n',fname);
[ fid, tree ] = fiff_open(fname);
%
%   Read the measurement info
%
[ info, meas ] = fiff_read_meas_info(fid,tree);
%
%   Locate the data of interest
%
raw = fiff_dir_tree_find(meas,FIFF.FIFFB_RAW_DATA);
if isempty(raw)
   raw = fiff_dir_tree_find(meas,FIFF.FIFFB_CONTINUOUS_DATA);
   if isempty(raw)
      error(me,'No raw data in %s',fname);
   end
end
%
%   Set up the output structure
%
data.fid        = fid;
data.info       = info;
data.first_samp = 0;
data.last_samp  = 0;
%
%   Process the directory
%
dir          = raw.dir;
nent         = raw.nent;
nchan        = info.nchan;
first        = 1;
first_samp   = 0;
first_skip   = 0;
%
%  Get first sample tag if it is there
%
if dir(first).kind == FIFF.FIFF_FIRST_SAMPLE
   tag = fiff_read_tag(fid,dir(first).pos);
   first_samp = tag.data;
   first = first + 1;
end
%
%  Omit initial skip
%
if dir(first).kind == FIFF.FIFF_DATA_SKIP
   tag = fiff_read_tag(fid,dir(first).pos);
   first_skip = tag.data;
   first = first + 1;
end
data.first_samp = first_samp;
%
%   Go through the remaining tags in the directory
%
rawdir = struct('ent',{},'first',{},'last',{},'nsamp',{});
nskip = 0;
ndir  = 0;
for k = first:nent
   ent = dir(k);
   if ent.kind == FIFF.FIFF_DATA_SKIP
      tag = fiff_read_tag(fid,dir(first).pos);
      try
        nskip = tag.data;
      end
   elseif ent.kind == FIFF.FIFF_DATA_BUFFER
      %
      %   Figure out the number of samples in this buffer
      %
      switch ent.type
      case FIFFT_DAU_PACK16
	 nsamp = ent.size/(2*nchan);
      case FIFFT_SHORT
	 nsamp = ent.size/(2*nchan);
      case FIFFT_FLOAT
	 nsamp = ent.size/(4*nchan);
      case FIFFT_INT
	 nsamp = ent.size/(4*nchan);
      otherwise
	 fclose(fid);
	 error(me,'Cannot handle data buffers of type %d',ent.type);
      end
      %
      %  Do we have a skip pending?
      %
      if nskip > 0
	 ndir        = ndir+1;
	 rawdir(ndir).ent   = [];
	 rawdir(ndir).first = first_samp;
	 rawdir(ndir).last  = first_samp + nskip*nsamp - 1;
	 rawdir(ndir).nsamp = nskip*nsamp;
	 first_samp = first_samp + nskip*nsamp;
	 nskip = 0;
      end
      %
      %  Add a data buffer
      %
      ndir               = ndir+1;
      rawdir(ndir).ent   = ent;
      rawdir(ndir).first = first_samp;
      rawdir(ndir).last  = first_samp + nsamp - 1;
      rawdir(ndir).nsamp = nsamp;
      first_samp = first_samp + nsamp;
   end
end
data.last_samp  = first_samp - 1;
%
%   Add the calibration factors
%
cals = zeros(1,data.info.nchan);
for k = 1:data.info.nchan
   cals(k) = data.info.chs(k).range*data.info.chs(k).cal;
end
%
data.cals       = cals;
data.rawdir     = rawdir;
data.proj       = [];
data.comp       = [];
%
fprintf(1,'\tRange : %d ... %d  =  %9.3f ... %9.3f secs\n',...
   data.first_samp,data.last_samp,...
   double(data.first_samp)/data.info.sfreq,...
   double(data.last_samp)/data.info.sfreq);
fprintf(1,'Ready.\n');
return;

    function [tag] = find_tag(node,findkind)

    for p = 1:node.nent
       kind = node.dir(p).kind;
       pos  = node.dir(p).pos;
       if kind == findkind
	  tag = fiff_read_tag(fid,pos);
	  return;
       end
    end
    tag = [];
    return
    
    end

end


