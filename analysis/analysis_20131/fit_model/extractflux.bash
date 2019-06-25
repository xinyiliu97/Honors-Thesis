#!/bin/bash
for file in ./fit_alllines*.txt; do 
	awk '0 == (NR-1) % 5 && NR > 25 {print $5}' "$file" >> flux.txt
done
pr -ts" " --columns 5 flux.txt > fluxt.txt &&
awk 'BEGIN{ ORS="" } { for ( i=1; i<= NF ; i++){ print $i"\n"  }  }' fluxt.txt > fluxall.txt
