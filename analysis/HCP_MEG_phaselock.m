function PLV = MEG_phaselock(filename)

freal=filename;
fimag=filename;
freal([strfind(freal,'real') strfind(freal,'imag')]+[0:3])='real';
fimag([strfind(fimag,'real') strfind(fimag,'imag')]+[0:3])='imag';

areal=ft_read_cifti(freal);
aimag=ft_read_cifti(fimag);

y=angle(areal.dtseries+(1i)*aimag.dtseries);

PLV=zeros(size(y,1));
for i=1:size(y,1)
    disp(i)
    for j=i+1:size(y,1)
        PLV(i,j)=abs(sum(exp(1i*(y(i,:)-y(j,:)))))/size(y,1);
    end
end

[p,f,e]=fileparts(filename);
fileout=fullfile(p,[f '-conn.mat']);
save(fileout,'PLV');

return
