#!/usr/bin/env isis
% This is based on Herman's email on 2018-Oct-03

_auto_declare=1;
require("tgcat");
pdir = "/home/xliu/20131"; 
hetgs_use_narrow_masks( 1 );       % auto resets after use.
s = set_source_detection_info( "findzo" ) ;
run_pipe( pdir; detect_info = s ) ;

