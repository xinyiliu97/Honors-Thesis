require("tgcat");

variable pdir = "part0" ; 

message("\n.......................part0.......................\n");

variable s = set_source_detection_info( "findzo" ) ; 
variable s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 
%

pdir = "part1" ; 

message("\n.......................part1.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 
%

pdir = "part2" ; 

message("\n.......................part2.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 
%

pdir = "part3" ; 

message("\n.......................part3.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 

pdir = "part4" ; 

message("\n.......................part4.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 

pdir = "part5" ; 

message("\n.......................part5.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 

pdir = "part6" ; 

message("\n.......................part6.......................\n");

s = set_source_detection_info( "findzo" ) ; 
s1 = set_tg_create_mask_info( 25, 25, 25 ) ; 

run_pipe( pdir; detect_info = s, mask_info = s1 ) ; 
% tg_run_cleanup( pdir, "${pdir}/P_sum" ) ; 
