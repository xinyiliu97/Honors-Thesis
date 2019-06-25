#!/bin/bash
awk 'NR>=7 && NR<=23 {print $5}' fit_alllines1.txt > wl.txt; 
