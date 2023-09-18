function [tag] = fiff_read_tag(fid,pos)
%
% [fid,dir] = fiff_read_tag(fid,pos)
%
% Read one tag from a fif file.
% if pos is not provided, reading starts from the current file position
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_read_tag.m,v 1.13 2006/09/24 18:52:43 msh Exp $
%   $Log: fiff_read_tag.m,v $
%   Revision 1.13  2006/09/24 18:52:43  msh
%   Added FIFFV_REF_MEG_CH to fiff_define_constants.
%   Added coord_frame field to dig point structure.
%
%   Revision 1.12  2006/09/23 13:31:55  msh
%   Added reading of complex and double complex arrays and matrices
%
%   Revision 1.11  2006/05/03 19:03:19  msh
%   Eliminated the use of cast function for Matlab 6.5 compatibility
%
%   Revision 1.10  2006/05/03 18:53:04  msh
%   Approaching Matlab 6.5 backward compatibility
%
%   Revision 1.9  2006/04/26 19:50:58  msh
%   Added fiff_read_mri
%
%   Revision 1.8  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.7  2006/04/17 11:52:15  msh
%   Added coil definition stuff
%
%   Revision 1.6  2006/04/15 12:21:00  msh
%   Several small improvements
%
%   Revision 1.5  2006/04/13 21:20:06  msh
%   Added new routines for the channel information transformation.
%
%   Revision 1.4  2006/04/13 17:53:31  msh
%   Added coordinate frame to the channel info structure
%
%   Revision 1.3  2006/04/13 17:49:12  msh
%   Added some more comments
%
%   Revision 1.2  2006/04/13 17:47:50  msh
%   Make coil coordinate transformation or EEG electrode location out of the channel  info.
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%
FIFF = fiff_define_constants;
%
%   Data types
%
FIFFT_BYTE=1;
FIFFT_SHORT=2;
FIFFT_INT=3;
FIFFT_OLD_PACK=23;
FIFFT_COMPLEX=25;
FIFFT_DOUBLE_COMPLEX=26;
FIFFT_FLOAT=4;
FIFFT_DOUBLE=5;
FIFFT_STRING=10;
FIFFT_DAU_PACK16=16;
FIFFT_ID_STRUCT=31;
FIFFT_DIG_POINT_STRUCT=33;
FIFFT_COORD_TRANS_STRUCT=35;
FIFFT_CH_INFO_STRUCT=30;
FIFFT_DIR_ENTRY_STRUCT=32;

me='MNE:fiff_read_tag';

if nargin == 2
    fseek(fid,pos,'bof');
elseif nargin ~= 1
    error(me,'Incorrect number of arguments');
end

tag.kind = fread(fid,1,'int32');
tag.type = fread(fid,1,'uint32');
tag.size = fread(fid,1,'int32');
tag.next = fread(fid,1,'int32');
if tag.size > 0
    matrix_coding = bitshift(bitand(hex2dec('FFFF0000'),tag.type),-16);
    if matrix_coding ~= 0
        %
        %   Matrices
        %
        if matrix_coding ~= hex2dec('4000');
          error(me,'Cannot handle other than dense matrices yet')
        end
        %
        % Find dimensions and return to the beginning of tag data
        %
	pos = ftell(fid);
        fseek(fid,tag.size-4,'cof');
        ndim = fread(fid,1,'int32');
        fseek(fid,-(ndim+1)*4,'cof');
        dims = fread(fid,ndim,'int32');
	%
	% Back to where the data start
	%
        fseek(fid,pos,'bof');
        
        if ndim~= 2
	   warning(me,'Only two-dimensional matrices are supported at this time');
	end
        
        matrix_type = bitand(hex2dec('FFFF'),tag.type);

	switch matrix_type
	   
	case FIFFT_INT
	   idata = fread(fid,prod(dims),'int32=>int32');
	    if(ndim==2)
            tag.data = reshape(idata,dims(1),dims(2))';
       else
           tag.data = permute(reshape(idata,dims(1),dims(2),dims(3)),[3 2 1]);
       end
	case FIFFT_FLOAT
	   fdata = fread(fid,prod(dims),'single=>double');
       if(ndim==2)
            tag.data = reshape(fdata,dims(1),dims(2))';
       else
           tag.data = permute(reshape(fdata,dims(1),dims(2),dims(3)),[3 2 1]);
       end
	case FIFFT_DOUBLE
	   ddata = fread(fid,prod(dims),'double=>double');
	    if(ndim==2)
            tag.data = reshape(ddata,dims(1),dims(2))';
       else
           tag.data = permute(reshape(ddata,dims(1),dims(2),dims(3)),[3 2 1]);
       end
	case FIFFT_COMPLEX
	   fdata = fread(fid,2*prod(dims),'single=>double');
	   nel = length(fdata);
	   fdata = complex(fdata(1:2:nel),fdata(2:2:nel));
	   %
	   %   Note: we need the non-conjugate transpose here
	   %
        if(ndim==2)
            tag.data = transpose(reshape(fdata,dims(1),dims(2)));
            
       else
           tag.data = permute(reshape(fdata,dims(1),dims(2),dims(3)),[3 2 1]);
       end
	  
	case FIFFT_DOUBLE_COMPLEX
	   ddata = fread(fid,2*dims(1)*dims(2),'double=>double');
	   nel = length(ddata);
	   ddata = complex(ddata(1:2:nel),ddata(2:2:nel));
	   %
	   %   Note: we need the non-conjugate transpose here
	   %
	   tag.data = transpose(reshape(ddata,dims(1),dims(2)));
	otherwise
	   error(me,'Cannot handle matrix of type %d yet',matrix_type)
	   
	end
    else
        %
        %   All other data types
        %
	switch tag.type
	%
	%   Simple types
	%
        case FIFFT_BYTE
	   tag.data = fread(fid,tag.size,'uint8=>uint8');
        case FIFFT_INT
	   tag.data = fread(fid,tag.size/4,'int32=>int32');
	case FIFFT_FLOAT
	   tag.data = fread(fid,tag.size/4,'single=>double');
	case FIFFT_DOUBLE
	   tag.data = fread(fid,tag.size/8,'double');            
	case FIFFT_STRING
	   tag.data = fread(fid,tag.size,'uint8=>char')';
	case FIFFT_DAU_PACK16
	   tag.data = fread(fid,tag.size/2,'int16=>int16');
	case FIFFT_COMPLEX
	   tag.data = fread(fid,tag.size/4,'single=>double');
	   nel = length(tag.data);
	   tag.data = complex(tag.data(1:2:nel),tag.data(2:2:nel));
	case FIFFT_DOUBLE_COMPLEX
	   tag.data = fread(fid,tag.size/8,'double');            
	   nel = length(tag.data);
	   tag.data = complex(tag.data(1:2:nel),tag.data(2:2:nel));
	%   
	%   Structures
	%
        case FIFFT_ID_STRUCT
	   tag.data.version = fread(fid,1,'int32=>int32');
	   tag.data.machid  = fread(fid,2,'int32=>int32');
	   tag.data.secs    = fread(fid,1,'int32=>int32');
	   tag.data.usecs   = fread(fid,1,'int32=>int32');
	case FIFFT_DIG_POINT_STRUCT
	   tag.data.kind    = fread(fid,1,'int32=>int32');
	   tag.data.ident   = fread(fid,1,'int32=>int32');
	   tag.data.r       = fread(fid,3,'single=>single');
	   tag.data.coord_frame = 0;
	case FIFFT_COORD_TRANS_STRUCT
	   tag.data.from = fread(fid,1,'int32=>int32');
	   tag.data.to   = fread(fid,1,'int32=>int32');
	   rot  = fread(fid,9,'single=>double');
	   rot = reshape(rot,3,3)';
	   move = fread(fid,3,'single=>double');
	   tag.data.trans = [ rot move ; [ 0  0 0 1 ]];
	   %
	   % Skip over the inverse transformation
	   % It is easier to just use inverse of trans in Matlab
	   %
	   fseek(fid,12*4,'cof');
	case FIFFT_CH_INFO_STRUCT
	   tag.data.scanno    = fread(fid,1,'int32=>int32');
	   tag.data.logno     = fread(fid,1,'int32=>int32');
	   tag.data.kind      = fread(fid,1,'int32=>int32');
	   tag.data.range     = fread(fid,1,'single=>double');
	   tag.data.cal       = fread(fid,1,'single=>double');
	   tag.data.coil_type = fread(fid,1,'int32=>int32');
	   %
	   %   Read the coil coordinate system definition
	   %
	   tag.data.loc        = fread(fid,12,'single=>double');
	   tag.data.coil_trans  = [];
	   tag.data.eeg_loc     = [];
	   tag.data.coord_frame = FIFF.FIFFV_COORD_UNKNOWN;
	   %
	   %   Convert loc into a more useful format
	   %
	   loc = tag.data.loc;
	   if tag.data.kind == FIFF.FIFFV_MEG_CH || tag.data.kind == FIFF.FIFFV_REF_MEG_CH 
	      tag.data.coil_trans  = [ [ loc(4:6) loc(7:9) loc(10:12) loc(1:3) ] ; [ 0 0 0 1 ] ];
	      tag.data.coord_frame = FIFF.FIFFV_COORD_DEVICE;
	   elseif tag.data.kind == FIFF.FIFFV_EEG_CH
	      if norm(loc(4:6)) > 0
		 tag.data.eeg_loc     = [ loc(1:3) loc(4:6) ];
	      else
		 tag.data.eeg_loc = [ loc(1:3) ];
	      end
	      tag.data.coord_frame = FIFF.FIFFV_COORD_HEAD;
	   end
	   %
	   %   Unit and exponent
	   %
	   tag.data.unit     = fread(fid,1,'int32=>int32');
	   tag.data.unit_mul = fread(fid,1,'int32=>int32');
	   %
	   %   Handle the channel name
	   %
	   ch_name   = fread(fid,16,'uint8=>char')';
	   %
	   % Omit nulls
	   %
	   len = 16;
	   for k = 1:16
	      if ch_name(k) == 0
		 len = k-1;
		 break
	      end
	   end
	   tag.data.ch_name = ch_name(1:len);
	case FIFFT_OLD_PACK
	   offset   = fread(fid,1,'single=>double');
	   scale    = fread(fid,1,'single=>double');
	   tag.data = fread(fid,(tag.size-8)/2,'int16=>short');
	   tag.data = scale*single(tag.data) + offset;
	case FIFFT_DIR_ENTRY_STRUCT
	   tag.data = struct('kind',{},'type',{},'size',{},'pos',{});
	   for k = 1:tag.size/16-1
	      kind = fread(fid,1,'int32');
	      type = fread(fid,1,'uint32');
	      tagsize = fread(fid,1,'int32');
	      pos  = fread(fid,1,'int32');
	      tag.data(k).kind = kind;
	      tag.data(k).type = type;
	      tag.data(k).size = tagsize;
	      tag.data(k).pos  = pos;
	   end
	   
	otherwise
	   error(me,'Unimplemented tag data type %d',tag.type);
	   
	end
   end
end

if tag.next ~= FIFF.FIFFV_NEXT_SEQ
  fseek(fid,tag.next,'bof');
end

return;

end




  
