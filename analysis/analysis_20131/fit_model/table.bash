#!/bin/bash
paste flux0.txt flux1.txt flux2.txt flux3.txt flux4.txt | awk -v OFS='\t' '{print $1,$2,$3,$4,$5}' > table.txt && datamash --no-strict transpose < table.txt > table1.txt &&
awk '{if(maxc<NF)maxc=NF;
      for(i=1;i<=NF;i++){(a[i]!=""?a[i]=a[i]RS$i:a[i]=$i)}
      }
     END{
      for(i=1;i<=maxc;i++)print a[i]
     }' table1.txt > table2.txt
