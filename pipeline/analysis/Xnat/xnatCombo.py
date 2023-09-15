from pyxnat import Interface
import os
import sys

# Description:
# Name: XNAT Session Consolidator
# Version: 1.0
# Date: June 6 2012
# Author: Michael Esparza
# Email: michael.l.esparza@gmail.com

# Check for bad input
if len(sys.argv) != 4:
	print('--------------------------------------------------')
	print('usage: python xnatCombo.py [project] [sessionA] [sessionB]\tCombine sessionB scans with sessionA')
	print('--------------------------------------------------')
	sys.exit(2)

# Name of program, version number, author, date
print('XNAT Session Consolidator v1.0, (Michael Esparza, June 06 2012)')

# Good number of arguments, can continue with the connection to the server
print('Update the interface here')
xnat = Interface('http://10.48.86.212:8080/sulcusdata/xnat','hcpadmin','hcp22')

# Assign variables
project = sys.argv[1]
sessionA = sys.argv[2]
sessionB = sys.argv[3]

# Check that sessions are different
if sessionA == sessionB:
	print('-----------------------------------------------------------------------------------------')
	print('Sessions given are identical, not combining.')
	print('usage: python xnatCombo.py [project] [sessionA] [sessionB]\tCombine sessionB scans with sessionA')
	print('-----------------------------------------------------------------------------------------')
	sys.exit(2)


# Check that project exists
p = xnat.select.projects(project).get('obj')
try:
	p = p[0]
except IndexError:
	print('-----------------------------------------------------------------------------------------')
	print('Project does not exist.' )
	print('Please make sure you typed in the project correctly or that the project exists.')
	print('-----------------------------------------------------------------------------------------')
	sys.exit(2)

print('Project: '+ p.label())

# Get objects from database
sA = p.subjects().experiment(sessionA).get('obj')
sB = p.subjects().experiment(sessionB).get('obj')

# Give default value for a non-None experiment. 
good_sA = sA[0]
good_sB = sB[0]

# Iterate through subjects to find experiments wanted. 
# Otherwise given an list of length "number of subjects" 
# And only one element in it will not be a NoneType.  
for i in range(len(sA)):
	if sA[i].label() is None:
		# Check if None
		pass
	else:
		good_sA = sA[i]
		print('sA: ' + good_sA.label())

# Check that sessionA exists
if good_sA.exists():
	pass
else:
	print('-----------------------------------------------------------------------------------------')
	print('Session', sessionA ,'does not exist.')
	print('Please make sure you typed in the session correctly or that it exists.')
	print('-----------------------------------------------------------------------------------------')
	sys.exit(2)

for j in range(len(sB)):
	if sB[j].label() is None:
		pass
	else:
		good_sB = sB[j]
		print('sB: ' + good_sB.label())

if good_sB.exists():
	pass
else:
	print('-----------------------------------------------------------------------------------------')
	print('Session', sessionB ,'does not exist.') 
	print('Please make sure you typed in the session correctly or that it exists.')
	print('-----------------------------------------------------------------------------------------')
	sys.exit(2)

print('Combining scans from sB:'+ good_sB.label()+ 'with sA:'+ good_sA.label()) 
for s in good_sB.scans().get('obj'):
	sB_scan = s.label()
	sA_scans = [x.label() for x in good_sA.scans().get('obj')]
	print('sB scan: ' + sB_scan)
	print('sA scans: ' + sA_scans)
	if sB_scan in sA_scans:
		print('sB scan found in sA scan list')
		print('No need to copy the scan.')
	else: 
		print('sB scan will be combined with sA scans')	
		new_scan = good_sA.scan(sB_scan)
		new_scan.create()
		for res in s.resources().get('obj'):
			print('Iterating through resources: '+ res)
			new_res = new_scan.resource(res.label())
			new_res.create()
			for f in res.files().get('obj'):
				print('Iterating through files: '+ f)
				tmp = f.get()
				new_f = new_res.file(f.label())
				new_f.put(tmp)
				os.remove(tmp)
	print('--------------------')

print('Deleting'+ good_sB.label())
if good_sB.exists():
	good_sB.delete()
else:
	pass
