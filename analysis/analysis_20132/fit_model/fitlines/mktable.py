import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path1  = '/home/xliu/analysis_20132/fit_model/fitlines/all_paramvalues2.txt'
file1 = glob.glob(path1)

myf = open("table.txt", "a")
myf.write("\n" + "redshift" + "\n")
n = 1
with open("all_paramvalues2.txt", "r") as f:
 	for i, line in enumerate(f):
 		if (i >= 8) & (i<=25):
 			obswl = line.split()[2]
 			print(obswl)
 			myf.write(obswl + "\n")

myf.close()
f.close()