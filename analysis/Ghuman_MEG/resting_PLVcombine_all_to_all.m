function PLV_out = resting_PLVcombine_all_to_all(brain_data,Fs,freqs)
% Process PLV of electrode pairs
% input:
%   brain_data(2)  -   node x trials x time
%   seed_data(2)   -   trials x time
%   Fs          -   sampling frequency
%   freqs       -   frequency vector
%   label(2)(3)       -   saving file name
% output:
%   PLV_out     -   freq x node x time
%
% Rongye Shi & Matthew Boring, Aug 2016

width=5;

tic

PLV_out=zeros(length(freqs),size(brain_data,1),size(brain_data,1));
for j = 1:length(freqs)

    brain_complex_values=traces2Phases_normalized_all2all(brain_data,freqs(j),Fs,width);
%     brain_complex_values_rnd=traces2Phases_normalized_all2all(brain_data_rnd,freqs(j),Fs,width);
    [p,~] = size(brain_complex_values);
    PLV = zeros(p,p, 'single');
    brain_complex_values=single(brain_complex_values);
    conjBC = single(conj(brain_complex_values));
    
    o=ones(size(brain_complex_values,1),1,'single');
    for seed = 1:size(brain_complex_values,1)
      disp(seed)
      PLV(seed,:)=single(abs(mean((o*brain_complex_values(seed,:)).*conjBC,2)));  
    end
    %{
    If using this PLV matrix structure you save space by converting the
    the lower "triangle" of the matrix (originally zeros or symmetric to
    the upper triangle to the PLVs of the randomly selected trials,
    therefore decreasing the storage space by a factor of 2.
    %}
    disp(['Done ' num2str(freqs(j))]);
    PLV_out(j,:,:) = triu(PLV);
%     PLV_out(j,:,:,:) = PLV;
end
disp(['Finished running Time = ' num2str(toc)]);
