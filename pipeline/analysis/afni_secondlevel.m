function cmd = afni_secondlevel(dset,mask,T1)

lstRm=[];
for idx=1:length(dset)
    try
        if(~isempty(dset{idx}))
            [e,i,i2]=BrikInfo([dset{idx} '.BRIK']);
            stim2{idx}=parsestr(i.BRICK_LABS);
        end
    catch
        lstRm=[lstRm idx];
    end
end

if(~isempty(lstRm))
    for idx=1:length(lstRm)
        warning(['Removing subject: ' dset{lstRm(idx)}]);
    end
    lstkp=[1:length(dset)];
    lstkp(lstRm)=[];
   % stim={stim{lstkp}};
    stim2={stim2{lstkp}};
    T1={T1{lstkp}};
    dset={dset{lstkp}};
    mask={mask{lstkp}};
end


str_mask='3dMean -mask_union -prefix mask';
for idx=1:length(mask)
    str_mask=sprintf('%s ',str_mask,mask{idx});
end
system(str_mask);

str_mask='3dMean -prefix anat_group';
for idx=1:length(T1)
    str_mask=sprintf('%s ',str_mask,T1{idx});
end

system(str_mask);


StimNames={};
for idx=1:length(stim2)
    try
        StimNames={StimNames{:} stim2{idx}{:}};
    end
end
StimNames=unique(StimNames);

str='3dANOVA -DAFNI_FLOATIZE=YES -debug 3';
str=sprintf('%s -levels %d',str,length(StimNames));

HasStim=false(length(StimNames),1);

for idx=1:length(dset)
    for idx2=1:length(StimNames)
        sI=min(find(ismember(stim2{idx},StimNames{idx2})));
        if(~isempty(sI))
            str=sprintf('%s -dset %d %s[%d]',str,idx2,dset{idx},sI-1);
            HasStim(idx2)=true;
        end
    end
    
end

str=sprintf('%s -ftr Fstats',str);

for idx=1:length(StimNames)
    if(HasStim(idx))
    str=sprintf('%s -mean %d %s',str,idx,StimNames{idx});
    end
end

str=sprintf('%s -mask %s -bucket group_results_ANOVA',str,'mask+tlrc');

cmd=str;


function  strs=parsestr(BRICK_LABS);

strs={};

lst=[0 strfind(BRICK_LABS,'~') length(BRICK_LABS)+1];
for idx=1:length(lst)-1
    strs{end+1}=BRICK_LABS(lst(idx)+1:lst(idx+1)-1);
end

return


%     3dANOVA3 -type 5                            \
%         -alevels 2                              \
%         -blevels 3                              \
%         -clevels 2                              \
%         -dset 1 1 1 man1_houses+tlrc            \
%         -dset 1 2 1 man1_faces+tlrc             \
%         -dset 1 3 1 man1_donuts+tlrc            \
%         -dset 1 1 2 man2_houses+tlrc            \
%         -dset 1 2 2 man2_faces+tlrc             \
%         -dset 1 3 2 man2_donuts+tlrc            \
%         -dset 2 1 1 woman1_houses+tlrc          \
%         -dset 2 2 1 woman1_faces+tlrc           \
%         -dset 2 3 1 woman1_donuts+tlrc          \
%         -dset 2 1 2 woman2_houses+tlrc          \
%         -dset 2 2 2 woman2_faces+tlrc           \
%         -dset 2 3 2 woman2_donuts+tlrc          \
%         -adiff   1 2           MvsW             \
%         -bdiff   2 3           FvsD             \
%         -bcontr -0.5 1 -0.5    FvsHD            \
%         -aBcontr 1 -1 : 1      MHvsWH           \
%         -aBdiff  1  2 : 1      same_as_MHvsWH   \
%         -Abcontr 2 : 0 1 -1    WFvsWD           \
%         -Abdiff  2 : 2 3       same_as_WFvsWD   \
%         -Abcontr 2 : 1 7 -4.2  goofy_example    \
%         -bucket donut_anova
% 
% 
%    -type k              : type of ANOVA model to be used:
%                               k=1  fixed effects model  (A and B fixed)    
%                               k=2  random effects model (A and B random)   
%                               k=3  mixed effects model  (A fixed, B random)
% 
%       -alevels a           : a = number of levels of factor A
% 
%       -blevels b           : b = number of levels of factor B
% 
%       -dset 1 1 filename   : data set for level 1 of factor A
%                                       and level 1 of factor B
%             . . .                           . . .
%       -dset i j filename   : data set for level i of factor A
%                                       and level j of factor B
%             . . .                           . . .
%       -dset a b filename   : data set for level a of factor A
%                                       and level b of factor B
% 
%      [-voxel num]          : screen output for voxel # num
% 
%      [-diskspace]          : print out disk space required for
%                              program execution
% 
%      [-mask mset]          : use sub-brick #0 of dataset 'mset'
%                              to define which voxels to process
