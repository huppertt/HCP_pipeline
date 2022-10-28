function MEG_MakeAdjMtx(subjid,outfolder,files)

if(nargin<2 || isempty(outfolder))
    outfolder='/disk/HCP/analyzed';
end

if(nargin<3)
    f=rdir(fullfile(outfolder,subjid,'MEG*REST*','*-prep-native-lh.stc'));
else
    if(~iscell(files))
        files={files};
    end
    for i=1:length(files)
        f(i).name=files{i};
    end
end

for i=1:length(f)
       p=fileparts(f(i).name);
       
       if (isempty(dir(fullfile(p,'*_50Hz.mat'))) | isempty(dir(fullfile(p,'*_1Hz.mat'))))
        
        disp(['Starting Subject: ' p])
        
        disp('Loading Left Hemisphere')
		
        dataStruct=mne_read_stc_file(f(i).name);
		Fs=1/dataStruct.tstep;
        usedTimes=fix((Fs*50):(Fs*110));
        
        timeData=zeros(5124,1,length(usedTimes));
        timeData(1:2562,1,:)=dataStruct.data(1:2562,usedTimes);
		
		clear dataStruct
		disp('Loading Right Hemisphere')
		
		dataStruct=mne_read_stc_file([f(i).name(1:end-6) 'lh.stc']);
		timeData(2563:end,1,:)=dataStruct.data(1:2562,usedTimes);
        
        clear dataStruct
        
		freqs=1:50;
		disp('Computing PLVs')
		PLV_out=resting_PLVcombine_all_to_all(timeData(:,1,:),Fs,freqs);
% 		clear timeData
		
	
		for myFreq=1:length(freqs)
		    adjacencyMatrix=squeeze(PLV_out(myFreq,:,:));
		    adjacencyMatrix=adjacencyMatrix+adjacencyMatrix.';
		    currentFrequency=freqs(myFreq);
            
		    save([f(i).name(1:end-19) '_freq_' num2str(currentFrequency,'%02.f') 'Hz.mat'],'adjacencyMatrix','currentFrequency')
        end
        
        toc
	end
    end
end
