import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
plt.rcParams['text.latex.preamble']=r'\makeatletter\newcommand{\rncaps}[1]{\MakeUppercase{\romannumeral #1}}'
path  = '/home/xliu/analysis_20131/fit_model/'
#flux = []
#fluxerr = []

MJDref = 58340.50758102
MJDb = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDm = []
MJD = []
for i in range(0,6):
	MJDm.append((MJDb[i]+MJDe[i])/2)
	MJD.append(MJDm[i] - MJDref)

element = (r"Ni {\sc xxvii}",r"Fe {\sc xxvi}",r"Fe {\sc xxv}", r"S {\sc xvi}", r"S {\sc xv}", r"Si {\sc xiv}", r"Si {\sc xiii}r",r"Si {\sc xiii}i",r"Si {\sc xiii}f", r"Mg {\sc xii}")
print(element[0])
df = pd.read_csv('west_flux.csv', header=None)
fluxlist = []
fluxerrlist=[]

fig = plt.figure()
fig.subplots_adjust(hspace=0.3, wspace=0.3)

for i in range(10):
	x = 0
	flux = df.loc[i*6:i*6+6,1] # grab the flux from the data frame
	fluxerr = df.loc[i*6:i*6+6,2] # grab the flux errorfrom the data frame
	ax = fig.add_subplot(5, 2, i+1) # set the axis for plotting
 	f = flux.values.tolist()      #convert data frame to list
 	fe = fluxerr.values.tolist()
 	elm = element[i]
 	for x in range(6):
		ax.errorbar(MJD[x], f[x], fe[x], marker='o', markersize = 2, color = 'red',
		 	ms=5, mew=4, label = elm if x == 0 else "")
		plt.tick_params(axis='x', which='major', labelsize=15)
		plt.tick_params(axis='y', which='major', labelsize=15)
		
		plt.legend(loc='upper center', prop = {'size':15})


plt.text(-1, 0, r" Days since 2018-Aug-10.5076 UTC (MJD 58340.5076)", ha='center', fontsize = 20)			
plt.text(-6.5, 400, r"Flux ($10^{-6}$ ph cm$^{-2}$ s$^{-1}$)", ha='center', va='center', rotation='vertical', fontsize = 20)
#plt.text(-1, 700, r"Flux Changes of Ten Prominent Lines over 2018 Chandra Observations ", ha='center', fontsize = 20)			

plt.show()