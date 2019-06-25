#!/bin/bash
zred=-0.010572
zblu=0.087716
awk '{print $11,$12,$1, $1*(1.0+'$zred'), $1*(1.0+'$zblu') }' lines_parts.txt > wl_short4.txt
