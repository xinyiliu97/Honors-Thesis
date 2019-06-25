import numpy as np
import matplotlib.pyplot as plt
import glob
import math
import pylab
import matplotlib
from matplotlib.ticker import ScalarFormatter, FormatStrFormatter,FuncFormatter
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True

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
flux = np.zeros(shape = (5,8))
fluxerror = np.zeros(shape = (5,8))
x = 0
j = 0

par = (8, 9, 10, 13, 14, 15, 16, 20)
element = ("Si14", "Mg12", "Si13r", "S15", "Ni27", "Fe25", "Fe26", "S16")
MJDstart = 58340.50758102
MJDshortb = 58340.50758102
MJDshortb = MJDshortb - MJDstart
MJDshorte = 58340.75083333
MJDshorte = MJDshorte - MJDstart
MJDshortd = (MJDshorte - MJDshortb)/25
MJD = np.zeros((8,5))
fluxshort = (1.35e-4, 7.57e-5, 1.169e-4, 9.27e-5, 1.47e-4, 0, 1.21e-4, 9.957e-5)
fluxshort = [i*1e5 for i in fluxshort]
fluxshorterror = (1.3e-5,1.26e-5, 1.734e-5, 1.856e-5, 5.75e-5, 1e-5, 3.54e-5,1.81e-5)
fluxshorterror = [i*1e5 for i in fluxshorterror]
MJD1 = np.array([[58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910],]*8).transpose()
MJDb= (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDd = (MJDe[1] - MJDb[1])/10

MJDb = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDlongoffset = []
MJDoffsetb = []
MJDoffsete = []
MJD = MJD1 - MJDstart
print(MJD)

fill = ( "---", None, "////", None, "...", None, "\\\\", None)
#color = (None, None, None, None, None, "grey", "black", None)
color = ("w", "w", "w", "lightsalmon", "w", "grey", "w","red")

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
				flux[j-1][x-1] = float(line.split()[1])*1e5
				fluxerror[j-1][x-1] = float(line.split()[2])*1e5
				#color = cm(1.*x/NUM_COLORS)
				#colorls.append(cm(1.*x/NUM_COLORS))
				#axs[j].errorbar(j, flux[j-1][x-1], fluxerror[j-1][x-1], marker='s', color = 'black', ms=5, mew=4)
#Plot the subgraphs by getting values from the arrays

for x in range(0,8):
	for j in range(0,5):
		axs.set_xlim(3.55 + 58340 - MJDstart, 4.7 + 58340 - MJDstart)
		if j == 0:
			axs.bar(MJD[j][x] + x*MJDd, flux[j][x], width = MJDd, yerr = fluxerror[j][x], edgecolor="red", hatch = fill[x], facecolor = color[x], fill = 1, label = element[x])
			axs2.bar(MJD[j][x] + x*MJDd, flux[j][x], width = MJDd, yerr = fluxerror[j][x], edgecolor="red", hatch = fill[x],facecolor = color[x], fill = 1, label = element[x])
			axs.bar(MJDshortb+x*MJDshortd, fluxshort[x], width = MJDshortd, yerr = fluxshorterror[x], edgecolor="red", hatch = fill[x], facecolor = color[x], fill = 1)
			axs2.bar(MJDshortb+x*MJDshortd, fluxshort[x], width = MJDshortd, yerr = fluxshorterror[x], edgecolor="red", hatch = fill[x], facecolor = color[x], fill = 1)
			# fillstyle = "none", markeredgewidth= 1, color = 'red', ms=5, mew=4)

		else:
			axs.bar(MJD[j][x] + x*MJDd, flux[j][x], width = MJDd, 
				yerr = fluxerror[j][x],hatch = fill[x],edgecolor="red",facecolor = color[x], fill = 1)
			axs2.bar(MJD[j][x] + x*MJDd, flux[j][x],edgecolor="red", width = MJDd , yerr = fluxerror[j][x], hatch = fill[x],facecolor = color[x], fill = 1)

		#axs[x].plot([MJD[0][x],MJD[1][x],MJD[2][x],MJD[3][x],MJD[4][x]],
		 #[flux[0][x], flux[1][x], flux[2][x], flux[3][x], flux[4][x]], 'k-', color = 'red')
	axs.set_xlim(58340.4 - MJDstart, 58340.7 - MJDstart)
	axs2.set_xlim(58343.5 - MJDstart,58344.8 - MJDstart)
	axs.legend(loc = 'top', fontsize = 25)
	#axs.yaxis.set_major_formatter(FixedOrderFormatter(-5))
	#axs[x].yaxis.set_major_formatter(FuncFormatter(lambda x, pos: '%.0f'%x))
	axs2.grid()
#ax = fig.add_subplot(1, 1, 1)
#axs.set_yscale('log')
#locs,labels = yticks()
#yticks(locs, map(lambda x: "%.1f" % x, locs*1e5))
#ylabel('Flux (1E-5)')
# for m in range(0,8):
# 	axs.errorbar(MJDshortb+m*MJDshortd, fluxshort[m], fluxshorterror[m], marker=markers[m], markersize = 10, 
# 		fillstyle = "none", markeredgewidth= 1, color = 'red', ms=5, mew=4)
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
fig.text(.05, .5, r" Line Flux ($10^{-5}$ photons/s/cm$^2$)", ha='center', va='center', rotation='vertical', fontsize = 30)
fig.text(0.5, 0.04, r" Days since 2018-Aug-10.0 UTC (MJD 58340.5076)", ha='center', fontsize = 30)
#fig.suptitle('The figure of the flux change of 8 most notable emission lines from the Western jet'
	#' over short and long observations', fontsize = 15)
axs.tick_params(axis='x', which='major', labelsize=30)
axs2.tick_params(axis='x', which='major', labelsize=30)
axs.tick_params(axis='y', which='major', labelsize=30)
axs2.tick_params(axis='y', which='major', labelsize=30)
plt.show()
