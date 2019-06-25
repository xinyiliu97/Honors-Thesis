#!/bin/bash
for file in ./fit_alllines*.txt; do 
	awk '0 == (NR-2) % 5 && NR > 26 {print $5}' "$file" >> obs.txt 
done
pr -ts" " --columns 5 obs.txt > obs1.txt &&
awk 'BEGIN{ ORS="" } { for ( i=1; i<= NF ; i++){ print $i"\n"  }  }' obs1.txt > obs2.txt
 



#awk '0 == (NR-2) % 5 && NR > 26 {print $5}' fit_allline1.txt > obs1.txt &&
#awk '0 == (NR-2) % 5 && NR > 26 {print $5}' fit_allline2.txt > obs2.txt &&
#awk '0 == (NR-2) % 5 && NR > 26 {print $5}' fit_allline3.txt > obs3.txt &&
#awk '0 == (NR-2) % 5 && NR > 26 {print $5}' fit_allline4.txt > obs4.txt &&
#paste obs0.txt obs1.txt obs2.txt obs3.txt obs4.txt


