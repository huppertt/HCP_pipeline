% Plots global connectivity over frequency of a single test case for sanity checking
% Created on 20190725 by Max Wang

readDir='/media/ghumanlab/Seagate_Expansion_Drive/HCP/AdjacencyMatrices/';

subjIDs={'HCP201','HCP203','HCP204','HCP205','HCP206','HCP209'};

for mySubj=1:length(subjIDs)
    disp(mySubj)
    subjID=subjIDs{mySubj};
    freqs=1:50;
    globalConns=zeros(length(freqs),1);
    
    for myFreq=1:length(freqs)
%         disp(myFreq)
        load([readDir subjID '/' subjID '-MEG_REST1-prep-native_freq_' num2str(freqs(myFreq),'%02.f') 'Hz.mat']);
        globalConns(myFreq,1)=mean(adjacencyMatrix(:));
    end
    
    subplot(ceil(length(subjIDs)/2),2,mySubj)
    plot(freqs,globalConns)
    set(gca,'FontSize',20)
    xlabel('Freqency (Hz)','FontSize',25)
    ylabel('Average PLV','FontSize',25)
    title(subjID,'FontSize',25)
end