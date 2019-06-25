import numpy as np
import matplotlib.pyplot as plt
import glob
import math
import pylab
import matplotlib
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter,FuncFormatter
#----------------------------------------------------------------------
class FixedOrderFormatter(ScalarFormatter):
    """Formats axis ticks using scientific notation with a constant order of 
    magnitude"""
    def __init__(self, order_of_mag=0, useOffset=True, useMathText=False):
        self._order_of_mag = order_of_mag
        ScalarFormatter.__init__(self, useOffset=useOffset, 
                                 useMathText=useMathText)
    def _set_orderOfMagnitude(self, range):
        """Over-riding this to avoid having orderOfMagnitude reset elsewhere"""
        self.orderOfMagnitude = self._order_of_mag
#-------------------------------------------------------------------------

path  = '/home/xliu/analysis_20131/fit_model/all_paramvalues*.txt'
files = glob.glob(path)
flux = np.zeros(shape = (5,4))
fluxerror = np.zeros(shape = (5,4))
x = 0
j = 0
colorls = []
NUM_COLORS = 13
cm = plt.get_cmap('gist_rainbow')
par = (21, 24)
element = ("Si13", "Si14","Fe25", "Fe26")
MJDshortb = 58340.50758102
MJDshorte = 58340.75083333
MJDshortd = (MJDshorte - MJDshortb)/25
fluxshort = (2.16e-5, 6.18e-5, 4.364e-4, 7.772e-4)
fluxshorterror = (9.62e-6, 1.128e-5, 4.136e-5, 2.66e-4)
MJD = np.array([[58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910],]*12).transpose()
MJDb= (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDd = (MJDe[1] - MJDb[1])/15
print(MJDd)
markers = ( "v", "X", "1", "p", "s", "<","d",".")

fig,(axs,axs2) = plt.subplots(1,2,sharey=True, facecolor='w')

#fig.subplots_adjust(hspace = 0.1)
#Save the values of fluxes and flux errors in the arrays.
for name in sorted(files):
	x = 0
	j = j + 1
	with open(name, 'r') as f:
		for i, line in enumerate(f):
			if i in par:
				x = x + 1
				flux[j-1][x-1] = float(line.split()[1])
				fluxerror[j-1][x-1] = float(line.split()[2])
				flux[j-1][2] = 0
				flux[j-1][3] = 0
				color = cm(1.*x/NUM_COLORS)
				colorls.append(cm(1.*x/NUM_COLORS))
				#axs[j].errorbar(j, flux[j-1][x-1], fluxerror[j-1][x-1], marker='s', color = 'black', ms=5, mew=4)
#Plot the subgraphs by getting values from the arrays

for x in range(0,4):
	for j in range(0,5):
		axs.set_xlim(3.55 + 58340, 4.7 + 58340)
		if j == 0:
			axs.errorbar(MJD[j][x]+x*MJDd, flux[j][x], fluxerror[j][x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4, label = element[x])
			axs2.errorbar(MJD[j][x]+x*MJDd, flux[j][x], fluxerror[j][x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4, label = element[x])
			axs.errorbar(MJDshortb+x*MJDshortd, fluxshort[x], fluxshorterror[x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4)
			axs2.errorbar(MJDshortb+x*MJDshortd, fluxshort[x], fluxshorterror[x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4)

		else:
			axs.errorbar(MJD[j][x]+x*MJDd, flux[j][x], fluxerror[j][x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4)
			axs2.errorbar(MJD[j][x]+x*MJDd, flux[j][x], fluxerror[j][x], marker=markers[x], markersize = 10, 
			fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4)

		#axs[x].plot([MJD[0][x],MJD[1][x],MJD[2][x],MJD[3][x],MJD[4][x]],
		 #[flux[0][x], flux[1][x], flux[2][x], flux[3][x], flux[4][x]], 'k-', color = 'blue')
	axs.set_xlim(58340.4,58340.7)
	axs2.set_xlim(58343.5,58344.8)
	axs2.legend()
	axs.yaxis.set_major_formatter(FixedOrderFormatter(-5))
	#axs[x].yaxis.set_major_formatter(FuncFormatter(lambda x, pos: '%.0f'%x))
	axs2.grid()
#ax = fig.add_subplot(1, 1, 1)
#axs.set_yscale('log')
#locs,labels = yticks()
#yticks(locs, map(lambda x: "%.1f" % x, locs*1e5))
#ylabel('Flux (1E-5)')
# for m in range(0,8):
# 	axs.errorbar(MJDshortb+m*MJDshortd, fluxshort[m], fluxshorterror[m], marker=markers[m], markersize = 10, 
# 		fillstyle = "none", markeredgewidth= 1, color = 'blue', ms=5, mew=4)
# hide the spines between ax and ax2
axs.spines['right'].set_visible(False)
axs2.spines['left'].set_visible(False)
axs.yaxis.tick_left()
axs.tick_params(labelright='off')
axs2.yaxis.tick_right()
plt.subplots_adjust(wspace=0.05)
d = .015 # how big to make the diagonal lines in axes coordinates
# arguments to pass plot, just so we don't keep repeating them
kwargs = dict(transform=axs.transAxes, color='k', clip_on=False)
axs.plot((1-d,1+d),(-d,+d), **kwargs) # top-left diagonal
axs.plot((1-d,1+d),(1-d,1+d), **kwargs) # bottom-left diagonal

kwargs.update(transform=axs2.transAxes) # switch to the bottom axes
axs2.plot((-d,d),(-d,+d), **kwargs) # top-right diagonal
axs2.plot((-d,d),(1-d,1+d), **kwargs) # bottom-right diagonal
fig.text(.05, .5, 'Line Flux (photons/s/cm^2)', ha='center', va='center', rotation='vertical', fontsize = 20)
fig.text(0.5, 0.04, 'MJD', ha='center', fontsize = 20)
fig.suptitle('The figure of the flux change of 4 emission lines from the Eastern jet'
	' over short and long observations', fontsize = 15)
plt.show()
