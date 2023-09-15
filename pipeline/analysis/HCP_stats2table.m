function t=HCP_stats2table(file)

% for PET analysis:
% s=unique(tbl{1}.ROI_name)
% for i=1:length(s); 
%     
%     for j=1:length(tbl); 
%            lst=find(ismember(tbl{j}.ROI_name,{'Left-Cerebellum-Cortex', 'Right-Cerebellum-Cortex'}));
%            n = sum(tbl{j}.PVC_uptake_wrt_Cerebellum(lst).*tbl{j}.Number_PET_Voxels(lst))/sum(tbl{j}.Number_PET_Voxels(lst)); 
%  
%         lst=find(ismember(tbl{j}.ROI_name,s{i}));
%         SUV{j,1+i}=tbl{j}.PVC_uptake_wrt_Cerebellum(lst)/n; 
%         SUV{j,1}=f(j).name(1:min(strfind(f(j).name,'/'))-1); 
%     end;
% end;
% 
% s2{1}='SubjID';
% for i=1:length(s); s2{1+i,1}=s{i}; s2{1+i,1}(strfind(s2{1+i,1},'-'))='_'; end;
% tbl2=cell2table(SUV,'VariableNames',s2)
% 
% s=unique(tbl{1}.ROI_name)
% for i=1:length(s); 
%     
%     for j=1:length(tbl); 
%         lst=find(ismember(tbl{j}.ROI_name,s{i}));
%         SUV2{j,1+i}=tbl{j}.Number_PET_Voxels(lst); 
%         SUV2{j,1}=f(j).name(1:min(strfind(f(j).name,'/'))-1); 
%     end;
% end;
% 
% s2{1}='SubjID';
% for i=1:length(s); s2{1+i,1}=s{i}; s2{1+i,1}(strfind(s2{1+i,1},'-'))='_'; end;
% tbl3=cell2table(SUV2,'VariableNames',s2)

try
    warning('off','MATLAB:table:ModifiedVarnames');
    t=readtable(file,'delimiter','\t');
    if(~isempty(t) & size(t,2)>1)
        return
    end
end
fid=fopen(file,'r'); cnt=1;

if(~isempty(strfind(file,'PiB')) | ~isempty(strfind(file,'gtm')))
    % PET data is different
    hdrs={'row','ROI_idx','ROI_name','Tissue_class','Number_PET_Voxels','variance_reduction_factor','PVC_uptake_wrt_Cerebellum','resdiual_varaince'};
   
else
    
    while(1)
        l=fgetl(fid);
        if(~isempty(strfind(l,'# ColHeaders')))
            break
        end
        cnt=cnt+1;
        if(~isstr(l))
            error('improper stats file');
        end
    end
    l(1)=[];
    hdrs=textscan(l,'%s'); hdrs=hdrs{1}; hdrs={hdrs{2:end}};
end

st='';
for i=1:length(hdrs); st=[st '%s']; end;
c=textscan(fid,st);
fclose(fid);

for i=1:length(c{1})
    if(~isempty(strfind(c{1}{i},'_exvivo')))
       c{1}{i}=c{1}{i}([1:strfind(c{1}{i},'_exvivo')-1 strfind(c{1}{i},'_exvivo')+7:end]);
    end
end

s=struct;
for i=1:length(hdrs)
    
    if(all(cellfun(@(x)isempty(x),cellfun(@(x)str2num(x),c{i},'UniformOutput',false))))
        val=c{i};
    else
        val=cell2mat(cellfun(@(x)str2num(x),c{i},'UniformOutput',false));
    end
    s=setfield(s,hdrs{i},val);
end

t=struct2table(s);