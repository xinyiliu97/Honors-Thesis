import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import glob
import csv
from itertools import izip
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True
path  = '/home/xliu/analysis_20131/fit_model/blind_fit/alllinefits_voigt*.csv'
files = glob.glob(path)

##combine csv files into one
# combined_csv = pd.concat([pd.read_csv(f) for f in files])
# combined_csv.to_csv( "combined_csv.csv", index=False)

## transpose csv file

import pandas as pd
pd.read_csv('combined_table.csv', header=None).T.to_csv('combined_table_t.csv', header=False, index=False)


# myf = open("table.txt", "a")
# myf.write("obswl" + "\t" + "obswlerror" + "\t" + "flux" + "\t" + "fluxerror" + "\n")
# n = 1
# for name in sorted(files):
# 	with open(name, "r") as f:
# 		for i, line in enumerate(f):
#  			obswl = line.split()[1]
#  			myf.write(obswl + "\t")
#  			obswlerror = line.split()[2]
#  			myf.write(obswlerror + "\t")
#  			flux = line.split()[3]
#  			myf.write(flux + "\t")
#  			fluxerror = line.split()[4]
#  			myf.write(fluxerror + "\n")




# myf.close()
# f.close()