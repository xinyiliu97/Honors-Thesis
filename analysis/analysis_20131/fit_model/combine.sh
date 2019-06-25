#!/bin/bash
paste <(sed 's/^[[:blank:]]*//' wl.txt) obs2.txt fluxall.txt > table2.txt
