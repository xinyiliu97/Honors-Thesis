import numpy as np
import matplotlib.pyplot as plt

f=open(all_lines,"r")
lines=f.readlines()
result=[]
for x in lines:
    result.append(x.split(' ')[1])
f.close()





#ytheo = -0.009697
#ytheoerr = 0.009
#x = 58343.74303
#y = 0.03634
#xerr = 0.114099475
#yerr = 0.000227
#plt.errorbar(x, ytheo, ytheoerr, marker='s', ms=5, mew=4)
#plt.errorbar(x, y, yerr, marker='s', ms=5, mew=4)

plt.show()
