import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path  = '/home/xliu/analysis_20131/fit_model/blind_fit/checkrs.txt'
files = glob.glob(path)


myf = open("checkrs.txt", "a")
myf.write("\n" + "redshift" + "\n")
n = 1
with open("checkrs.txt", "r") as f:
 	for i, line in enumerate(f):
 		if i > 0:
 			obswl = float(line.split()[1])
 			restwl = float(line.split()[2])
 			print(obswl,restwl)
 			rs = (obswl - restwl)/restwl
 			myf.write(str(rs) + "\n")

myf.close()
f.close()