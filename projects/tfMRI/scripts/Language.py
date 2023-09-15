import sys, os

def main():
    
    #catch filename
    openfile = sys.argv[1]
    #check filename for consistency with task
    if openfile.find("LANGUAGE") != -1 or openfile.find("language") != -1:
        #attempt to open for reading
        tabfile = open(openfile, 'r')
        #get the length of the first line to establish # of columns
        num_columns = tabfile.readline()
        #split by tabs to sort into a list
        num_columns = num_columns.split("\t")
        #len of the list is the number of columns
        num_columns_len = len(num_columns)
       
        #save all remaining data to a list
        data = tabfile.readlines()
        
        #get relevant columns
        Proc_Block = [] #14 #index starts at 0
        CB_Block = [] #14 #index starts at 0
        PM_Onset = [] #28
        PM2_Onset = [] #28
        QM_Onset = [] #62
        R_Onset = [] #65
        RO_Onset = [] #65
        RO2_Onset = [] #65
        PS_Onset = [] #37
        QS_Onset = [] #43
        Sync_Onset = []
        Sync_Val = False

        RT = [ [], []]
        ACC = [ [], []]
    
   
        #Auto-detect column numbers
        for i in range(num_columns_len):
                if num_columns[i] == "Procedure[Block]":
                    PB_Index = i
                elif num_columns[i] == "PresentMathFile.OnsetTime":
                    PM_Index = i
                elif num_columns[i] == "ResponsePeriod.OnsetTime":
                    R_Index = i
                elif num_columns[i] == "ResponsePeriod.OffsetTime":
                    RO_Index = i
                elif num_columns[i] == "PresentBlockChange.FinishTime":
                    RO2_Index = i
                elif num_columns[i] == "PresentMathOptions.OnsetTime":
                    QM_Index = i
                elif num_columns[i] == "ExperimenterWindow.OnsetTime[Block]":
                    PM2_Index = i
                elif num_columns[i] == "PresentStoryFile.OnsetTime":
                    PS_Index = i
                elif num_columns[i] == "PresentStoryOption1.OnsetTime":
                    QS_Index = i
                elif num_columns[i] == "GetReady.OffsetTime":
                    SO_Index = i
                elif num_columns[i] == "ChangingBlockTypeTo":
                    CB_Index = i

                
        #create EV text files
        cmd = 'mkdir -p ' + str(sys.argv[2])
        os.system(cmd)
        EV1 = open(str(sys.argv[2]) + '/PresentMath.txt','w')
        EV2 = open(str(sys.argv[2]) + '/ResponseMath.txt','w')
        EV3 = open(str(sys.argv[2]) + '/QuestionMath.txt','w')
        EV4 = open(str(sys.argv[2]) + '/Math.txt','w')
        EV5 = open(str(sys.argv[2]) + '/PresentStory.txt','w')
        EV6 = open(str(sys.argv[2]) + '/ResponseStory.txt','w')
        EV7 = open(str(sys.argv[2]) + '/QuestionStory.txt','w')
        EV8 = open(str(sys.argv[2]) + '/Story.txt','w')
        
        Sync_Txt = open(str(sys.argv[2]) + '/Sync.txt','w')
        Stats = open(str(sys.argv[2]) + '/Stats.txt','w')
    
        for i in range(len(data)): #80
            #split data[i] into list
            tempdata = data[i].split("\t")
            for j in range(len(tempdata)): #
                if j == PB_Index:
                    Proc_Block.append(tempdata[j])
                elif j == PM_Index:
                    PM_Onset.append(tempdata[j])
                elif j == PM2_Index:
                    PM2_Onset.append(tempdata[j])
                elif j == QM_Index:
                    QM_Onset.append(tempdata[j])
                elif j == R_Index:
                    R_Onset.append(tempdata[j])    
                elif j == RO_Index:
                    RO_Onset.append(tempdata[j])
                elif j == RO2_Index:
                    RO2_Onset.append(tempdata[j])       
                elif j == PS_Index:
                    PS_Onset.append(tempdata[j])
                elif j == QS_Index:
                    QS_Onset.append(tempdata[j])
                elif j == SO_Index:
                    Sync_Onset.append(tempdata[j])
                if j == CB_Index:
                    CB_Block.append(tempdata[j])
            
        #Consruct out EV's based on these data
        #set set first index arbitrarily high

        #iterate through all blocks
        
        Sync_Val = int(Sync_Onset[i])/1000.0
        Sync_Txt.write(str(Sync_Val))

        for i in range(len(Proc_Block)):
        
            #check to see if you're in the task
            if Proc_Block[i] == "MathProc":
           
                PresentOnset_sec = int(PM_Onset[i])/1000.0 - Sync_Val
                QuestionOnset_sec = int(QM_Onset[i])/1000.0 - Sync_Val
                ResponseOnset_sec = int(R_Onset[i])/1000.0 - Sync_Val
                ResponseOffset_sec = int(RO_Onset[i])/1000.0 - Sync_Val

                PresDur = QuestionOnset_sec -  PresentOnset_sec
                QuestDur =  ResponseOnset_sec -QuestionOnset_sec
                RespDur = ResponseOffset_sec - ResponseOnset_sec 
                
                RT[0].append(float(Stim_ACC[i]))
                ACC[0].append(float(Stim_ACC[i]))
                
                #write output to EV file
                EV1.write(str(PresentOnset_sec) + "    " + str(PresDur) + "    " + "1"+"\n")
                EV2.write(str(QuestionOnset_sec) + "    " + str(QuestDur) + "    " + "1"+"\n")
                EV3.write(str(ResponseOnset_sec) + "    " + str(RespDur) + "    " + "1"+"\n")
                
            if Proc_Block[i] == "StoryProc":
                
                PresentOnset_sec =  int(PS_Onset[i])/1000.0 - Sync_Val
                QuestionOnset_sec = int(QS_Onset[i])/1000.0 - Sync_Val
                ResponseOnset_sec = int(R_Onset[i])/1000.0 - Sync_Val
                ResponseOffset_sec =int(RO_Onset[i])/1000.0 - Sync_Val

                PresDur = QuestionOnset_sec -  PresentOnset_sec
                QuestDur =  ResponseOnset_sec -QuestionOnset_sec
                RespDur = ResponseOffset_sec - ResponseOnset_sec 
                

                #write output to EV file
                EV5.write(str(PresentOnset_sec) + "    " + str(PresDur) + "    " + "1"+"\n")
                EV6.write(str(QuestionOnset_sec) + "    " + str(QuestDur) + "    " + "1"+"\n")
                EV7.write(str(ResponseOnset_sec) + "    " + str(RespDur) + "    " + "1"+"\n")
                
               
            if Proc_Block[i] == "PresentChangePROC":
                if CB_Block[i] == "Math.wav":
                    
                    PresentOnset_sec = int(PM2_Onset[i])/1000.0 - Sync_Val
                    ResponseOffset_sec = int(RO2_Onset[i])/1000.0 - Sync_Val
                    
                    MathDur = ResponseOffset_sec - PresentOnset_sec
                    
                    EV4.write(str(PresentOnset_sec) + "    " + str(MathDur) + "    " + "1"+"\n")

                elif CB_Block[i] == "Story.wav":
                    
                    PresentOnset_sec = int(PM2_Onset[i])/1000.0 - Sync_Val
                    ResponseOffset_sec = int(RO2_Onset[i])/1000.0 - Sync_Val
                    
                    StoryDur = ResponseOffset_sec - PresentOnset_sec
                    
                    EV8.write(str(PresentOnset_sec) + "    " + str(StoryDur) + "    " + "1"+"\n")
                    
                #manually advance i to ensure no multiples are taken - accounted for by duration
        

   #     try:
   #         RT_median = sum(thing[])/len(thing[])
   #     except ZeroDivisionError:
   #         print("WARNING ZeroDivisionError")
   #         RT_median = -555

   #     try:
   #         ACC_median = sum(thing[])/len(thing[])
   #     except:
   #         print("WARNING ZeroDivisionError")
   #         ACC_median = -555

   #     templist = [RT_median,ACC_median]

    #    for item in templist:
    #        if item == 0:
   #             item = -555

	#	Stats.write("0-Back BP Median ACC: " + str(Zero_ACC_BP_Median)+"\n")
#		Stats.write("0-Back Faces Median ACC: " + str(Zero_ACC_Faces_Median)+"\n")
#		Stats.write("0-Back Places Median ACC: " + str(Zero_ACC_Places_Median)+"\n")
#		Stats.write("0-Back Tools Median ACC: " + str(Zero_ACC_Tools_Median)+"\n")
#		Stats.write("========================\n")
#		Stats.write("2-Back BP Median ACC: " + str(Two_ACC_BP_Median)+"\n")
#		Stats.write("2-Back Faces Median ACC: " + str(Two_ACC_Faces_Median)+"\n")
#		Stats.write("2-Back Places Median ACC: " + str(Two_ACC_Places_Median)+"\n")
#		Stats.write("2-Back Tools Median ACC: " + str(Two_ACC_Tools_Median)+"\n")
#		Stats.write("========================\n")
#		Stats.write("0-Back BP Median RT: " + str(Zero_RT_BP_Median)+"\n")
#		Stats.write("0-Back Faces Median RT: " + str(Zero_RT_Faces_Median)+"\n")
#		Stats.write("0-Back Places Median RT: " + str(Zero_RT_Places_Median)+"\n")
#		Stats.write("0-Back Tools Median RT: " + str(Zero_RT_Tools_Median)+"\n")
#		Stats.write("========================\n")
#		Stats.write("2-Back BP Median RT: " + str(Two_RT_BP_Median)+"\n")
#		Stats.write("2-Back Faces Median RT: " + str(Two_RT_Faces_Median)+"\n")
#		Stats.write("2-Back Places Median RT: " + str(Two_RT_Places_Median)+"\n")
#		Stats.write("2-Back Tools Median RT: " + str(Two_RT_Tools_Median)+"\n")

        EV1.close()
        EV2.close()
        EV3.close()
        EV4.close()
        EV5.close()
        EV6.close()
        EV7.close()
        EV8.close()
        Sync_Txt.close()
        Stats.close()
        
    else:
        print ("File input not consistent with task.")
        
if __name__ == "__main__":
    main()