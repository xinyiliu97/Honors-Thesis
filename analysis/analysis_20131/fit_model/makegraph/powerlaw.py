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

part = [0,1,2,3,4]
fig = plt.figure()
ax = plt.axes()
x = 0
for name in sorted(files):
		with open(name, "r") as f:
			for i, line in enumerate(f):
				if i == 6:
					norm= float(line.split()[1])
					normerror = float(line.split()[2])
				elif i ==7:
					phoindex= float(line.split()[1])
					phoindexerror = float(line.split()[2])
			l = np.linspace(1, 13, 1300)
			logl = np.log(l)
			lognorm = np.log(norm)
			phospec = lognorm - phoindex * logl
			ax.plot(logl, phospec , label = "Part%d" % part[x])
			ax.legend(loc = 'right', fontsize = 25, bbox_to_anchor=(1,0.5))
		x = x + 1
plt.xlabel(r'$\mathrm{log(E)}$', fontsize = 30)
plt.ylabel (r'$\mathrm{log(N(E)}$ ($\mathrm{photons/cm^2/s/keV}$)', fontsize = 30)
plt.show()