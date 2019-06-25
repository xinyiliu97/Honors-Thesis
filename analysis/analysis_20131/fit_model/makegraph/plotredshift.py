import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path  = '/home/xliu/analysis_20131/fit_model/all_paramvalues*.txt'
files = glob.glob(path)

x = 0
rs1short = 6.78E-03
rs2short = 5.088E-02
rs1shorterror = 3.066E-04
rs2shorterror = 5.414E-04
rs1shorttheo = 0.009234
rs2shorttheo = 0.06791
rs1theo = (-0.009697, -0.0106, -0.011065, -0.01105, -0.01057)
rs2theo = (0.0868, 0.087753, 0.08812, 0.0882, 0.087716)
rstheoerror = 0.009
MJD = []
MJDstart = 58340.50758102
MJDb = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDlongoffset = []
MJDoffsetb = []
MJDoffsete = []
for i in range(0,6):
	MJDoffsetb.append(MJDb[i] - MJDstart)
	MJDoffsete.append(MJDe[i] - MJDstart)
for i in range(0,6):
	if i == 0 or i == 1:
		MJDlongoffset.append(MJDoffsetb[i])
	else:
		MJDlongoffset.append(MJDoffsete[i])
print(MJDoffsetb, MJDoffsete, MJDlongoffset)
#MJDlong = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.76992804)

fig,(ax,ax2) = plt.subplots(1,2,sharey=True, facecolor='w')
for j in range(0,6):
	MJDa = (MJDoffsetb[j]+MJDoffsete[j])/2
	MJD.append(MJDa)
print(MJD)

for name in sorted(files):
	x = x + 1
	with open(name, "r") as f:
		for i, line in enumerate(f):
			if i == 1:
				rs1= float(line.split()[1])
				rserror1 = float(line.split()[2])
				print(rserror1)
			elif i ==2:
				rs2= float(line.split()[1])
				rserror2 = float(line.split()[2])
				print(rserror2)		
		#plot both redshifts for 5 parts with errorbars on two subplots
		ax.errorbar(MJD[x], rs1, rserror1, marker='o', color = 'red',
		 ms=5, mew=4)
		ax2.errorbar(MJD[x], rs1, rserror1, marker='o', color = 'red',
		 ms=5, mew=4)
		ax.errorbar(MJD[x], rs2, rserror2, marker='o', color = 'blue', 
			ms=5, mew=4)
		ax2.errorbar(MJD[x], rs2, rserror2, marker='o', color = 'blue', 
			ms=5, mew=4)
#Plot the theoretical redshifts with shaded areas.
ax.fill_between(MJDlongoffset[1:6], [x - rstheoerror for x in rs1theo], 
	[x + rstheoerror for x in rs1theo], color = 'pink')
ax2.fill_between(MJDlongoffset[1:6], [x - rstheoerror for x in rs1theo], 
	[x + rstheoerror for x in rs1theo], color = 'pink')
ax.fill_between(MJDlongoffset[1:6], [x - rstheoerror for x in rs2theo], 
	[x + rstheoerror for x in rs2theo], color = '#1f77b4')
ax2.fill_between(MJDlongoffset[1:6], [x - rstheoerror for x in rs2theo], 
	[x + rstheoerror for x in rs2theo], color = '#1f77b4')
#Plot the short observation's observed and theoretical redshifts
ax.errorbar(MJD[0], rs1short, rs1shorterror, marker='o', color = 'red', 
	ms=5, mew=4, label = 'Observed redshift of the Western jet')
ax2.errorbar(MJD[0], rs1short, rs1shorterror, marker='o', color = 'red', 
	ms=5, mew=4, label = 'Observed redshift of the Western jet')
ax.errorbar(MJD[0], rs2short, rs2shorterror, marker='o', color = 'blue', 
	ms=5, mew=4, label = 'Observed redshift of the Eastern jet')
ax2.errorbar(MJD[0], rs2short, rs2shorterror, marker='o', color = 'blue', 
	ms=5, mew=4, label = 'Observed redshift of the Eastern jet')
ax.fill_between((MJDoffsetb[0],MJDoffsete[0]), rs1shorttheo - rstheoerror, 
	rs1shorttheo + rstheoerror, color = 'pink', label = 'Predicted ' 
	'redshift of the Western jet')
ax2.fill_between((MJDoffsetb[0],MJDoffsete[0]), rs1shorttheo - rstheoerror, 
	rs1shorttheo + rstheoerror, color = 'pink', label = 'Predicted ' 
	'redshift of the Western jet')
ax.fill_between((MJDoffsetb[0],MJDoffsete[0]), rs2shorttheo - rstheoerror, 
	rs2shorttheo + rstheoerror, color = '#1f77b4', label = 'Predicted ' 
	'redshift of the Eastern jet')
ax2.fill_between((MJDoffsetb[0],MJDoffsete[0]), rs2shorttheo - rstheoerror, 
	rs2shorttheo + rstheoerror, color = '#1f77b4', label = 'Predicted ' 
	'redshift of the Eastern jet')

#plt.errorbar(MJD[0], rs1shorttheo, rstheoerror, marker='s', color = 
#plt.errorbar(MJD[0], rs1shorttheo, rstheoerror, marker='s', color = 'red', 
	#ms=5, mew=4, label = 'Theoretical redshift of the Western jet')
#plt.errorbar(MJD[0], rs2shorttheo, rstheoerror, marker='s', color = 'blue', 
	#ms=5, mew=4, label = 'Theoretical redshift of the Eastern jet')
ax.set_xlim(58340.5 - MJDstart,58341 - MJDstart)
ax2.set_xlim(58343.5 - MJDstart,58344.8 - MJDstart)

# hide the spines between ax and ax2
ax.spines['right'].set_visible(False)
ax2.spines['left'].set_visible(False)
ax.yaxis.tick_left()
ax.tick_params(labelright='off')
ax2.yaxis.tick_right()
plt.subplots_adjust(wspace=0.05)
d = .015 # how big to make the diagonal lines in axes coordinates
# arguments to pass plot, just so we don't keep repeating them
kwargs = dict(transform=ax.transAxes, color='k', clip_on=False)
ax.plot((1-d,1+d),(-d,+d), **kwargs) # top-left diagonal
ax.plot((1-d,1+d),(1-d,1+d), **kwargs) # bottom-left diagonal

kwargs.update(transform=ax2.transAxes) # switch to the bottom axes
ax2.plot((-d,d),(-d,+d), **kwargs) # top-right diagonal
ax2.plot((-d,d),(1-d,1+d), **kwargs) # bottom-right diagonal

#fig.suptitle('The figure of the observed and theoretical redshifts values ' 
	#'with error bars of Western and Eastern jets from SS 433', fontsize = 15)
size = 30
ax2.legend(loc = 'center left', fontsize = 25, bbox_to_anchor=(0.7,0.5))
fig.text(.05, .5, r"Redshift", ha='center', va='center', rotation='vertical', fontsize = size)
fig.text(0.5, 0.02, r" Days since 2018-Aug-10.5076 UTC (MJD 58340.5076)", ha='center', fontsize = size)
#fig.suptitle('The figure of the flux change of 2 emission lines from the Eastern jet'
#	' over short and long observations', fontsize = 15)
ax.tick_params(axis='x', which='major', labelsize=size)
ax2.tick_params(axis='x', which='major', labelsize=size)
ax.tick_params(axis='y', which='major', labelsize=size)
ax2.tick_params(axis='y', which='major', labelsize=size)
ax.grid()
ax.grid()
plt.show()