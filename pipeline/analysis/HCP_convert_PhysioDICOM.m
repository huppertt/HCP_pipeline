function HCP_convert_PhysioDICOM(file)

dcm=dicominfo(file);
a=native2unicode(dcm.Private_7fe1_1010,'UTF-8');
a=textscan(a,'%s');
a=a{1};

cnt=0;
while(cnt<length(a))
    cnt=cnt+1;
    if(~isempty(strfind(a{cnt},'.log')))
        if(isempty(strfind(a{cnt},'Info')))
            filename=a{cnt};
            filename=filename(strfind(filename,'Phys'):end);
            str='';
            str=sprintf('%sUUID = %s',str,a{cnt+2});
            str=sprintf('%s\nScanDate = %s',str,a{cnt+5});
            str=sprintf('%s\nLogVersion = %s',str,a{cnt+8});
            str=sprintf('%s\nLogDataType = %s',str,a{cnt+11});
            str=sprintf('%s\nSampleTime = %s\n',str,a{cnt+14});
            str=sprintf('%s\n%s\t%s\t%s\t%s',str,a{cnt+15},a{cnt+16},a{cnt+17},a{cnt+18});
            cnt=cnt+19;
            while(isempty(find(double(a{cnt})<48)))
                if(~isempty(strfind(a{cnt+3},'_TRIGGER')))
                    str=sprintf('%s\n\t%s\t%s\t%s\t%s',str,a{cnt},a{cnt+1},a{cnt+2},a{cnt+3});
                    disp(sprintf('\t%s\t%s\t%s\t%s',a{cnt},a{cnt+1},a{cnt+2},a{cnt+3}));
                    cnt=cnt+4;
                else
                    str=sprintf('%s\n\t%s\t%s\t%s\t ',str,a{cnt},a{cnt+1},a{cnt+2});
                    disp(sprintf('\t%s\t%s\t%s',a{cnt},a{cnt+1},a{cnt+2}));
                    cnt=cnt+3;
                end
                
            end
            fid=fopen(fullfile(fileparts(file),filename),'w');
            fwrite(fid,str);
            fclose(fid);
            cnt=cnt-1;
        else
    
            str='';
            str=sprintf('%sUUID = %s',str,a{cnt+2});
            str=sprintf('%s\nScanDate = %s',str,a{cnt+5});
            str=sprintf('%s\nLogVersion = %s',str,a{cnt+8});
            str=sprintf('%s\nLogDataType = %s',str,a{cnt+11});
            str=sprintf('%s\nNumSlices = %s',str,a{cnt+14});
            str=sprintf('%s\nNumVolumes = %s',str,a{cnt+17});
            if(~isempty(strfind(a{cnt+18},'NumEchoes')))
                global FilesWeird;
                FilesWeird{end+1}=file;
                str=sprintf('%s\nNumEchoes = %s\n',str,a{cnt+20});
                cnt=cnt+3;
                str=sprintf('%s\n\n%s\t%s\t%s\t%s\t%s',str,a{cnt+18},a{cnt+19},a{cnt+20},a{cnt+21},a{cnt+22});
                cnt=cnt+23;
                while(isempty(strfind(a{cnt},'FirstTime')))
                    str=sprintf('%s\n\t%s\t%s\t%s\t%s\t%s',str,a{cnt},a{cnt+1},a{cnt+2},a{cnt+3},a{cnt+4});
                    disp(sprintf('\t%s\t%s\t%s\t%s\t%s',a{cnt},a{cnt+1},a{cnt+2},a{cnt+3},a{cnt+4}));
                    cnt=cnt+5;
                    
                end
            else
                str=sprintf('%s\n\n%s\t%s\t%s\t%s',str,a{cnt+18},a{cnt+19},a{cnt+20},a{cnt+21});
                cnt=cnt+22;
                while(isempty(strfind(a{cnt},'FirstTime')))
                    str=sprintf('%s\n\t%s\t%s\t%s\t%s',str,a{cnt},a{cnt+1},a{cnt+2},a{cnt+3});
                    disp(sprintf('\t%s\t%s\t%s\t%s',a{cnt},a{cnt+1},a{cnt+2},a{cnt+3}));
                    cnt=cnt+4;
                    
                end
            end
            str=sprintf('%s\n%s = %s',str,a{cnt},a{cnt+2});
            str=sprintf('%s\n%s = %s',str,a{cnt+3},a{cnt+5});
            
            filename=[filename(1:max(strfind(filename,'_'))) 'info.log'];
            
            
            fid=fopen(fullfile(fileparts(file),filename),'w');
            fwrite(fid,str);
            fclose(fid);
        end
    end
end