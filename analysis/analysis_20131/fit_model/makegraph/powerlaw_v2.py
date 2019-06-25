import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path1 = '/home/xliu//analysis_20132/fit_model/fitlines/all_paramvalues2.txt'
path2  = '/home/xliu/analysis_20131/fit_model/all_paramvalues*.txt'
fileshort = glob.glob(path1)
fileslong = glob.glob(path2)


phoindexls = []
phoindexerls = []
normls = []
normerrorls = []

#get date
MJDref = 58340.50758102
MJDb = (58340.50758102, 58343.62893332, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910)
MJDe = (58340.75083333, 58343.85713227, 58344.08533122, 58344.31353015, 58344.54172910, 58344.76992804)
MJDm = []
MJD = []
for i in range(0,6):
	MJDm.append((MJDb[i]+MJDe[i])/2)
	MJD.append(MJDm[i] - MJDref)
part = [0,1,2,3,4]

#plotting
fig, ax = plt.subplots(1, 2, sharex='col', sharey='row', gridspec_kw = {'width_ratios':[0.5, 3]})
plt.subplots_adjust(wspace=0.01, hspace=0.1)
size = 20

x = 0

def date(path):
	for name in sorted(path):
		with open(name, "r") as f:
			for i, line in enumerate(f):
				if i == 6:
					norm = float(line.split()[1])
					normerror = float(line.split()[2])
				elif i ==7:
					phoindex= float(line.split()[1])
					phoindexer = float(line.split()[2])
			normls.append(norm)
			normerrorls.append(normerror)
			phoindexls.append(phoindex)
			phoindexerls.append(phoindexer)
	return(normls, normerrorls, phoindexls, phoindexerls)

def main():
	N1, Ner1, alpha1, alphaer1 = date(fileshort)
	N, Ner, alpha, alphaer = date(fileslong)
	print(N, Ner, alpha, alphaer)
	for i in range(0,6):
		if i == 0:
			#ax[0].errorbar(MJD[i], N[i], Ner[i], marker='o', color = 'red',
			# ms=5, mew=4, label = "The Change of Normalization of the Powerlaw of SS 433 Spectrum")
			#ax[0].tick_params( which='major', labelsize=size)
			#ax[0].grid(axis = 'both', linestyle='-', linewidth = 1)
			
			ax[0].errorbar(MJD[i], alpha[i], alphaer[i], marker='o', color = 'red',
		 	ms=5, mew=4, label = "The Change of Photon Index of the Powerlaw of SS 433 Spectrum")
		 	ax[0].tick_params( which='major', labelsize=size)
			ax[0].grid(axis = 'both', linestyle='-', linewidth = 1)
		
		else:
			#ax[1].errorbar(MJD[i], N[i], Ner[i], marker='o', color = 'red',
			#ms=5, mew=4, label = "The Change of Normalization of the Powerlaw of SS 433 Spectrum")
			#fig.text(.05, .5, r"Normalization (photons/keV/$cm^2$/s)", ha='center', va='center', rotation='vertical', fontsize = 25)
			#ax[1].tick_params( which='major', labelsize=size)
			#ax[1].grid(axis = 'both', linestyle='-', linewidth = 1)
		
			ax[1].errorbar(MJD[i], alpha[i], alphaer[i], marker='o', color = 'red',
		 	ms=5, mew=4, label = "The Change of Photon Index of the Powerlaw of SS 433 Spectrum")
		 	fig.text(0.5, 0.04, r"Days since 2018-Aug-10.5076 UTC (MJD 58340.5076)", ha='center', fontsize = 25)			
			fig.text(.05, 0.5, r"Photon Index", ha='center', va='center', rotation='vertical', fontsize = 25)
			plt.tick_params(axis='x', which='major', labelsize=size)
			plt.tick_params(axis='y', which='major', labelsize=size)
			plt.grid(axis = 'both', linestyle='-', linewidth = 1)
			#plt.tick_params(axis='x', which='major', labelsize=size)
			#plt.tick_params(axis='y', which='major', labelsize=size)
			#plt.grid(axis = 'both', linestyle='-', linewidth = 1)
	plt.show()

main()