load( fullfile(outfolder,'HCP215','T1w','HCP215','dmri','HCP215_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.pass.connectivity.mat'))
DTI1=connectivity;
load( fullfile(outfolder,'HCP215','T1w','HCP215','dmri','HCP215_dsistudio.fib.gz.HCP-MMP_subcort_atlas.count.end.connectivity.mat'))
DTI2=connectivity;
DTI=max(DTI1,DTI2);
load( fullfile(outfolder,'HCP215','MNINonLinear', 'Results', 'HCP215_BOLD_REST_MMP_timecourses.mat'))
BOLD=[];
for i=1:length(tc_data)
  clear b;
  for j=1:372
    b(j,:)=tc_data(i).raw_tc(j).dat;
    b(j,:)=b(j,:)-mean(b(j,:));
    b(j,:)=b(j,:)/std(b(j,:));
  end
  BOLD=[BOLD b];
end
ntps=size(BOLD,2);
nnodes=size(BOLD,1);
ends=[];
[ends(:,1),ends(:,2)]=find(DTI>0);
ends(:,3)=DTI(find(DTI>0));
EndCount=zeros(nnodes);
it=0;
while(it<500000)
  it=it+1;
  i=ends(randi(size(ends,1),1),1);
  time = BOLD(ends(i,1),:);
  fprintf(1,'%d: %d',it,i);
  st=i;
  EndCount(st,st)=EndCount(st,st)+1;
  traj = [];
  while(1)
    lst=find(ends(:,1)==i);
    %ee=[0; ends(lst,3)]; % Uncomment to make tract selection proportional to tract count; 
    ee=[0;ones(length(ends(lst,3)),1)]; %Uncomment to make tract selection equal probability
    ee=cumsum(ee)/sum(ee);
    j=ends(lst(max(find(ee<rand(1)))),2);
    time2=BOLD(j,:);
    cc = (nansum(time.*time2)/(ntps-1));
    Tstat = abs(cc .* sqrt((ntps-2) ./ (1 - cc.^2)));
    p = 2*betainc((ntps-2) ./ ((ntps-2) + Tstat.^2), (ntps-2)/2, 0.5)/2;
    if(rand(1)>(1-p))
      fprintf(1,'\r');
      traj = [traj int16(i)];
      break;
    end
    EndCount(st,j)=EndCount(st,j)+1;
    EndCount(j,st)=EndCount(j,st)+1;
    fprintf(1,'-->%d',j); 
    time=time.*time2;
    time=time-nanmean(time);
    time=time/nanstd(time);
    traj = [traj int16(i)];
    i=j;
  end
  trajectories(it).traj = traj;
end