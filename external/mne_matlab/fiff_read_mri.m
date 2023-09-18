function [stack] = fiff_read_mri(fname)
%
% [stack] = fiff_read_mri(fname)
%
% Read a fif format MRI description file
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_read_mri.m,v 1.1 2006/04/26 19:50:58 msh Exp $
%   $Log: fiff_read_mri.m,v $
%   Revision 1.1  2006/04/26 19:50:58  msh
%   Added fiff_read_mri
%
%
%
FIFF = fiff_define_constants;

FIFFV_MRI_PIXEL_BYTE       = 1;
FIFFV_MRI_PIXEL_WORD       = 2;
FIFFV_MRI_PIXEL_SWAP_WORD  = 3;
FIFFV_MRI_PIXEL_FLOAT      = 4;

me='MNE:fiff_read_mri';

if nargin ~= 1
    error(me,'Incorrect number of arguments');
end
%
%   Try to open the file
%
[ fid, tree ] = fiff_open(fname);
%
%   Locate the data of interest
%   Pick the first MRI set within the first MRI data block
%
mri = fiff_dir_tree_find(tree,FIFF.FIFFB_MRI);
if length(mri) == 0
    fclose(fid);
    error(me,'Could not find MRI data');
end
mri = mri(1);
%
set = fiff_dir_tree_find(mri,FIFF.FIFFB_MRI_SET);
if length(set) == 0
    fclose(fid);
    error(me,'Could not find MRI stack');
end
set = set(1);
%
slices = fiff_dir_tree_find(set,FIFF.FIFFB_MRI_SLICE);
if length(slices) == 0
    fclose(fid);
    error(me,'Could not find MRI slices');
end
%
%   Data ID
%
tag = find_tag(mri,FIFF.FIFF_BLOCK_ID);
if ~isempty(tag)
    stack.id = tag.data;
end
%
%   Head -> MRI coordinate transformation
%
tag = find_tag(set,FIFF.FIFF_COORD_TRANS);
if isempty(tag)
    stack.trans.from  = FIFF.FIFFV_COORD_HEAD;
    stack.trans.to    = FIFF.FIFFV_COORD_MRI;
    stack.trans.trans = eye(4,4);
else
    stack.trans = tag.data;
    if stack.trans.to ~= FIFF.FIFFV_COORD_MRI;
        fclose(fid);
        error(me,'Incorrect coordinate transform found');
    end
end
stack.nslice = length(slices);

fprintf(1,'\tReading slices.');
for k = 1:stack.nslice
    try
        stack.slices(k) = read_slice(slices(k));
    catch
        fclose(fid);
        error(me,'%s',mne_omit_first_line(lasterr));
    end
    if mod(k,50) == 0
        fprintf(1,'.%d.',k);
    end
end
fprintf(1,'.%d..[done]\n',k);

fclose(fid);


return;


    function [slice] = read_slice(node)
        %
        %   Read all components of a single slice
        %   
        tag = find_tag(node,FIFF.FIFF_COORD_TRANS);
        if isempty(tag)
            error(me,'Could not find slice coordinate transformation');
        end
        slice.trans = tag.data;
        if slice.trans.from ~= FIFF.FIFFV_COORD_MRI_SLICE || ...
                slice.trans.to ~= FIFF.FIFFV_COORD_MRI
            error(me,'Illegal slice coordinate transformation');
        end
        %
        %   Change the coordinate transformation so that 
        %   ex is right
        %   ey is down
        %   ez is into the slice
        %
        slice.trans.trans(1:3,2) = -slice.trans.trans(1:3,2);
        slice.trans.trans(1:3,3) = -slice.trans.trans(1:3,3);
        %
        %   Pixel data info
        %
        tag = find_tag(node,FIFF.FIFF_MRI_PIXEL_ENCODING);
        if isempty(tag)
            error(me,'Pixel encoding tag missing');
        end 
        slice.encoding = tag.data;
	%
	%    Offset in the MRI data file if not embedded
	%
        tag = find_tag(node,FIFF.FIFF_MRI_PIXEL_DATA_OFFSET);
        if isempty(tag)
            slice.offset = -1;
        else
            slice.offset = tag.data;
        end
	%
	%    Format of the MRI source file
	%
        tag = find_tag(node,FIFF.FIFF_MRI_SOURCE_FORMAT);
        if isempty(tag)
            slice.source_format = 0;
        else
            slice.source_format = tag.data;
        end
        %
	%   Suggested scaling for the pixel values
	%   (not applied here)
	%
        tag = find_tag(node,FIFF.FIFF_MRI_PIXEL_SCALE);
        if isempty(tag)
            slice.scale = 1.0;
        else
            slice.scale = tag.data;
        end
        %
        %   Width and height in pixels
        %
        tag = find_tag(node,FIFF.FIFF_MRI_WIDTH);
        if isempty(tag)
            error(me,'Slice width missing');
        end 
        slice.width = tag.data;
        %
        tag = find_tag(node,FIFF.FIFF_MRI_HEIGHT);
        if isempty(tag)
            error(me,'Slice height missing');
        end 
        slice.height = tag.data;
        %
        %   Pixel sizes
        %
        tag = find_tag(node,FIFF.FIFF_MRI_WIDTH_M);
        if isempty(tag)
            error(me,'Pixel width missing');
        end 
        slice.pixel_width = double(tag.data)/double(slice.width);
        %
        tag = find_tag(node,FIFF.FIFF_MRI_HEIGHT_M);
        if isempty(tag)
            error(me,'Pixel height missing');
        end 
        slice.pixel_height = double(tag.data)/double(slice.height);
        %
        %   Are the data here or in another file?
        %
        tag = find_tag(node,FIFF.FIFF_MRI_SOURCE_PATH);
        if isempty(tag)
            slice.offset = -1;
            slice.source = [];
            %
            %   Pixel data are embedded in the fif file
            %
            tag = find_tag(node,FIFF.FIFF_MRI_PIXEL_DATA);
            if isempty(tag)
                error(me,'Embedded pixel data missing');
            end
            if tag.type ~= slice.encoding
                error(me,'Embedded data is in wrong format (expected %d, got %d)',...
                        slice.encoding,tag.type);
            end
            if length(tag.data) ~= slice.width*slice.height
                error(me,'Wrong length of pixel data');
            end
            %
            %   Reshape into an image
            %
            slice.data = reshape(tag.data,slice.width,slice.height)';
        else
            if slice.offset < 0
                error(me,'Offset to external file missing');
            end
            slice.source = tag.data;
            %
            %   External slice reading follows
            %
            pname = search_pixel_file(slice.source,fname);
            if isempty(pname)
                error(me,'Could not locate pixel file %s',slice.source);
            else
                try
                    slice.data   = read_external_pixels(pname,...
                        slice.offset,slice.encoding,slice.width,slice.height);
                catch
                    error(me,'%s',mne_omit_first_line(lasterr));
                end
            end
        end
        
    end

    function [name] = search_pixel_file(pname,sname)
        %
        %   First try the file name as it is
        %
        if exist(pname,'file') == 2
            name = pname;
        else
            %
            %   Then <set file dir>/../slices/<slice file name>
            %
            a = findstr(sname,'/');
            if isempty(a)
                d = pwd;
            else
                d = sname(1:a(length(a))-1);
            end
            a = findstr(pname,'/');
            if ~isempty(a)
                pname = pname(a(length(a))+1:length(pname));
            end
            pname = sprintf('%s/../slices/%s',d,pname);
            if exist(pname,'file') == 2
                name = pname;
            else
                name = [];
            end
        end
        return;

    end

    function [pixels] = read_external_pixels(pname,offset,encoding,width,height)
        %
        %   Read pixel data from an external file
        %
        if (encoding == FIFFV_MRI_PIXEL_SWAP_WORD)
            sfid = fopen(pname,'rb','ieee-le');
        else
            sfid = fopen(pname,'rb','ieee-be');
        end
        if sfid < 0
            error(me,'Could not open pixel data file : %s',pname);
        end
        try
            fseek(sfid,double(offset),'bof');
        catch
            error(me,'Could not position to pixel data @ %d',offset);
            fclose(sfid);
        end
        %
        %   Proceed carefully according to the encoding
        %
        switch encoding
            
            case FIFFV_MRI_PIXEL_BYTE
                pixels = fread(sfid,double(width*height),'uint8=>uint8');
            case FIFFV_MRI_PIXEL_WORD
                pixels = fread(sfid,double(width*height),'int16=>int16');
            case FIFFV_MRI_PIXEL_SWAP_WORD
                pixels = fread(sfid,double(width*height),'int16=>int16');
            case FIFFV_MRI_PIXEL_FLOAT
                pixels = fread(sfid,double(width*height),'single=>double');
            otherwise
                fclose(sfid);
                error(me,'Unknown pixel encoding : %d',encoding);
        end
        fclose(sfid);
        %
        %   Reshape into an image
        %
        pixels = reshape(pixels,width,height)';
    end

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

