HCP_matlab_setenv;

 [~,jsess]=system('./CreateXnatJess.sh');
    jsess=jsess(end-32:end);
    jsess(double(jsess)==10)=[];
 
tbl=Xnat_get_SessionInfo(jsess);
    
for i=1:height(tbl)
    URI=tbl.URI{i};
    
    system(['XnatDataClientCerebro -r http://10.48.86.212:8080 -s ' jsess ...
        ' -m POST /archive/sevices/refresh/catalog?resource=' URI]);
end
