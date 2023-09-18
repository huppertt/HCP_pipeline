function fiff_list_dir_tree(out,tree,indent)

%
% fiff_list_dir_tree(fid,tree)
%
% List the fiff directory tree structure
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_list_dir_tree.m,v 1.2 2006/04/23 15:29:40 msh Exp $
%   $Log: fiff_list_dir_tree.m,v $
%   Revision 1.2  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.1  2006/04/10 23:26:54  msh
%   Added fiff reading routines
%
%
%


FIFF = fiff_define_constants;

me='MNE:fiff_list_dir_tree';

if nargin == 2
    indent = 0;
end

for k = 1:indent
   fprintf(out,'\t');
end
fprintf(out,'{ %d\n',tree.block);

for k = 1:tree.nent
    if k == 1 
        count = 1;
        print = true;
        for p = 1:indent+1
            fprintf(out,'\t');
        end
        fprintf(out,'tag : %d',tree.dir(k).kind);
    else  
        if tree.dir(k).kind == tree.dir(k-1).kind
            count = count + 1;
        else
            if count > 1
                fprintf(out,' [%d]\n',count);
            else
                fprintf(out,'\n');
            end
            for p = 1:indent+1
                fprintf(out,'\t');
            end
            fprintf(out,'tag : %d',tree.dir(k).kind);
            count = 1;
        end
    end
end
if count > 1
    fprintf(out,' [%d]\n',count);
else
    fprintf(out,'\n');
end

for k = 1:tree.nchild
    fiff_list_dir_tree(out,tree.children(k),indent+1);
end

for k = 1:indent
   fprintf(out,'\t');
end
fprintf(out,'} %d\n',tree.block);


return;

