function mne_setup_toolbox
%
%  Add the MNE toolbox to the path variable
%
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
% $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/mne_setup_toolbox.m,v 1.6 2006/05/03 18:53:06 msh Exp $
% $Log: mne_setup_toolbox.m,v $
% Revision 1.6  2006/05/03 18:53:06  msh
% Approaching Matlab 6.5 backward compatibility
%
% Revision 1.5  2006/04/23 15:29:41  msh
% Added MGH to the copyright
%
% Revision 1.4  2006/04/21 17:48:42  msh
% Modified setup script and changed the directory of examples.
%
% Revision 1.3  2006/04/17 11:52:15  msh
% Added coil definition stuff
%
% Revision 1.2  2006/04/10 23:26:54  msh
% Added fiff reading routines
%
% Revision 1.1  2005/11/21 05:10:54  msh
% Added the setup routine.
%
%
mne_root=getenv('MNE_ROOT');
if ~isempty(mne_root)
   %
   %   Add the toolbox to path
   %
   mne_toolbox=strcat(mne_root,'/matlab/toolbox');
   if isempty(findstr(path,mne_toolbox))
      path(mne_toolbox,path);
      fprintf('%s added to path\n',mne_toolbox);
   else
      fprintf('%s is already in path\n',mne_toolbox);
   end
   %
   %   Add the examples to path
   %
   mne_examples=strcat(mne_root,'/matlab/examples');
   if isempty(findstr(path,mne_examples))
      path(mne_examples,path);
      fprintf('%s added to path\n',mne_examples);
   else
      fprintf('%s is already in path\n',mne_examples);
   end
   setpref('MNE','MNE_ROOT',mne_root);
else
   fprintf('MNE_ROOT was not set. MNE Matlab tools will not accessible\n');
end
clear mne_root;
