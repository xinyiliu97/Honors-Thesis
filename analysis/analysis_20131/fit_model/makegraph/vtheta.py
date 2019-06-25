import math
import numpy as np
import matplotlib.pyplot as plt
import glob
from brokenaxes import brokenaxes
import matplotlib
from matplotlib.font_manager import FontProperties
matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True

def f(x):
	return (np.arccos(((0.034+1)*np.sqrt(1-x**2)-1)/x)*360)/(2*np.pi)
def g(x):
	return (np.arccos(((-0.0097+1)*np.sqrt(1-x**2)-1)/x)*360)/(2*np.pi)
print(f(0.995))

size = 20

x2 = np.arange(0.1, 0.9, 0.005)
print(x2)

plt.plot(x2, f(x2), 'b-', label= "z = 0.034")
plt.plot(0.26, f(0.26), 'bo')
plt.plot(x2, g(x2), 'g-', label= "z = -0.0097")
plt.plot(0.26, g(0.26),'go')
plt.plot(0.45, f(0.45),'ro')

plt.legend(loc='center right', prop = {'size':20})
plt.tick_params(axis='x', which='major', labelsize=size)
plt.tick_params(axis='y', which='major', labelsize=size)
#plt.xlabel('Jet Velocity (c)')
#plt.ylabel('Angle to the Line of Sight ($\theta$)')
plt.text(0.5, 63, r"Jet Velocity in the unit of c ($v$)", ha='center', fontsize = 25)			
plt.text(0, 100, r"Angle to the Line of Sight in degree ($\theta$)", ha='center', va='center', rotation='vertical', fontsize = 25)
plt.text(0.28, 85, "observed", ha='center', fontsize = 25)			
plt.text(0.28, 105, "predicted", ha='center', fontsize = 25)			
plt.text(0.26, 68, "0.26", ha='center', color = 'black',fontsize = 25)
plt.text(0.45, 68, "0.45", ha='center', color = 'r',fontsize = 25)
#plt.text(0.1, 100, "99.7", ha='center', fontsize = 15)		

plt.axhline(90.1, color = 'y', linestyle = '--')
plt.axhline(99.8, color = 'y', linestyle = '--')
plt.axvline(0.26, color = 'y',linestyle = '--')
plt.axvline(0.45, color = 'y', linestyle = '--')

#plt.axhline(y=99, xmin=0.1, xmax=0.45)
l1 = np.arange(0.1, 0.5, 0.005)
yl1 = [g(0.26)]*len(l1)

#plt.stem(99,0.26)
#plt.text(0.245, 93, "The relationship between $\theta$ and $v$", ha='center', fontsize = 25)
			
plt.show()