function [PLF,timeVec,freqVec] = traces2Phases_normalized_all2all(S,freqVec,Fs,width)
% function [PLF,timeVec,freqVec] = TFplf(S,freqVec,Fs,width);
%
% Calculates the phase locking factor for multiple frequencies using        
% & channels by applying the Morlet wavelet method.                            
%
% Input
% -----
% S    : signals = time x trials?? time x channels<---
% f    : frequencies over which to calculate spectrogram 
% Fs   : sampling frequency
% width: number of cycles in wavelet (> 5 advisable)  
%
% Output
% ------
% timeVec    : time
% freqVec    : frequency
% PLF    : phase-locking factor = frequency x time
%
%
% Ole Jensen, August 1998

S=single(S); % transform data to singles for computational efficiency

timeVec = (1:size(S,3))/Fs;

B = zeros(size(S)); %will store PLF of channels x time

for i=1:size(S,2)%cycle through trials
    if size(S,1) <  2 % seed based analysis (only one chan)
        sS = reshape(squeeze(S(:,i,:)),[1,size(S,3)]);
        B(:,i,:) = phasevec(freqVec,detrend(sS)',Fs,width);
    else
        B(:,i,:) = phasevec(freqVec,detrend(squeeze(S(:,i,:))')',Fs,width);
    end
end
% fprintf('\n'); 
%B = B/size(S,1);     
B = squeeze(B);

PLF = B;

function y = phasevec(f,s,Fs,width)
% function y = phasevec(f,s,Fs,width)
%
% Return a the phase as a function of time for frequency f. 
% The phase is calculated using Morlet's wavelets. 
%
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)


dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st; % Is this the width of the wavelet in time 0-centered?
... 3.5 comes from sigma_t = 7/f in lachaux?
m = morlet(f,t,width);

y = conv2(s,m); % convolve signal with morlett wave to evelope + phase at
...each timepoint, why is this signal not filtered like in lachaux?


l = find(abs(y) == 0); 
y(l) = 1; %replace 0's in data with 1's to avoid division by zero

y = y./abs(y); %divide by complex modulus to get phase
y(l) = 0;% replace those 1's you added back with zeros
   
y = y(:,ceil(length(m)/2):size(y,2)-floor(length(m)/2)); % "resample" y to 
...ensure similar shape as s?




function y = morlet(f,t,width)
% function y = morlet(f,t,width)
% 
% Morlet's wavelet for frequency f and time t. 
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet. 
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998 

sf = f/width;
st = 1/(2*pi*sf);
A = 1/sqrt(st*sqrt(pi));
y = A*exp(-t.^2/(2*st^2)).*exp(1i*2*pi*f.*t); %G(t,f) in Lachaux et al.
