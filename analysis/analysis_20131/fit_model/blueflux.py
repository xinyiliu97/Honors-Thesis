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
NUM_COLORS = 4
cm = plt.get_cmap('gist_rainbow')
element = ("Si13i", "Si13r", "Si13f", "Si14")
MJD = np.array([[58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910],]*12).transpose()
print(MJD)
fig, axs = plt.subplots(4,1, figsize=(10,6))
fig.subplots_adjust(hspace = 0.1)
#Save the values of fluxes and flux errors in the arrays.
for name in sorted(files):
	x = 0
	j = j + 1
	with open(name, 'r') as f:
		for i, line in enumerate(f):
			if i > 19:
				x = x + 1
				flux[j-1][x-1] = float(line.split()[1])
				fluxerror[j-1][x-1] = float(line.split()[2])
				#color = cm(1.*x/NUM_COLORS)
				#colorls.append(cm(1.*x/NUM_COLORS))
				#axs[j].errorbar(j, flux[j-1][x-1], fluxerror[j-1][x-1], marker='s', color = 'black', ms=5, mew=4)
#Plot the subgraphs by getting values from the arrays

for x in range(0,4):
	for j in range(0,5):
		axs[x].set_xlim(3.55 + 58340, 4.7 + 58340)
		axs[x].errorbar(MJD[j][x], flux[j][x], fluxerror[j][x], marker='s', color = 'blue', ms=5, mew=4)
		axs[x].plot([MJD[0][x],MJD[1][x],MJD[2][x],MJD[3][x],MJD[4][x]],
		 [flux[0][x], flux[1][x], flux[2][x], flux[3][x], flux[4][x]], 'k-', color = 'blue')
	axs[x].legend([element[x]], loc = 1)
	axs[x].yaxis.set_major_formatter(FixedOrderFormatter(-5))
	#axs[x].yaxis.set_major_formatter(FuncFormatter(lambda x, pos: '%.0f'%x))
	axs[x].grid()
#ax = fig.add_subplot(1, 1, 1)
#ax.set_yscale('log')
#locs,labels = yticks()
#yticks(locs, map(lambda x: "%.1f" % x, locs*1e5))
#ylabel('Flux (1E-5)')
fig.text(0.5, 0.04, 'MJD', ha='center')
fig.text(0.04, 0.5, 'Flux', va='center', rotation='vertical')
plt.show()
