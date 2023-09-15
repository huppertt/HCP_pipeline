outfolder='/disk/HCP/analyzed';

% volume stats
asegstats=HCP_statsAll(outfolder,'aseg.stats');
wmstats=HCP_statsAll(pwd,'wmparc.stats');

Tbl2=[asegstats; wmstats];


L{1}='aparc.stats';
L{2}='aparc.DKTatlas40.stats';
L{3}='aparc.a2009s.stats';
L{4}='BA.stats';
L{5}='entorhinal_exvivo.stats';

Tbl=[];
for i=1:length(L)
    t=HCP_statsAll(outfolder,['rh.' L{i}]);
    t=[t table(repmat(cellstr('rh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end
for i=1:length(L)
    t=HCP_statsAll(outfolder,['lh.' L{i}]);
    t=[t table(repmat(cellstr('lh'),height(t),1),'VariableNames',{'Hemisphere'})];
    t=[t table(repmat(cellstr(L{i}),height(t),1),'VariableNames',{'Method'})];
    Tbl=[Tbl; t];
end


tblPET=HCP_statsAll(outfolder,'PiB_SUV.stats');