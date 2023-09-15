% Plot results of tbss & maxfilter  data for QA purposes
% Created on 20190717 by Max Wang

readDir='/media/ghumanlab/Seagate_Expansion_Drive/HCP/';

subjIDs={'HCP201','HCP203','HCP204','HCP205','HCP206','HCP209'};
% subjIDs={'HCP201'};
figure
for mySubj=1:length(subjIDs)
    fheader = ft_read_header([readDir subjIDs{mySubj} '/MEG_REST1/' subjIDs{mySubj} '-MEG_REST1-raw_tsss.fif']);
    data = ft_read_data([readDir subjIDs{mySubj} '/MEG_REST1/' subjIDs{mySubj}  '-MEG_REST1-raw_tsss.fif']);
    
    L=size(data,2);
    Fs=fheader.Fs;
    
    fftTransform=fft(data(randi(size(data,1)),:));
    P2 = abs(fftTransform/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    f = Fs*(0:(L/2))/L;
    [~,ind]=min(abs(f-100));
    
    subplot(ceil(length(subjIDs)/2),2,mySubj)
    plot(f(1000:ind),P1(1000:ind))
    set(gca,'FontSize',20)
    xlabel('f (Hz)','FontSize',25)
    ylabel('Amplitude','FontSize',25)
    title(subjIDs{mySubj},'FontSize',25)
    
%    fheader = ft_read_header([readDir subjIDs{mySubj} '_Ghumanlab/preprocessed/' subjIDs{mySubj} '_rest_raw_tsss_raw.fif']);
%    data = ft_read_data([readDir subjIDs{mySubj} '_Ghumanlab/preprocessed/' subjIDs{mySubj} '_rest_raw_tsss_raw.fif']);
%    
%    L=size(data,2);
%    Fs=fheader.Fs;
%    
%    fftTransform=fft(data(randi(size(data,1)),:));
%    P2 = abs(fftTransform/L);
%    P1 = P2(1:L/2+1);
%    P1(2:end-1) = 2*P1(2:end-1);
%    
%    f = Fs*(0:(L/2))/L;
%    [~,ind]=min(abs(f-100));
%    
%    subplot(length(subjIDs)/2,4,mySubj*2)
%    plot(f(1000:ind),P1(1000:ind))
%    set(gca,'FontSize',20)
%    xlabel('f (Hz)','FontSize',25)
%    ylabel('Amplitude','FontSize',25)
%    title(['' subjIDs{mySubj} '-G'],'FontSize',25)
end
