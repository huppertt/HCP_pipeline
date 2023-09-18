function [ mat ] = fiff_read_named_matrix(fid,node,matkind)

%
% [mat] = fiff_read_named_matrix(fid,node)
%
% Read named matrix from the given node
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_read_named_matrix.m,v 1.3 2006/04/23 15:29:40 msh Exp $
%   $Log: fiff_read_named_matrix.m,v $
%   Revision 1.3  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.2  2006/04/20 21:49:38  msh
%   Added mne_read_inverse_operator
%   Changed some of the routines accordingly for more flexibility.
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%

FIFF = fiff_define_constants;

me='MNE:fiff_read_named_matrix';

if nargin ~= 3
    error(me,'Incorrect number of arguments');
end
%
%   Descend one level if necessary
%
found_it=false;
if node.block ~= FIFF.FIFFB_MNE_NAMED_MATRIX
   for k = 1:node.nchild
      if node.children(k).block == FIFF.FIFFB_MNE_NAMED_MATRIX
	 if has_tag(node.children(k),matkind) 
	    node = node.children(k);
	    found_it = true;
	    break;
	 end
      end
   end
   if ~found_it
      error(me,'Desired named matrix (kind = %d) not available',matkind);
   end
else
   if has_tag(node,matkind);
      error(me,'Desired named matrix (kind = %d) not available',matkind);
   end
end
%
%   Read everything we need
%
tag = find_tag(node,FIFF.FIFF_MNE_NROW);
if isempty(tag)
    error(me,'Number of rows not defined');
else
    nrow = tag.data;
end
tag = find_tag(node,FIFF.FIFF_MNE_NCOL);
if isempty(tag)
    error(me,'Number of columns not defined');
else
    ncol = tag.data;
end
tag = find_tag(node,FIFF.FIFF_MNE_ROW_NAMES);
if ~isempty(tag)
    row_names = tag.data;
end
tag = find_tag(node,FIFF.FIFF_MNE_COL_NAMES);
if ~isempty(tag)
    col_names = tag.data;
end
tag = find_tag(node,matkind);
if isempty(tag)
    error(me,'Matrix data missing');
else
    data = tag.data;
end
%
%   Check that we have everything we need
%
if size(data,1) ~= nrow || size(data,2) ~= ncol
    error(me,'The data matrix has wrong size (%d x %d instead of %d x %d)',...
        size(data,1),size(data,2),nrow,ncol);
end
%
%   Put it together
%
mat.nrow = nrow;
mat.ncol = ncol;
if exist('row_names')
    mat.row_names = fiff_split_name_list(row_names);
else
    mat.row_names = [];
end
if exist('col_names')
    mat.col_names = fiff_split_name_list(col_names);
else
    mat.col_names = [];
end
mat.data = data;

return;


    function [tag] = find_tag(node,findkind)

         for p = 1:node.nent
	    if node.dir(p).kind == findkind
	       tag = fiff_read_tag(fid,node.dir(p).pos);
	       return;
           end
        end
        tag = [];
	return;
    end

    function [has] = has_tag(this,findkind)
    
       for p = 1:this.nent
	  if this.dir(p).kind == findkind
	     has = true;
	     return;
	  end
       end
       has = false;
       return;

    end

end




