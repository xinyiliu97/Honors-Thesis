#!/bin/bash

# first extract all sigmas into 5 different files 
for f in fit_alllines*.txt
do
	 awk '$2 ~ /sigma$/  {print $5}' $f > "sigma_${f}"
done

# then paste them side by side into one file
paste sigma_fit_alllines0.txt sigma_fit_alllines1.txt sigma_fit_alllines2.txt sigma_fit_alllines3.txt sigma_fit_alllines4.txt > sigma.txt

# transpose the file
tr '\n' ' ' <  sigma.txt > sigma1.txt

