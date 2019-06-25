#!/bin/bash

# first extract all sigmas into 5 different files 
awk '$2 ~ /sigma$/  {print $5}' fit_alllines.txt > sigma.txt


# then paste them side by side into one file
#paste sigma_fit_alllines0.txt sigma_fit_alllines1.txt sigma_fit_alllines2.txt sigma_fit_alllines3.txt sigma_fit_alllines4.txt > sigma.txt

# transpose the file
#tr '\n' ' ' <  sigma.txt > sigma1.txt

