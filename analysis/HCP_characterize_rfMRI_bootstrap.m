outfolder = '/disk/HCP/analyzed';
load(fullfile(outfolder,'HCP_table_final.mat'))

subjid_MCI = {'HCP215'	'HCP216'	'HCP246'	'HCP247'	'HCP252'	'HCP264'	'HCP281'	'HCP292'	'HCP293'	'HCP294'	'HCP296'	'HCP297'	'HCP298'	'HCP303'	'HCP304'	'HCP305'	'HCP306'	'HCP309'	'HCP310'	'HCP319'	'HCP325'	'HCP327'	'HCP328'	'HCP340'	'HCP345'	'HCP349'	'HCP351'	'HCP354'	'HCP355'	'HCP358'	'HCP359'	'HCP365'	'HCP368'	'HCP369'	'HCP373'	'HCP382'	'HCP383'	'HCP391'	'HCP393'	'HCP400'	'HCP405'	'HCP406'	'HCP407'	'HCP409'	'HCP411'	'HCP412'	'HCP414'	'HCP425'	'HCP426'	'HCP429'	'HCP439'	'HCP446'	'HCP449'	'HCP454'	'HCP458'	'HCP460'	'HCP462'	'HCP467'	'HCP468'	'HCP469'	'HCP476'	'HCP477'	'HCP478'	'HCP481'	'HCP482'	'HCP484'	'HCP485'	'HCP486'	'HCP487'	'HCP490'	'HCP494'	'HCP513'	'HCP518'	'HCP523'	'HCP524'	'HCP525'	'HCP526'	'HCP529'	'HCP530'	'HCP531'};
subjid_MCI_AD = {'HCP215'	'HCP216'	'HCP246'	'HCP247'	'HCP252'	'HCP264'	'HCP280'	'HCP281'	'HCP282'	'HCP292'	'HCP293'	'HCP294'	'HCP296'	'HCP297'	'HCP298'	'HCP303'	'HCP304'	'HCP305'	'HCP306'	'HCP309'	'HCP310'	'HCP319'	'HCP325'	'HCP327'	'HCP328'	'HCP337'	'HCP340'	'HCP345'	'HCP349'	'HCP351'	'HCP354'	'HCP355'	'HCP356'	'HCP358'	'HCP359'	'HCP363'	'HCP365'	'HCP368'	'HCP369'	'HCP373'	'HCP382'	'HCP383'	'HCP391'	'HCP393'	'HCP400'	'HCP404'	'HCP405'	'HCP406'	'HCP407'	'HCP409'	'HCP411'	'HCP412'	'HCP414'	'HCP425'	'HCP426'	'HCP428'	'HCP429'	'HCP439'	'HCP446'	'HCP449'	'HCP454'	'HCP458'	'HCP460'	'HCP462'	'HCP467'	'HCP468'	'HCP469'	'HCP476'	'HCP477'	'HCP478'	'HCP481'	'HCP482'	'HCP484'	'HCP485'	'HCP486'	'HCP487'	'HCP490'	'HCP494'	'HCP513'	'HCP518'	'HCP523'	'HCP524'	'HCP525'	'HCP526'	'HCP529'	'HCP530'	'HCP531'};
subjid_CI = {'HCP205'	'HCP206'	'HCP208'	'HCP209'	'HCP212'	'HCP213'	'HCP218'	'HCP222'	'HCP224'	'HCP225'	'HCP226'	'HCP227'	'HCP229'	'HCP230'	'HCP231'	'HCP235'	'HCP236'	'HCP242'	'HCP243'	'HCP244'	'HCP248'	'HCP250'	'HCP251'	'HCP253'	'HCP256'	'HCP258'	'HCP259'	'HCP263'	'HCP265'	'HCP266'	'HCP267'	'HCP268'	'HCP270'	'HCP271'	'HCP273'	'HCP275'	'HCP276'	'HCP279'	'HCP283'	'HCP284'	'HCP285'	'HCP286'	'HCP288'	'HCP289'	'HCP290'	'HCP299'	'HCP302'	'HCP307'	'HCP308'	'HCP315'	'HCP329'	'HCP332'	'HCP334'	'HCP336'	'HCP341'	'HCP343'	'HCP350'	'HCP357'	'HCP360'	'HCP362'	'HCP364'	'HCP366'	'HCP367'	'HCP370'	'HCP372'	'HCP379'	'HCP384'	'HCP387'	'HCP390'	'HCP394'	'HCP399'	'HCP415'	'HCP417'	'HCP418'	'HCP419'	'HCP420'	'HCP421'	'HCP422'	'HCP423'	'HCP424'	'HCP427'	'HCP432'	'HCP437'	'HCP438'	'HCP442'	'HCP447'	'HCP450'	'HCP451'	'HCP453'	'HCP455'	'HCP456'	'HCP457'	'HCP461'	'HCP465'	'HCP466'	'HCP470'	'HCP473'	'HCP475'	'HCP491'	'HCP495'	'HCP498'	'HCP501'	'HCP502'	'HCP503'	'HCP505'	'HCP507'	'HCP510'	'HCP511'	'HCP512'	'HCP515'	'HCP516'	'HCP517'	'HCP520'	'HCP522'};

nboot = 10000;
rng('default');
rng(0);

% Generate reduced-size master table for each sample of interest
mastertable = tbl_final(:,[1:6 21]);
clear tbl_final;

mastertable_MCI = mastertable;
idx = ismember(mastertable_MCI.subject, subjid_MCI);
mastertable_MCI(~idx,:) = [];

mastertable_MCI_AD = mastertable;
idx = ismember(mastertable_MCI_AD.subject, subjid_MCI_AD);
mastertable_MCI_AD(~idx,:) = [];

mastertable_CI = mastertable;
idx = ismember(mastertable_CI.subject, subjid_CI);
mastertable_CI(~idx,:) = [];

subjects = unique(mastertable.subject);
categories = unique(mastertable.net);

% Generate bootstrap sample
[~,bootsamp]=bootstrp(nboot,[],1:length(subjects));

mdls_boot = struct;
for i = 1:nboot
    mdls_boot(i).betas = nan(length(categories),3);
end

%% This section computes bootstrap for whole sample
parfor i = 1:nboot
    tic;
    disp(['Running whole-sample bootstrap ' num2str(i) ' of ' num2str(nboot)])
    % Generate bootstrap sample table
    boottable = table;
    for j = 1:size(bootsamp,1)
        boottable = [boottable ; mastertable(mastertable.subject==subjects(bootsamp(j,i)),:) ];
    end
    % mdls_boot(i).bootsamp = subjects(bootsamp(:,i));
    % Compute network models
    betas = nan(91,3);
    for j = 1:length(categories)
        tbl_net = boottable(boottable.net==categories(j),:);
        tbl_net.rDTI_free = tiedrank(tbl_net.DTI_free);
        tbl_net.rDTI_WMH = tiedrank(tbl_net.DTI_WMH);
        tbl_net.rFC = tiedrank(tbl_net.abs_zF_res_AR);
        mdl = fitlme(tbl_net,'rFC~1+rDTI_free+rDTI_WMH');
        betas(j,:) = [mdl.Coefficients.Estimate]';
    end
    mdls_boot(i).betas = betas;
    disp(['Time to complete bootstrap iteration: ' num2str(toc)]);
end

save( fullfile(outfolder,'HCP_bootstrap_full_sample.mat'), 'mdls_boot' , 'bootsamp' , '-v7.3')
clear mdls_boot bootsamp mastertable;

%% Compute boostrap for MCI sample
subjects = unique(mastertable_MCI.subject);
categories = unique(mastertable_MCI.net);

% Generate bootstrap sample
[~,bootsamp]=bootstrp(nboot,[],1:length(subjects));

mdls_boot = struct;
for i = 1:nboot
    mdls_boot(i).betas = nan(length(categories),3);
end

parfor i = 1:nboot
    tic;
    disp(['Running MCI bootstrap ' num2str(i) ' of ' num2str(nboot)])
    % Generate bootstrap sample table
    boottable = table;
    for j = 1:size(bootsamp,1)
        boottable = [boottable ; mastertable_MCI(mastertable_MCI.subject==subjects(bootsamp(j,i)),:) ];
    end
    % mdls_boot(i).bootsamp = subjects(bootsamp(:,i));
    % Compute network models
    betas = nan(91,3);
    for j = 1:length(categories)
        tbl_net = boottable(boottable.net==categories(j),:);
        tbl_net.rDTI_free = tiedrank(tbl_net.DTI_free);
        tbl_net.rDTI_WMH = tiedrank(tbl_net.DTI_WMH);
        tbl_net.rFC = tiedrank(tbl_net.abs_zF_res_AR);
        mdl = fitlme(tbl_net,'rFC~1+rDTI_free+rDTI_WMH');
        betas(j,:) = [mdl.Coefficients.Estimate]';
    end
    mdls_boot(i).betas = betas;
    disp(['Time to complete bootstrap iteration: ' num2str(toc)]);
end

save( fullfile(outfolder,'HCP_bootstrap_MCI_sample.mat'), 'mdls_boot' , 'bootsamp' , '-v7.3')
clear mdls_boot bootsamp mastertable_MCI;

%% Compute boostrap for MCI_AD sample
subjects = unique(mastertable_MCI_AD.subject);
categories = unique(mastertable_MCI_AD.net);

% Generate bootstrap sample
[~,bootsamp]=bootstrp(nboot,[],1:length(subjects));

mdls_boot = struct;
for i = 1:nboot
    mdls_boot(i).betas = nan(length(categories),3);
end

parfor i = 1:nboot
    tic;
    disp(['Running MCI w/AD bootstrap ' num2str(i) ' of ' num2str(nboot)])
    % Generate bootstrap sample table
    boottable = table;
    for j = 1:size(bootsamp,1)
        boottable = [boottable ; mastertable_MCI_AD(mastertable_MCI_AD.subject==subjects(bootsamp(j,i)),:) ];
    end
    % mdls_boot(i).bootsamp = subjects(bootsamp(:,i));
    % Compute network models
    betas = nan(91,3);
    for j = 1:length(categories)
        tbl_net = boottable(boottable.net==categories(j),:);
        tbl_net.rDTI_free = tiedrank(tbl_net.DTI_free);
        tbl_net.rDTI_WMH = tiedrank(tbl_net.DTI_WMH);
        tbl_net.rFC = tiedrank(tbl_net.abs_zF_res_AR);
        mdl = fitlme(tbl_net,'rFC~1+rDTI_free+rDTI_WMH');
        betas(j,:) = [mdl.Coefficients.Estimate]';
    end
    mdls_boot(i).betas = betas;
    disp(['Time to complete bootstrap iteration: ' num2str(toc)]);
end

save( fullfile(outfolder,'HCP_bootstrap_MCI_AD_sample.mat'), 'mdls_boot' , 'bootsamp' , '-v7.3')
clear mdls_boot bootsamp mastertable_MCI_AD;

%% Compute boostrap for CI sample
subjects = unique(mastertable_CI.subject);
categories = unique(mastertable_CI.net);

% Generate bootstrap sample
[~,bootsamp]=bootstrp(nboot,[],1:length(subjects));

mdls_boot = struct;
for i = 1:nboot
    mdls_boot(i).betas = nan(length(categories),3);
end

parfor i = 1:nboot
    tic;
    disp(['Running CI bootstrap ' num2str(i) ' of ' num2str(nboot)])
    % Generate bootstrap sample table
    boottable = table;
    for j = 1:size(bootsamp,1)
        boottable = [boottable ; mastertable_CI(mastertable_CI.subject==subjects(bootsamp(j,i)),:) ];
    end
    % mdls_boot(i).bootsamp = subjects(bootsamp(:,i));
    % Compute network models
    betas = nan(91,3);
    for j = 1:length(categories)
        tbl_net = boottable(boottable.net==categories(j),:);
        tbl_net.rDTI_free = tiedrank(tbl_net.DTI_free);
        tbl_net.rDTI_WMH = tiedrank(tbl_net.DTI_WMH);
        tbl_net.rFC = tiedrank(tbl_net.abs_zF_res_AR);
        mdl = fitlme(tbl_net,'rFC~1+rDTI_free+rDTI_WMH');
        betas(j,:) = [mdl.Coefficients.Estimate]';
    end
    mdls_boot(i).betas = betas;
    disp(['Time to complete bootstrap iteration: ' num2str(toc)]);
end

save( fullfile(outfolder,'HCP_bootstrap_CI_sample.mat'), 'mdls_boot' , 'bootsamp' , '-v7.3')
clear mdls_boot bootsamp mastertable_CI;
