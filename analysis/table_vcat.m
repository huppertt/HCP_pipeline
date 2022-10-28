function tbl = table_vcat(tbls)
% This function concatinates tables in a safe way to avoid errors of
% mismatched dimensions or data types


lst=[];
for i=1:length(tbls)
    if(~isempty(tbls{i}))
        lst=[lst i];
    end
end
tbls={tbls{lst}};


ntables=length(tbls);
AllNames={};
for i=1:ntables
    Names{i}=tbls{i}.Properties.VariableNames;
    types{i}={};
    for j=1:length(Names{i})
        types{i}{j}=class(tbls{i}.(Names{i}{j}));
    end
    AllNames={AllNames{:} Names{i}{:}};
end
AllNames=unique(AllNames);
for i=1:length(AllNames)
    localtype={}; cnt=1;
    for j=1:ntables
        lst=find(ismember(Names{j},AllNames{i}));
        if(~isempty(lst))
            localtype{cnt}=types{j}{lst};
            cnt=cnt+1;
        end
    end
    if(length(unique(localtype))==1)
        typesAll{i}=unique(localtype);
    else
        typesAll{i}=cellstr('cell');
    end
    
end

for i=1:ntables
    tbls2{i}=table;
    s=struct;
    for j=1:length(AllNames);
         lst=find(ismember(Names{i},AllNames{j}));
         if(~isempty(lst))
            data=tbls{i}.(AllNames{j});
            if(~strcmp(class(data),typesAll{j}))
                data=num2cell(data);
            end
            
         else
           if(strcmp(typesAll{j},'double'))
               data=nan(height(tbls{i}),1);
           elseif(strcmp(typesAll{j},'cell'))
                data=cell(height(tbls{i}),1);
           end
         end
         s=setfield(s,AllNames{j},data);
    end
    tbls2{i}=struct2table(s);
end

if(ntables>0)
    tbl=vertcat(tbls2{:});
else
    tbl=[];
end

