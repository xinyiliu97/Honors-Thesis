import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path  = '/home/xliu/analysis_20131/fit_model/blind_fit/voigt*.txt'
files = glob.glob(path)

myline = []
myf = open("getwl.txt", "w")
myf.write("Energy (keV)" + "\t" + "Obs_wl (A)" + "\t" + "rest_wl (A)" + "\t" + "Element" + "\n")
n = 1
for name in sorted(files):
	n = 1
	with open(name, "r") as f:
		for i, line in enumerate(f):
			if i == 4*n + 2:
				energy = float(line.split()[4])
				wavelength = ((3e8 * 6.63e-34/(energy*1000*1.60218e-19)))*1e10
				myf.write(str(energy) + "\t" + str(wavelength)+ "\t\t" + "\n")
				n = n + 1
f.close()