#!/bin/bash
zred=0.009234
zblu=0.0679105
awk '{print $11,$12,$1, $1*(1.0+'$zred'), $1*(1.0+'$zblu') }' lines.txt > wl_short1.txt
