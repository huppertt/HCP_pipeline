function Xnat_Remove_Bad(subjid,jsess)


tbl2=Xnat_get_SubjectInfo(subjid,jsess);
if(isempty(tbl2))
    return;
end

lst=[];
for i=1:height(tbl2)
    if(isempty(strfind(tbl2.type{i},'/disk')))
        lst=[lst i];
    end
end

% lst=[];
% for i=1:height(tbl2)
%     if(isempty(strfind(tbl2.type{i},'MEG')))
%         lst=[lst i];
%     end
% end
% 




URI={};
for i=1:height(tbl2);
    if(~isempty(strfind(tbl2.series_description{i},'fMRI')) & isempty(strfind(tbl2.series_description{i},'SBRef')))
        disp(tbl2.URI{i});
        tbl3=Xnat_get_ScanInfo(tbl2.URI{i},jsess);
        try
            for j=1:height(tbl3)
                if(~isempty(strfind(tbl3.name{j},'fMRI_REST_')))
                    URI{end+1}=[tbl2.URI{i} '/resources/LINKED_DATA/files/' tbl3.URI{j}];
                end
            end
        end
    end;
end;

for i=1:length(URI)
    system(['XnatDataClientCerebro -s ' jsess '  -m DELETE -r http://10.48.86.212:8080' URI{i}]);
end

tbl2(lst,:)=[];
for i=1:height(tbl2)
    system(['XnatDataClientCerebro -s ' jsess '  -m DELETE -r http://10.48.86.212:8080' tbl2.URI{i}]);
end