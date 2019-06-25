import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
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
MJDb= (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDlong = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.76992804)
f, (ax, ax2) = plt.subplot(2, 1, sharex = Ture)
for j in range(0,6):
	MJDa = (MJDb[j]+MJDe[j])/2
	MJD.append(MJDa)
print(MJD)

for name in sorted(files):
	x = x + 1
	with open(name, "r") as f:
		for i, line in enumerate(f):
			if i == 1:
				rs1= float(line.split()[1])
				rserror1 = float(line.split()[2])
			elif i ==2:
				rs2= float(line.split()[1])
				rserror2 = float(line.split()[2])		
		#bax = brokenaxes(xlims=((0.4, 1), (3.5, 4.6)), hspace=.05)
		ax.errorbar(MJD[x], rs1, rserror1, marker='o', color = 'red',
		 ms=5, mew=4)
		ax2.errorbar(MJD[x], rs1, rserror1, marker='o', color = 'red',
		 ms=5, mew=4)
		ax.errorbar(MJD[x], rs2, rserror2, marker='o', color = 'blue', 
			ms=5, mew=4)
		ax2.errorbar(MJD[x], rs2, rserror2, marker='o', color = 'blue', 
			ms=5, mew=4)
		#plt.errorbar(MJD[x], rs1theo[x-1], rstheoerror, marker='s', 
		#	color = 'red', ms=5, mew=4)
		#plt.errorbar(MJD[x], rs2theo[x-1], rstheoerror, marker='s', 
			#color = 'blue', ms=5, mew=4)

ax.fill_between(MJDlong[1:6], [x - rstheoerror for x in rs1theo], 
	[x + rstheoerror for x in rs1theo], color = 'pink')
ax2.fill_between(MJDlong[1:6], [x - rstheoerror for x in rs1theo], 
	[x + rstheoerror for x in rs1theo], color = 'pink')
ax.fill_between(MJDlong[1:6], [x - rstheoerror for x in rs2theo], 
	[x + rstheoerror for x in rs2theo])
ax2.fill_between(MJDlong[1:6], [x - rstheoerror for x in rs2theo], 
	[x + rstheoerror for x in rs2theo])
ax.errorbar(MJD[0], rs1short, rs1shorterror, marker='o', color = 'red', 
	ms=5, mew=4, label = 'Observed redshift of the Western jet')
ax2.errorbar(MJD[0], rs1short, rs1shorterror, marker='o', color = 'red', 
	ms=5, mew=4, label = 'Observed redshift of the Western jet')
ax.errorbar(MJD[0], rs2short, rs2shorterror, marker='o', color = 'blue', 
	ms=5, mew=4, label = 'Observed redshift of the Eastern jet')
ax2.errorbar(MJD[0], rs2short, rs2shorterror, marker='o', color = 'blue', 
	ms=5, mew=4, label = 'Observed redshift of the Eastern jet')
#rect = Rectangle((,yc-ye[0]),xe.sum(),ye.sum()
ax.fill_between((MJDb[0],MJDe[0]), rs1shorttheo - rstheoerror, 
	rs1shorttheo + rstheoerror, color = 'pink', label = 'Theoretical ' 
	'redshift of the Western jet')
ax2.fill_between((MJDb[0],MJDe[0]), rs1shorttheo - rstheoerror, 
	rs1shorttheo + rstheoerror, color = 'pink', label = 'Theoretical ' 
	'redshift of the Western jet')
ax.fill_between((MJDb[0],MJDe[0]), rs2shorttheo - rstheoerror, 
	rs2shorttheo + rstheoerror, color = '#1f77b4', label = 'Theoretical ' 
	'redshift of the Eastern jet')
ax2.fill_between((MJDb[0],MJDe[0]), rs2shorttheo - rstheoerror, 
	rs2shorttheo + rstheoerror, color = '#1f77b4', label = 'Theoretical ' 
	'redshift of the Eastern jet')
ax.set_xlim(.4, 1.)  # outliers only
# ax2.set_xlim(3.5, 4.6)  # most of the data
# ax.spines['right'].set_visible(False)
# ax2.spines['left'].set_visible(False)
# ax.yaxis.tick_left()
# ax.tick_params(labelright='off')
# ax2.yaxis.tick_right()
#plt.errorbar(MJD[0], rs1shorttheo, rstheoerror, marker='s', color = 
#plt.errorbar(MJD[0], rs1shorttheo, rstheoerror, marker='s', color = 'red', 
	#ms=5, mew=4, label = 'Theoretical redshift of the Western jet')
#plt.errorbar(MJD[0], rs2shorttheo, rstheoerror, marker='s', color = 'blue', 
	#ms=5, mew=4, label = 'Theoretical redshift of the Eastern jet')
plt.title('The figure of the observed and theoretical redshifts values' 
	'with error bars of Western and Eastern jets from SS 433')
plt.legend(loc = 2, fontsize = 15)
plt.xlabel("MJD", fontsize = 20)
plt.ylabel("z", fontsize = 20)
plt.tick_params(axis='x', which='major', labelsize=15)
plt.tick_params(axis='y', which='major', labelsize=15)
plt.grid()
plt.show()