function [info,meas] = fiff_read_meas_info(source,tree)
%
% [info,meas] = fiff_read_meas_info(source,tree)
%
% Read the measurement info
%
% If tree is specified, source is assumed to be an open file id,
% otherwise a the name of the file to read. If tree is missing, the
% meas output argument should not be specified.
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_read_meas_info.m,v 1.10 2006/09/24 18:52:43 msh Exp $
%   $Log: fiff_read_meas_info.m,v $
%   Revision 1.10  2006/09/24 18:52:43  msh
%   Added FIFFV_REF_MEG_CH to fiff_define_constants.
%   Added coord_frame field to dig point structure.
%
%   Revision 1.9  2006/09/08 19:27:13  msh
%   Added KIT coil type to mne_load_coil_def
%   Allow reading of measurement info by specifying just a file name.
%
%   Revision 1.8  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.7  2006/04/18 20:44:46  msh
%   Added reading of forward solution.
%   Use length instead of size when appropriate
%
%   Revision 1.6  2006/04/14 15:49:49  msh
%   Improved the channel selection code and added ch_names to measurement info.
%
%   Revision 1.5  2006/04/13 23:09:46  msh
%   Further streamlining of the coordinate transformations.
%
%   Revision 1.4  2006/04/13 22:37:03  msh
%   Added head_head_trans field to info.
%
%   Revision 1.3  2006/04/13 17:05:45  msh
%   Added reading of bad channels to fiff_read_meas_info.m
%   Added mne_pick_channels_cov.m
%
%   Revision 1.2  2006/04/12 10:29:02  msh
%   Made evoked data writing compatible with the structures returned in reading.
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%

FIFF = fiff_define_constants;

me='MNE:fiff_read_meas_info';

if nargin ~= 2 & nargin ~= 1
   error(me,'Incorrect number of arguments');
end

if nargin == 1 & nargout == 2
   error(me,'meas output argument is not allowed with file name specified');
end

if nargin == 1
   [ fid, tree ] = fiff_open(source);
   open_here = true;
else
   fid = source;
   open_here = false;
end

%
%   Find the desired blocks
%
meas = fiff_dir_tree_find(tree,FIFF.FIFFB_MEAS);
if length(meas) == 0
   if open_here
      fclose(fid);
   end
   error(me,'Could not find measurement data');
end
%
meas_info = fiff_dir_tree_find(meas,FIFF.FIFFB_MEAS_INFO);
if length(meas_info) == 0
   if open_here
      fclose(fid);
   end
   error(me,'Could not find measurement info');
end
%
%   Read measurement info
%
dev_head_t=[];
ctf_head_t=[];
p = 0;
for k = 1:meas_info.nent
   kind = meas_info.dir(k).kind;
   pos  = meas_info.dir(k).pos;
   switch kind
       case FIFF.FIFF_NCHAN
           tag = fiff_read_tag(fid,pos);
           nchan = tag.data;
       case FIFF.FIFF_SFREQ
           tag = fiff_read_tag(fid,pos);
           sfreq = tag.data;
       case FIFF.FIFF_CH_INFO
           p = p+1;
           tag = fiff_read_tag(fid,pos);
           chs(p) = tag.data;
       case FIFF.FIFF_LOWPASS
           tag = fiff_read_tag(fid,pos);
	   lowpass = tag.data;
       case FIFF.FIFF_HIGHPASS
           tag = fiff_read_tag(fid,pos);
	   highpass = tag.data;
       case FIFF.FIFF_COORD_TRANS
           tag = fiff_read_tag(fid,pos);
           cand = tag.data;
	   if cand.from == FIFF.FIFFV_COORD_DEVICE && ...
	      cand.to == FIFF.FIFFV_COORD_HEAD
	      dev_head_t = cand;
	   elseif cand.from == FIFF.FIFFV_MNE_COORD_CTF_HEAD && ...
	      cand.to == FIFF.FIFFV_COORD_HEAD
	      ctf_head_t = cand;
           end
   end
end
%
%   Check that we have everything we need
%
if ~exist('nchan')
   if open_here
      fclose(fid);
   end
   error(me,'Number of channels in not defined');
end
if ~exist('sfreq')
   if open_here
      fclose(fid);
   end
   error(me,'Sampling frequency is not defined');
end
if ~exist('chs')
   if open_here
      fclose(fid);
   end
   error(me,'Channel information not defined');
end
if length(chs) ~= nchan
   if open_here
      fclose(fid);
   end
   error(me,'Incorrect number of channel definitions found');
end
    

if isempty(dev_head_t) || isempty(ctf_head_t)
    hpi_result = fiff_dir_tree_find(meas_info,FIFF.FIFFB_HPI_RESULT);
    if length(hpi_result) == 1
        for k = 1:hpi_result.nent
           kind = hpi_result.dir(k).kind;
           pos  = hpi_result.dir(k).pos;
           if kind == FIFF.FIFF_COORD_TRANS
               tag = fiff_read_tag(fid,pos);
	       cand = tag.data;
               if cand.from == FIFF.FIFFV_COORD_DEVICE && ...
		  cand.to == FIFF.FIFFV_COORD_HEAD
		  dev_head_t = cand;
	       elseif cand.from == FIFF.FIFFV_MNE_COORD_CTF_HEAD && ...
		  cand.to == FIFF.FIFFV_COORD_HEAD
		  ctf_head_t = cand;
	       end
           end
        end
   end
end
%
%   Locate the Polhemus data
%   
isotrak = fiff_dir_tree_find(meas_info,FIFF.FIFFB_ISOTRAK);
dig=struct('kind',{},'ident',{},'r',{},'coord_frame',{});
if length(isotrak) == 1
    p = 0;
    for k = 1:isotrak.nent
        kind = isotrak.dir(k).kind;
        pos  = isotrak.dir(k).pos;
        if kind == FIFF.FIFF_DIG_POINT
            p = p + 1;
            tag = fiff_read_tag(fid,pos);
            dig(p) = tag.data;
	    dig(p).coord_frame = FIFF.FIFFV_COORD_HEAD;
        end
    end
end
%
%   Load the SSP data
%
projs = fiff_read_proj(fid,meas_info);
%
%   Load the CTF compensation data
%
comps = fiff_read_ctf_comp(fid,meas_info,chs);
%
%   Load the bad channel list
%
bads = fiff_read_bad_channels(fid,meas_info);
%
%   Put the data together
%
if ~isempty(tree.id)
   info.file_id = tree.id;
else
   info.file_id = [];
end
%
%  Make the most appropriate selection for the measurement id
%
if isempty(meas_info.parent_id)
   if isempty(meas_info.id)
      if isempty(meas.parent_id)
	 if isempty(meas.id)
	    info.meas_id = info.file_id;
	 else
	    info.meas_id = meas.id;
	 end
      else
	 info.meas_id = meas.parent_id;
      end
   else
      info.meas_id = meas_info.id;
   end
else
   info.meas_id = meas_info.parent_id;
end
info.nchan = nchan;
info.sfreq = sfreq;
if exist('highpass')
    info.highpass = highpass;
else
    info.highpass = 0;
end
if exist('lowpass')
   info.lowpass = lowpass;
else
   info.lowpass = info.sfreq/2.0;
end
%
%   Add the channel information and make a list of channel names
%   for convenience
%
info.chs = chs;
for c = 1:info.nchan
   info.ch_names{c} = info.chs(c).ch_name;
end
 %
 %  Add the coordinate transformations
 %
info.dev_head_t = dev_head_t;
info.ctf_head_t = ctf_head_t;
if ~isempty(info.dev_head_t) && ~isempty(info.ctf_head_t)
   info.dev_ctf_t    = info.dev_head_t;
   info.dev_ctf_t.to = info.ctf_head_t.from;
   info.dev_ctf_t.trans = inv(ctf_head_t.trans)*info.dev_ctf_t.trans;
else
   info.dev_ctf_t = [];
end
%
%   All kinds of auxliary stuff
%
info.dig   = dig;
info.bads  = bads;
info.projs = projs;
info.comps = comps;

if open_here
   fclose(fid);
end

return;

    function [tag] = find_tag(node,findkind)

        for p = 1:node.nent
           if node.dir(p).kind == findkind
              tag = fiff_read_tag(fid,node.dir(p).pos);
              return;
           end
        end
        tag = [];
    end

end
