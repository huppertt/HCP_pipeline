% Plot FFTs of the STC data for QA purposes
% Created on 20190717 by Max Wang

readDir='/media/ghumanlab/Seagate_Expansion_Drive/HCP/';
% d=dir(readDir);
% isub=[d(:).isdir];
% nameFolds={d(isub).name}';
% nameFolds(ismember(nameFolds,{'.','..'})) = [];

% Subjs=nameFolds;

subjList={'HCP201','HCP203','HCP204','HCP205','HCP206','HCP209'};

for mySubj=1:length(subjList)
%     figure
    restStruct=mne_read_stc_file([readDir subjList{mySubj} '/MEG_REST1/' subjList{mySubj} '-MEG_REST1-prep-native-lh.stc']);
    restData=restStruct.data;
    
    Fs=1/restStruct.tstep;
%     restTime=0:1/Fs:(size(restData,2)/Fs);
%     emptyTime=0:1/Fs:(size(emptyData,2)/Fs);
    
%     plot(restTime(1:end-1),restData(1,:),'r'); hold on
%     plot(emptyTime(1:end-1),emptyData(1,:),'b');
%     xlabel('Time (sec)','FontSize',15)
%     ylabel('Signal','FontSize',15)
    
    L=size(restData,2);
    
    fftTransform=fft(restData(randi(size(restData,1)),:));
    P2 = abs(fftTransform/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    f = Fs*(0:(L/2))/L;
    [~,ind]=min(abs(f-100));
    
    subplot(length(subjList)/2,2,mySubj)
    plot(f(1:ind),P1(1:ind))
    set(gca,'FontSize',20)
    xlabel('f (Hz)','FontSize',25)
    ylabel('Amplitude','FontSize',25)
    title([subjList{mySubj} '-STC Files'],'FontSize',25)
end
