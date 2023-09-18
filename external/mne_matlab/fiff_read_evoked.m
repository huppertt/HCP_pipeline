function [data] = fiff_read_evoked(fname,setno)
%
% [data] = fiff_read_evoked(fname,setno)
%
% Read one evoked data set
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
%   $Header: /space/orsay/8/users/msh/CVS/CVS-MSH/MNE/mne_matlab/fiff_read_evoked.m,v 1.8 2006/10/14 11:47:32 msh Exp $
%   $Log: fiff_read_evoked.m,v $
%   Revision 1.8  2006/10/14 11:47:32  msh
%   Omitted listing of nepoch from the diagnostic output
%
%   Revision 1.7  2006/09/21 19:27:16  msh
%   fiff_read_evoked did not tolerate missing comment
%
%   Revision 1.6  2006/05/03 19:03:19  msh
%   Eliminated the use of cast function for Matlab 6.5 compatibility
%
%   Revision 1.5  2006/04/23 15:29:40  msh
%   Added MGH to the copyright
%
%   Revision 1.4  2006/04/18 20:44:46  msh
%   Added reading of forward solution.
%   Use length instead of size when appropriate
%
%   Revision 1.3  2006/04/12 13:13:51  msh
%   Added fiff_find_evoked.m
%   Use aspect_kind field name instead of aspect_type
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

me='MNE:fiff_read_evoked';

if nargin == 1
   setno = 1;
elseif nargin ~= 2
   error(me,'Incorrect number of arguments');
end
if setno <= 0
   error(me,'Data set selector must be positive');
end
%
%   Open the file
%
fprintf(1,'Reading %s ...\n',fname);
[ fid, tree ] = fiff_open(fname);
%
%   Read the measurement info
%
[ info, meas ] = fiff_read_meas_info(fid,tree);
%
%   Locate the data of interest
%
processed = fiff_dir_tree_find(meas,FIFF.FIFFB_PROCESSED_DATA);
if length(processed) == 0
    fclose(fid);
    error(me,'Could not find processed data');
end
%
evoked = fiff_dir_tree_find(meas,FIFF.FIFFB_EVOKED);
if length(evoked) == 0
    fclose(fid);
    error(me,'Could not find evoked data');
end
%
%   Identify the aspects
%
naspect = 0;
for k = 1:length(evoked)
    sets(k).aspects  = fiff_dir_tree_find(evoked(k),FIFF.FIFFB_ASPECT);
    sets(k).naspect = length(sets(k).aspects);
    naspect = naspect + sets(k).naspect;
end
fprintf(1,'\t%d evoked data sets containing a total of %d data aspects in %s\n',length(evoked),naspect,fname);
if setno > naspect || setno < 1
    fclose(fid);
    error(me,'Data set selector out of range');
end
%
%   Next locate the evoked data set
%
p = 0;
for k = 1:length(evoked)
    for a = 1:sets(k).naspect
        p = p + 1;
        if p == setno
            my_evoked = evoked(k);
            my_aspect = sets(k).aspects(a);
        end
        if exist('my_evoked')
            break;
        end
    end
    if exist('my_evoked')
        break;
    end
end
%
%   The desired data should have been found but better to check
%
if ~exist('my_evoked') || ~exist('my_aspect')
    fclose(fid);
    error(me,'Desired data set not found');
end
%
%   Now find the data in the evoked block
%
for k = 1:my_evoked.nent
   kind = my_evoked.dir(k).kind;
   pos  = my_evoked.dir(k).pos;
   switch kind
       case FIFF.FIFF_COMMENT
           tag = fiff_read_tag(fid,pos);
           comment = tag.data;
       case FIFF.FIFF_FIRST_SAMPLE
           tag = fiff_read_tag(fid,pos);
           first = tag.data;
       case FIFF.FIFF_LAST_SAMPLE
           tag = fiff_read_tag(fid,pos);
           last = tag.data;
   end
end
if ~exist('comment')
   comment = 'No comment';
end
nsamp = last-first+1;
fprintf(1,'\tFound the data of interest:\n');
fprintf(1,'\t\tt = %10.2f ... %10.2f ms (%s)\n',...
     1000*first/info.sfreq,1000*last/info.sfreq,comment);
if ~isempty(info.comps)
    fprintf(1,'\t\t%d CTF compensation matrices available\n',length(info.comps));
end
%
% Read the data in the aspect block
%
nepoch = 0;
for k = 1:my_aspect.nent
   kind = my_aspect.dir(k).kind;
   pos  = my_aspect.dir(k).pos;
   switch kind
       case FIFF.FIFF_COMMENT
           tag = fiff_read_tag(fid,pos);
           comment = tag.data;
       case FIFF.FIFF_ASPECT_KIND
           tag = fiff_read_tag(fid,pos);
           aspect_kind = tag.data;
       case FIFF.FIFF_NAVE
           tag = fiff_read_tag(fid,pos);
           nave = tag.data;
       case FIFF.FIFF_EPOCH
           nepoch = nepoch + 1;
           tag = fiff_read_tag(fid,pos);
           epoch(nepoch) = tag;
   end
end
if ~exist('nave')
   nave = 1;
end
fprintf(1,'\t\tnave = %d aspect type = %d\n',...
    nave,aspect_kind);
if nepoch ~= 1 && nepoch ~= info.nchan
    fclose(fid);
    error(me,'Number of epochs is unreasonable (%d)',nepoch);
end
%
%   Put the old style epochs together
%
if nepoch == 1
    all = epoch(1).data;
else
    all = epoch(1).data';
    for k = 2:nepoch
        all = [ all ; epoch(k).data' ];
    end
end
if size(all,2) ~= nsamp
    fclose(fid);
    error(me,'Incorrect number of samples (%d instead of %d)',...
        size(all,2),nsamp);
end
%
%   Calibrate
%
for k = 1:info.nchan
    cals(k) = info.chs(k).cal;
end
all = diag(cals)*all;
%
%   Put it all together
%
data.info = info;
data.evoked.aspect_kind = aspect_kind;
if exist('nave')
    data.evoked.nave = nave;
else
    data.evoked.nave  = 1;
end
data.evoked.first = first;
data.evoked.last  = last;
if exist('comment')
    data.evoked.comment = comment;
end
%
%   Times for convenience and the actual epoch data
%
data.evoked.times = double(data.evoked.first:1:data.evoked.last)/data.info.sfreq;
data.evoked.epochs = all;

fclose(fid);

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


