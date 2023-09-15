% Generates adjacency matrices from STC files using Phase-Locking-Values
% Adjacency Matrix Format: All left (2562 voxels) then all right (2562
% voxels)
% Created on 20180619 by Max Wang

MEG_Dir='/media/ghumanlab/Seagate_Expansion_Drive/HCP/'; % where to find the subject folders
taskList={'-MEG_REST1-prep-native'}; % generate adj matrices for all STC files in this list that follow the format of (SubjID)(taskName)(-lh and rh.stc)
subjList={'HCP201','HCP203','HCP204','HCP205','HCP206','HCP209'}; % list of subject IDs to run
numPools=10; % Number of parallel pools to open

for mySubj=1:length(subjList)
    for myTask=1:length(taskList)
        if ~(exist([MEG_Dir 'AdjacencyMatrices/' subjList{mySubj} '/' subjList{mySubj} '_' taskList{myTask} '_freq_56Hz.mat'])==2)
        %if 1==1
        downSample=1; % Can downsample here if necessary, not necessary if the STC files have already been downsampled

		disp(['Starting Subject: ' subjList{mySubj} '; Task: ' taskList{myTask}])
        tic
		
		disp('Loading Left Hemisphere')
		dataStruct=mne_read_stc_file([MEG_Dir subjList{mySubj} '/MEG_REST1/' subjList{mySubj} taskList{myTask} '-lh.stc']);
		Fs=1/dataStruct.tstep;
        Fs=Fs/downSample;
        usedTimes=(Fs*50):downSample:(Fs*110);
        
        timeData=zeros(5124,1,length(usedTimes));
        timeData(1:2562,1,:)=dataStruct.data(1:2562,usedTimes);
		
		clear dataStruct
		disp('Loading Right Hemisphere')
		
		dataStruct=mne_read_stc_file([MEG_Dir subjList{mySubj} '/MEG_REST1/' subjList{mySubj} taskList{myTask} '-rh.stc']);
		timeData(2563:end,1,:)=dataStruct.data(1:2562,usedTimes);
        
        clear dataStruct
        
		freqs=1:50;
		disp('Computing PLVs')
		PLV_out=resting_PLVcombine_all_to_all(timeData(:,1,:),Fs,freqs,numPools);
% 		clear timeData
		
		if ~(exist([MEG_Dir 'AdjacencyMatrices/' subjList{mySubj} '/'])==7)
			mkdir([MEG_Dir 'AdjacencyMatrices/' subjList{mySubj} '/'])
		end

		for myFreq=1:length(freqs)
		    adjacencyMatrix=squeeze(PLV_out(myFreq,:,:));
		    adjacencyMatrix=adjacencyMatrix+adjacencyMatrix.';
		    currentFrequency=freqs(myFreq);
            
		    save([MEG_Dir 'AdjacencyMatrices/' subjList{mySubj} '/' subjList{mySubj} taskList{myTask} '_freq_' num2str(currentFrequency,'%02.f') 'Hz.mat'],'adjacencyMatrix','currentFrequency')
        end
        
        toc
	end
    end
end
