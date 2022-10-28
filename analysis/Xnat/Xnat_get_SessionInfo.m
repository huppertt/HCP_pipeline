function tbl = Xnat_get_SessionInfo(jsess)
tbl=[];
try

if(nargin>0)
     [~,msg]=system(['XnatDataClientCerebro -s ' jsess ' -m GET -r http://10.48.86.212:8080/data/archive/experiments/?format=zip']);
else
    [~,msg]=system(['XnatDataClientCerebro -u hcpadmin -p ''hcp22'' -m GET -r http://10.48.86.212:8080/data/archive/experiments/?format=zip']);
end
%now parse the table

rowsS=strfind(msg,'<tr');
rowsE=strfind(msg,'</tr>');

% first one is the header
str=msg(rowsS(1):rowsE(1));
colsS=strfind(str,'<th>');
colsE=strfind(str,'</th>');
for j=1:length(colsS)
    Header{j}=str(colsS(j)+4:colsE(j)-1);
end

T={};
for i=2:length(rowsS)
    str=msg(rowsS(i):rowsE(i));
    colsS=strfind(str,'<td');
    colsE=strfind(str,'</td>');
    for j=1:length(colsS)
        value=str(colsS(j):colsE(j));
        T{i-1,j}=value(5:end-1);
    end  
end

tbl=cell2table(T,'VariableNames',Header);
for i=1:size(T,1)
    SubjID{i,1} = tbl.label{i}(1:min(strfind(tbl.label{i},'_'))-1);
end

tbl=[table(SubjID) tbl];
end