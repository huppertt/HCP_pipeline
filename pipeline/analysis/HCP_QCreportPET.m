function HCP_QCreportPET(folder,subjid,force);

if(nargin<1 || isempty(folder))
    folder='/disk/HCP/analyzed';
end

if(nargin<3)
    force=false;
end

if(nargin<2|| isempty(subjid))
    subjd=rdir(fullfile(folder,'*','stats','aseg.stats'));
    for i=1:length(subjd)
        subjid=strtok(subjd(i).name(length(folder)+2:end),'/');
        try;
            HCP_QCreportPET(folder,subjid,force);
        catch
            warning(['QC for ' subjid ' failed:' lasterr]);
        end
    end
    return
end

if(exist([folder filesep subjid filesep 'stats' filesep 'PET_' subjid '.pdf']) & ~force)
    disp(['Exists: skipping ' subjid]);
    return
end


curdir=pwd;

rpt = RptgenML.CReport('Description','HCP QC Stage-1 Report');
set(rpt,'Format','pdf-fop','Stylesheet','fo-NoChapterNumbers');

cfr_titlepage = rptgen.cfr_titlepage;
cfr_titlepage.Title=['HCP QC anlysis of ' subjid];
cfr_titlepage.Subtitle=['Analysis run on' datestr(now)];
setParent(cfr_titlepage,rpt);


sMRIrpt=rptgen.cfr_section('SectionTitle','PET');
types={'PET'};
for j=1:length(types)
    cfr_section3(j) = FreeSurfer_Report(folder,subjid,types{j});
    setParent(cfr_section3(j),sMRIrpt);
end
setParent(sMRIrpt,rpt);

% 
% 
% 
% 
% MEGrpt=rptgen.cfr_section('SectionTitle','MEG Data');
% ff=rdir(fullfile(folder,subjid,'MEG*'));
% if(~isempty(ff))
%     cnt=1;
%     types={'raw'};
%     for j=1:length(types)
%         cfr_section2(j) = HCP_QA_report_MEG(folder,subjid,types{j});
%         setParent(cfr_section2(j),MEGrpt);
%     end
%     setParent(MEGrpt,rpt);
% end
% 

try
    
    system(['mkdir -p ' fullfile(folder,subjid,'images')]);
    delete(fullfile(folder,subjid,'images','report.mat'))
    try; save(fullfile(folder,subjid,'images','report.mat'),'rpt'); end;
    cd(fullfile(folder,subjid,'images'));
    tt=report(rpt);
    system(['mv ' tt ' ' folder filesep subjid filesep 'stats' filesep 'PET_' subjid '.pdf']);
end
% 
% system(['mkdir -p /Users/huppert/Desktop/HCPtmp/' subjid]);
% system(['mv /disk/HCP/analyzed/' subjid '/images /Useres/huppert/Desktop/HCPtmp/' subjid]);

cd(curdir);