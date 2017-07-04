from PulsarLogOn import *
import sys
import subprocess
import threading
import os
import glob
import shlex
import fnmatch
import time
import string
import random
import Queue
import commands

#---------------------variable used in the script------------------------------------------------

all_tst=[]      #list of all .tst scripts to be tested
all_tst1=[]		#list of all .tst script where Analysis_id is involved
tmp_tst=[]		#list of all newly created TMP.tst script where Analysis_id is involved 
all_tst2=[]		#list of all .tst script where Analysis_id is not involved and modified TMP.tst scripts where Analysisid is involved
all_out=[]
all_rslt=[]
tst_commands=Queue.LifoQueue()		#Queue of all commands corresponding to each .tst script in all_tst
num_threads=4				#number of processes to be run in parallel by user
tstlog=logdir+"/PulsarTST."+time.strftime("%H:%M:%S")+".log"	#logfile for AUTOTST mode
reflog=logdir+"/PulsarREF."+time.strftime("%H:%M:%S")+".log"	#logfile for AUTOREF mode
base_command="nzsql -d %s -u %s -pw %s -a -f "%(NZ_DATABASE,NZ_USER,NZ_PASSWORD) #stores the base command to execute any .tst script


#---------------------All functions defined in the script-----------------------------------------
def worker():
# function to be called by each thread created to run all commands in tst_command 
        while True:
                current_command=tst_commands.get()						#command dequeued from tst_commands
                temp_logfile=os.tmpfile()							#temporary logfile created for each .tst file
                temp_logfile.write(item[80:]+": 01 :     --- START:"+time.strftime("%H:%M:%S")+"\n")	#logs of current process is added
                temp_logfile.write(item[80:]+": 02 :     --- "+str(threading.current_thread())+"\n")
                temp_process=subprocess.Popen(current_command,stdout=temp_logfile,shell=True)	#new process is initiated to be run in current_thread
                temp_process.wait()								#wait for the process to finish
                temp_logfile.write(item[80:]+": 04 :     --- END:"+time.strftime("%H:%M:%S")+"\n\n")	
                temp_logfile.seek(0)								#move pointer to begin of temp_logfile
                logfile.write(temp_logfile.read())						#appends temp_logfile to logfile
                current_command.task_done()

def create_dir(directory):
# Creates a new directory provided as argument if it does not exist
        if not os.path.exists(directory):
                os.makedirs(directory)
        return os.path.abspath(directory);

def get_command(script_name,flag)
	#return nzsql command to run script_name in mode denoted by flag
	#flag=1 denotes AUTOREF
	#flag=2 denotes AUTOTST
	#flag=3 denotes AUTOPERF
	#flag=4 denotes AUTOCON
	if flag=1:
                rsltfile="REF/"+script_name[:-4].replace("TMP","")+".rslt"
                command=base_commad+file+" > "+rsltfile
	elif flag=2:
                outfile="OUT/"+script_name[:-4].replace("TMP","")+".out"
                command=base_command+file+" > "+outfile+" && "+"./PulsarReport.sh "+outfile
	return command;

get_arguments():
	for 

#------------------------- Testing Starts -------------------------------------------------------

refdir=create_dir("REF")	#create REF directory to store .rslt file
logdir=create_dir("LOG")	#create LOG directory to store .log file
outdir=create_dir("OUT")	#create OUT directory to store .out file

if sys.argv[1]=="--config":
	from myconfig import *
else:
	get_arguments()

#Display error in case user writes UNITEST in place of UNITTEST
if sys.argv[1]=="UNITEST":
	print "'UNITEST' looks like a typo.  Please try 'UNITTEST' with 2 Ts."

#Store all the .tst script to be tested by user in list all_tst
if sys.argv[1]=="TESTCAT":						
	#if category of .tst scripts is provided by user
        category_list=shlex.split(sys.argv[2])						#store each category name of .tst scripts in a list 
        for category in category_list:
		#iterate over each category recursively to retreive all .tst scripts
                for root, dirnames, filenames in os.walk(category):
                        if sys.argv[3]=="AUTOREF":
                                create_dir("REF/"+root)					#create subfolders in REF folder as required
                        elif sys.argv[3]=="AUTOTST":
                                create_dir("OUT/"+root)					#create subfolders in OUT folder as required
                        for filename in fnmatch.filter(filenames, '*.tst'):
                                all_tst.append(os.path.join(root, filename))		#append each .tst script to the list all_tst 
elif sys.argv[1]=="UNITTEST":
	#if list of individual .tst scripts is provided by user
        all_tst=shlext.split(sys.argv[2])						#store each .tst script to the list all_tst

for file in all_tst:
	#iterate over scripts in all_tst to search for scripts involving Analysis_id and store them in list all_tst1
        with open(file,'r') as f:
                for line in f:
                        if "Analysisid" in line:
				#line where Analysid is present in file
                                all_tst1.append(file)
                                break

for file in all_tst1:
	#iterate over each script in all_tst1 to create corresponding TMP.tst file and store in the list tmp_tst 
        random_string=''.join(random.sample(string.lowercase+string.digits,10))	#a random string is created 
        with open(file,"r") as f:
		tmp_file =file[:-4]+"TMP.tst"					#temporary TMP.tst file is created  
                with open(tmp_file, "w") as f1:
			#the content of .tst script is copied to correspondingly created tmp_file with "helloworld" replaced to some random string
                        tmp_tst.append(tmp_file)		#tmp_file is added to list temp_tst
                        count=0					#counter declared to keep track of number of functions involving analysisid
                        for line in f:
                                if "CALL " in line or "EXEC " in line:
                                        count=count+1		#counter is incremented for each occurance of "CALL" or "EXEC" in script
                                if "helloworld" in line:
                                        s1="helloworld"
                                        s2=random_string+`count`
                                        line=line.replace(s1,s2)#replace occurance of "helloworld" with random sting in the line
                                f1.write(line)

all_tst2=list(set(all_tst)-set(all_tst1))		#a new list is created storing .tst scripts where Analysisid is not involved 
all_tst2=list(set(all_tst2)+set(tmp_tst))		#TMP.tst scripts are added to all_tst2
		

if sys.argv[3]=="AUTOREF":
	logfile=open(reflog,"aw")	#sets logfile to reflog 
	for file in all_tst2:
		#enqueue command for each script in list all_tst2 to tst_commands
		tst_commands.put(get_command(file,1))
elif sys.argv[3]=="AUTOTST":
	logfile=open(tstlog,"aw")	#sets logfile to tstlog 
	for file in all_tst2:
		#enqueue command for each script in list all_tst2 to tst_commands
		tst_commands.put(get_command(file,2))

for i in range(num_threads):
	#threads are created to work on running commands in tst_commands
        t = threading.Thread(target=worker)	#a new thread created with function worker() assigned as task to do
        t.daemon = True				#daemon paramater set to TRUE to make sure the thread exits itself on completion
        t.start()				#thread start execution

tst_commands.join()		#block the main threads until the child threads have processed everything that's in the queue tst_commands

for file in tmp_tst:
	#removes the temporary files stored in list tmp_tst
        os.remove(file)








