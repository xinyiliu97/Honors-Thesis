% -*- mode: SLang; mode: fold -*-
%; Time-stamp: <2019-04-26 10:42:22 dph>
%; Directory:  ~dph/libisis/
%; File:       Aped_utils.sl
%; Author:     David P. Huenemoerder <dph@space.mit.edu>
%; Orig. version: 2006.nn.nn
%;========================================

% version 1.3.2 2019.04.26
%  problems with plaw_dem2 temperature grid truncation; the fit param may say, e.g., LogTmax=7.06,
%  but the fit may actually use a bin to 7.16 (and get a very different spectrum say, at 6 keV).
%  Try finer default grid of 0.05 dex instead of 0.1 (rather than thinking hard and
%  interpolating/integrating over fractional end bins).  
%  WARNING: also raises the possibility of overflowing the grid of the Aped_emd model called,
%          which is limited to 26 bins.  May need a local custom model.

% version 1.3.1 2019.02.20 dph
%  modified plaw_dem2 grid, so not restricted to even 0.1 dex grid boundaries.
%

% version 1.3.0 2019.01.30 dph
%
%   add a simpler power law dem model, single component.
%     of form    D(T) =  norm * T^\gamma
%         parameters VEM, gamma, then the usual APED plasma params.
%         norm will be the usual VEM * 1.e-14 / 4pid^2.
%

% version 1.2.0    2012.03.27
% try to accomodate K in the element list.
% Note that K is not an isis global variable .
%   K is included in AtomDB 2.0

% version 1.1.0
% add a version of Aped_* with He in the abund list.
% To maintain back compatibility w/ old par files, we need to keep the
% versions without.  used qualifier in _Aped().
% BUT: no such easy way for plaw version.
% 

% version 1.0.0
%  change a couple function names.  plaw_idem => plaw_emd; plaw_ddem => plaw_dem;
%  add normalized Aped_emd form with vem parameter.
%  add tgrid functions for default 26 T log grid.

% 2010.07.16 added functions
%       p = aped_par_to_pstate( fun_name );  % current fit_fun
%       p = aped_par_to_pstate( fpar, fun_name ); % load from par file


% version 0.3.5
%  2009.11.09  added aped_line_free_bins()


% version:  0.3.4
%          
% purpose:  useful things for working w/ aped models.
%           like standard plasma model definitions.
%          

private variable _version = [1, 3, 3 ]   ; % major, minor, patch
variable Aped_utils_version = sum( _version * [ 10000, 100, 1 ] ) ; 
variable Aped_utils_version_string =
            sprintf("%d.%d.%d", _version[0], _version[1], _version[2] ) ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% provide for models w/ individual plasma model components. [not done...]
%
%
% see model_spectrum()  help for info about contrib flags.
% see create_aped_fun() help for info on the hook() function.

private variable K = 19 ;

private variable Default_Elem_List = [ He, C, N, O, Ne, Na, Mg, Al, Si, S, Ar, K, Ca, Fe, Ni ] ;
private variable Orig_Elem_List = [        C, N, O, Ne,     Mg, Al, Si, S, Ar,    Ca, Fe, Ni ] ;

private variable Default_Elem_SList = [ "He", "C", "N", "O", "Ne", "Na", "Mg", "Al", "Si", "S", "Ar", "K", "Ca", "Fe", "Ni" ] ;
private variable Orig_Elem_SList = [          "C", "N", "O", "Ne",       "Mg", "Al", "Si", "S", "Ar",      "Ca", "Fe", "Ni" ] ;

private variable NO_ABUND_FLAG = 0 ; %  if 1, use ; no_abund_prefix in param name

private variable emd_logt_lo, emd_logt_hi, emd_logt_mid ;
private variable emd_lnt_lo,  emd_lnt_hi ;
private variable emd_t_lo,    emd_t_hi, emd_t_mid ;
private variable emd_dlnt, emd_dlogt ; 

private variable log10_tmin = 5.95 ;
private variable log10_tmax = 8.55 ; 
private variable emd_nT = 26 ; 

( emd_logt_lo, emd_logt_hi ) = linear_grid( log10_tmin, log10_tmax, emd_nT ) ; 

emd_logt_mid = ( emd_logt_lo + emd_logt_hi ) / 2.0 ;
emd_lnt_lo   = emd_logt_lo / log10( E ) ; 
emd_lnt_hi   = emd_logt_hi / log10( E ) ; 

emd_t_lo     = 10^emd_logt_lo ; 
emd_t_hi     = 10^emd_logt_hi ; 
emd_t_mid    = 10^emd_logt_mid ; 

emd_dlnt     = emd_lnt_hi  - emd_lnt_lo ; 
emd_dlogt    = emd_logt_hi - emd_logt_lo ; 

define emd_get_default_tgrid()
{
    return( @emd_t_lo, @emd_t_hi, @emd_t_mid ) ;
}

define get_default_elem_nums()
{
    return( @Default_Elem_List );
}

define get_default_elem_names()
{
    return( @Default_Elem_SList );
}

private variable aped_flag = struct { contrib_flag, line_list };
aped_flag.line_list = NULL;    
aped_flag.contrib_flag = MODEL_LINES_AND_CONTINUUM ; 

private variable valid_flags = [
  MODEL_LINES_AND_CONTINUUM,       % 0
  MODEL_LINES,                     % 1
  MODEL_CONTIN,                    % 2
  MODEL_CONTIN_PSEUDO,             % 3
  MODEL_CONTIN_TRUE                % 4
] ;

private variable aped_model_types = [
   "MODEL_LINES_AND_CONTINUUM",
   "MODEL_LINES",
   "MODEL_CONTIN",
   "MODEL_CONTIN_PSEUDO",
   "MODEL_CONTIN_TRUE"
] ;

define Aped_list_types()
{
    vmessage("\n%% Model component types are: \n");
    () = array_map( Integer_Type,
                    &printf,
                    "%%   %d  %S\n",
                    valid_flags, aped_model_types ) ;
    message("");
}

define Aped_set_type( )  % ( id )
{
    variable id;
    if (_NARGS == 0 )
    {
	id = 0 ;
    }
    else
    {
	id = () ;
    }

    if ( (id < min(valid_flags) ) or (id > max(valid_flags) ))
    {
	id = min( valid_flags ) ;
    }
    aped_flag.contrib_flag = id ;
}

%
% If you want only certain lines included in the model, this can be
% used to specify them.  line_list should be the result of something
% like where( el_ion(Ne, 10) ), or the equivalent.  (also see trans(),
% page_group(), brightest() ).
%
define Aped_set_linelist( ) % ( line_list )
{
    variable line_list ; 

    aped_flag.line_list = NULL ;

    if ( _NARGS == 1 )
    {
	line_list = () ; 
	aped_flag.line_list = line_list ;
    }
}    

define Aped_get_type()
{
    return( valid_flags[ aped_flag.contrib_flag ], aped_model_types[aped_flag.contrib_flag] ) ; 
}

define Aped_get_linelist()
{
    return( aped_flag.line_list ) ; 
}

define Aped_print_type()
{
    variable nt, st, ll ;
    (nt, st) = Aped_get_type;
    () = printf( "%d: %s\n", nt, st );
    ll = Aped_get_linelist;
    if (ll != NULL ) page_group( ll );
}


private define aped_hook ( id )
{
    return ( aped_flag ) ;
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% define a fit function called "Aped_n" which will be a nT model
% w/ variable abundances.
%
define _Aped( )   %  (n , name )
{
    variable n, name, elems ;

%    elems = [ C, N, O, Ne, Mg, Al, Si, S, Ar, Ca, Fe, Ni ] ;
    elems = Default_Elem_List; 

    if ( qualifier_exists( "He" ) ) elems = [ He, elems ] ; 
    if ( qualifier_exists( "H" ) )  elems = [ H, elems  ] ; 

    switch( _NARGS )
    {
	case 1:
	n = () ;
	name = "Aped_$n"$ ;
    }
    {
	case 2:
	(n,name) = () ;
    }
    {
	case 3:
	(n, name, elems) = () ;
    }
    {
	message("");
	message("%% _Aped( n[, name[, elems]]) ") ;
	message("%%    Define n-temperature component APED plasma model.");
	message("%%    If the second argument is omitted, then the model name");
        message("%%      will be \"Aped_n\" (using the integer value of n).");
	message("%%    The third argument should be an array of element atomic");
	message("%%      numbers.  The default will be all APED elements.");
	message("%%  EXAMPLES:");
	message("%%  isis> fit_fun( \"Aped_1(1)\");   % pre-defined 1-T model.");
	message("%%  isis> fit_fun( \"Aped_2(1)\");   % pre-defined 2-T model.");
	message("%%  isis> fit_fun( \"Aped_3(1)\");   % pre-defined 3-T model.");
	message("%%  isis> fit_fun( \"Aped_emd(1)\"); % pre-defined 26-T model.");
	message("%%  isis> _Aped(4); % define 4-T model called \"Aped_4\"");
	message("%%  isis> _Aped(19,\"xaped\", [Fe,Ne,Si]); % define 19-T model called \"xaped\" with only 3 elements as parameters.");
	message("");
	return;
    }
    
    variable p = default_plasma_state;
    p.elem = elems ; 
    p.elem_abund = Double_Type[ length( p.elem ) ] + 1.0 ;
    p.temperature = Double_Type[ n ] ;
    p.norm = Double_Type[ n ] + 1.0 ;

% select initial n temperatures from range of 6.0-8.5

    variable logt1, logt2 ;
    ( logt1, logt2 ) = linear_grid( log10_tmin, log10_tmax, n ) ; 

    p.temperature = 10^( (logt1 + logt2) / 2 ) ;

    if (NO_ABUND_FLAG)     create_aped_fun( name, p, &aped_hook; no_abund_prefix ) ;
    else create_aped_fun( name, p, &aped_hook ) ;
}

_Aped( 1 ) ;
_Aped( 2 ) ;
_Aped( 3 ) ;
_Aped( 4 ) ; 
_Aped( 5 ) ; 
_Aped( 6 ) ; 
_Aped( emd_nT, "Aped_emd" ) ; %%% for full EMD models.

define set_no_abund_flag( f )
{
    NO_ABUND_FLAG = 0 ; 
    if ( f > 0 ) NO_ABUND_FLAG = 1 ;
    _Aped( 1 ) ;
    _Aped( 2 ) ;
    _Aped( 3 ) ;
    _Aped( 4 ) ; 
    _Aped( 5 ) ; 
    _Aped( 6 ) ; 
    _Aped( emd_nT, "Aped_emd" ) ; %%% for full EMD models.
}

%
% Utilities to turn aped model params into a plasma state variable...
% Example: p = aped_par_to_pstate( "Aped_emd(1)" );
%
private define _aped_par_to_pstate( fun_name )
{
    variable p    = default_plasma_state ;
    p.norm        = get_par( "${fun_name}.norm*"$ ) ; 
    p.temperature = get_par( "${fun_name}.temperature*"$ ) ;
    p.density     = get_par( "${fun_name}.density"$ ) ;
    p.metal_abund = get_par( "${fun_name}.metal_abund"$ ) ;
    p.vturb       = get_par( "${fun_name}.vturb"$ ) ;
    p.redshift    = get_par( "${fun_name}.redshift"$ ) ;
    p.elem_abund  = get_par( "${fun_name}.abund_*"$ ) ;

    p.elem        = Integer_Type[ length(p.elem_abund) ] ;
    variable i, a ;
    a = get_par_info( "${fun_name}.abund_*"$ );
    for( i=0; i<length(a); i++) p.elem[i] = eval( strtok( a[i].name, "_")[-1] );

    return( p ) ; 
}

% or from a par file; instead of trying to parse the name (which could
% include arbitrary components),  provide the name:
% Example:  p = aped_par_file_to_pstate( "Aped_emd_001.par", "Aped_emd(1)" ); 
%
private define _aped_par_file_to_pstate( fpar, fun_name )
{
    variable saved_fit_fun = get_fit_fun ;
    load_par( fpar ) ;
    variable p = _aped_par_to_pstate( fun_name ) ;
    fit_fun( saved_fit_fun ) ;
    return( p ) ; 
}

define aped_par_to_plasma_state()
{
    variable r, fun_name, fpar ; 
    switch( _NARGS )
    {
	case 1:               % use current fit_fun
	fun_name = () ; 
	r = _aped_par_to_pstate( fun_name ) ;
    }
    {
	case 2:               % load from par file
	( fpar, fun_name ) = () ;
	r = _aped_par_file_to_pstate( fpar, fun_name ) ;
    }
    {
	message("USAGE: aped_par_to_plasma_state( fun_name ) ;       % uses current fit_fun");
	message("USAGE: aped_par_to_plasma_state( fpar, fun_name ) ; % use par file and name");
	return( NULL ) ; 
    }
    return( r ) ; 
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Introduce a normalization parameter for the norms, so that the
% overall VEM can be set, and the EMD(T) shape can be constant.
% Done via dummy function which introduces the parameter VEM, and
% through set_par_fun, will tie all the norms.
%
define Aped_vem_fit( lo, hi, par )
{
    return ( 1 ) ; 
}

add_slang_function( "Aped_vem", ["VEM"], [0] ) ;

define Aped_vem_defaults( n )
{
    variable s = struct { value=1.0, freeze=0, min=0, max=DOUBLE_MAX, hard_min=0.0, hard_max=_Inf, step=0, relstep=0 };
    return( s ) ;
}

set_param_default_hook( "Aped_vem", "Aped_vem_defaults" ) ; 

define Aped_emd_norm( s, n )     % e.g.,   Aped_emd_norm( "Aped_emd(1)", 1 );
{
    if (  ( n <= 0 ) || ( n == NULL ) ) n = 1 ; 
    fit_fun( "Aped_vem( $n ) * "$ + get_fit_fun  ) ;

    variable p = get_par( "${s}.norm*"$ ) ;
    variable vem = sum( p ) ; 
    set_par( "Aped_vem($n).VEM"$, vem, 0, vem*1.e-6, vem*1.e6 ) ; 
    p /= vem ; 

    variable i ;
    for( i=1; i<=length(p); i++ )
    {
	variable k = p[i-1];
	set_par_fun( "${s}.norm${i}"$, "$k * Aped_vem($n).VEM"$ ) ;
    }
}

define Aped_emd_norm_reset( s, n )
{
    variable vem = get_par( "Aped_vem($n).VEM"$ ) ;
    freeze( "Aped_vem( $n ).VEM"$) ; 
    variable p = get_par( "${s}.norm*"$ ) ;
    variable i ;
    for (i=1; i<=length(p); i++)
    {
	set_par_fun( "${s}.norm${i}"$, NULL ) ;
%	set_par( "${s}.norm${i}"$, p[i-1] ) ;
    }
}

% example test:
#iffalse
fit_fun( "Aped_emd(1) * wabs(1)" ) ; 

p = get_par( "Aped_emd(1)*.norm*");
x = [1:length(p)];
p = exp( -(x-length(p)/2.)^2/4^2 / 2 ) ; 
set_par( "Aped_emd(1)*.norm*", p);
xnotice( all_data, 1.5, 30);
thaw("Aped_emd(1)*.norm*");
renorm_counts;

Aped_emd_norm( "Aped_emd(1)", 1 ) ; 
Aped_emd_norm_reset( "Aped_emd(1)", 1 ) ; 
#endif


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% evaluate "line-free" bins, using a defined model and loaded data.
%
% support combined_data version...
%  ... though there is not much reason to used combined data, since we
%      are only using the models.  It might extend the coverage,
%      though, since positive and negative orders have different
%      ranges.
%
define aped_line_free_bins()         % ( h, frac_thresh )
{
    variable h, frac_thresh ; 

    if (_NARGS != 2 )
    {
	message("%% USAGE: (v_all, v_true, bins ) = aped_line_free_bins( idx, tol );" );
	message("%%  idx: spectrum index (arf, rmf must be assigned).");
	message("%%       For combined dataset handle, use idx < 0.");
	message("%%  tol: fractional tolerance");
	message("");
	message("%% v_all:  model spectrum (struct) of continuum plus lines");
	message("%% v_true: model spectrum (struct) of true continuum");
	message("%% bins:   array of spectral bins where (abs(all/true)-1) <= tol ");
	message("");
	message("%% EXAMPLE: ");
	message("%%  (va, vt, l ) = aped_line_free_bins( 3, 0.03 ) ; ");
	message("%%  hplot( va ) ;   ohplot( vt ) ; ");
	message("%%  ignore( 3 ) ; notice_list( 3, l ) ;  oplot_data_counts( 3 );");
	return (NULL) ; 
    }

    ( h, frac_thresh ) = () ; 

    if (length( h ) != 1 ) error("%% idx must be a scalar histogram index.");

    variable v_true, v_all, v_test, l, r, b, hh ;

    if ( h < 0 )
    {
	hh = combination_members( -h ) ; 
	b = get_data_info( hh[0] ).notice_list ;
	notice( hh ) ; 
    }

    Aped_set_type( MODEL_CONTIN_TRUE ) ; 
    () = eval_counts;

    if ( h < 0 )
    {
	r = get_combined2( -h )[0].model ;
	v_true = get_model_counts( hh[ 0 ] ) ;
	v_true.value = r ;
    }
    else
    {
	v_true = get_model_counts( h ) ;
    }

    Aped_set_type( MODEL_LINES_AND_CONTINUUM ) ; 
    () = eval_counts;

    if ( h < 0 )
    {
	r = get_combined2( -h )[0].model ;
	v_all = get_model_counts( hh[ 0 ] ) ;
	v_all.value = r ; 
    }
    else
    {
	v_all = get_model_counts( h ) ;
    }

    l = where( v_all.value > 0 );

    v_test      = Double_Type[ length( v_all.value ) ]  ; 
    v_test[ l ] = v_all.value[l] / v_true.value[l] ;

    if ( h < 0 )
    {
	ignore( hh );
	notice_list( hh, b ) ;
    }

    return ( v_all, v_true, where( abs(v_test-1.0) <= frac_thresh ) ) ;
}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% plot emissivity curves.
%
private variable Tgrid = 10^[5.5:8.5:0.1] ; 

define get_em( elem, ion )
{
    variable e = line_em( where(el_ion( elem, ion )), Tgrid ) ;
    return( @Tgrid, e ) ; 
}


private define _plot_em()         % ( pref, t, elem, ion[, col] )
{
    variable pref, t, elem, ion, col ;
    if ( _NARGS == 5 )
    {
	( pref, t, elem, ion, col ) = () ;
	color( col ) ;
    }
    else ( pref, t, elem, ion ) = () ;

    variable e = line_em( where(el_ion( elem, ion )), t );
    @pref( t, e ) ; 
}

define plot_em()               % ( elem, ion[, col] )
{
    variable elem, ion, col ;
    if (_NARGS == 3 )
    {
	(elem, ion, col) = () ;
	_plot_em( &plot, Tgrid, elem, ion, col ) ;
    }
    else
    {
	(elem, ion) = () ;
	_plot_em( &plot, Tgrid, elem, ion ) ;
    }
}

define oplot_em()              % ( elem, ion[, col])
{
    variable elem, ion, col ;
    if (_NARGS == 3 )
    {
	(elem, ion, col) = () ;
	_plot_em( &oplot, Tgrid, elem, ion, col ) ;
    }
    else
    {
	(elem, ion) = () ;
	_plot_em( &oplot, Tgrid, elem, ion ) ;
    }
}

% fool _plot_em to return Tmax:
%
private define _get_tmax( t, e )
{
    variable l = where( e == max( e ) )[0] ; 
    variable tmax = 0.5 * ( t[l] + t[l+1] ) ; 
    return( tmax ) ; 
}

define get_tmax( elem, ion )
{
    _plot_em( &_get_tmax, Tgrid, elem, ion ) ; 
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2007.05.18
%
% Provide functions for powerlaw parameterizations of the EMD (such as
% used by peres; reale; in coronal and flare modeling).
%
% Define a default grid, as per the _Aped_emd 26-T model of use over
% Xray line regime
%
% Provide in a few forms for convenience:

% The commonly used powerlaw form of the emission measure distribution
% is:
%
%   D( T ) =  D_0 ( T / T_0 ) ^ \gamma(T)   
%
%  and D means   n_e n_H dV/dT  [ /cm^3 /K ],  differential form
%
%   \gamma(T)     > -1   for (T/T_0) <= 1    == \alpha  ~ 3/2
%                 < -1   for (T/T_0)  > 1    == \beta   ~ -2
%
% Logarithmic form in T is convenient - usually use logT.
%
% Global normalization is usually given in terms of the total Volume
% Emission Measure,
%
%  D  = \int{ D(T) dT}  =  \int{  D(x) exp(x) dx },   for  x == lnT
%
%  Given D, \alpha, \beta, and T_0, we can find D_0.
%
%

private variable Log10E = log10(E) ; 
private variable plaw_emd_par = struct{ norm, dpeak, tpeak, alpha, beta } ;

% alpha must be > -1
%
private define plaw_emd_test_alpha( a )
{
    if ( a <= -1 ) return (-1 ) ;
    else return( 0 ) ; 
}

% beta must be < -1
%
private define plaw_emd_test_beta( a )
{
    if ( a >= -1 ) return (-1 ) ;
    else return( 0 ) ; 
}


private define calc_plaw_emd_max( norm, alpha, beta, tpeak )
{
    variable dmax = norm / tpeak * (alpha+1) * (beta+1) / ( beta - alpha ) ;
    return( dmax ) ; 
}

private variable PLAW_EMD ; 
private define plaw_emd_save_par( norm, tpeak, alpha, beta )
{
    variable PLAW_EMD = @plaw_emd_par ;
    PLAW_EMD.norm = norm ;
    PLAW_EMD.alpha = alpha ;
    PLAW_EMD.beta = beta ;
    PLAW_EMD.tpeak = tpeak ; 
    PLAW_EMD.dpeak = calc_plaw_emd_max( norm, alpha, beta, tpeak ) ;
}

define plaw_emd_get_default_par()
{
    return( @plaw_emd_par ) ; 
}


%
% Is T log10? log?  guess, and return linear scale value:
%
%  APED range is 1.e4 - 7.943e8
%
%  if > 100, assume linear.
%  if  9.2 < t <= 20.5  assume ln
%  if  4.0 < t < 8.9    assume log10
%
private define plaw_emd_maybe_convert_t( t )
{
    if ( max(t) <= 8.9 ) return( 10^t ) ;
    if ( max(t) < 20.5 ) return( exp(t) ) ;
    return( t ) ; 
}

private define _plaw_args()
{
    variable t, p ; 
    variable norm, alpha, beta, tpeak, dpeak ; 

    switch ( _NARGS )
    {   % struct of type plaw_emd_par
	case 2:
	(t, p) = () ;
	if ( typeof(p) != Struct_Type )
	{
	    error("%% improper argument: 2nd arg not struct.");
	}
	else
	{
	    p.tpeak = plaw_emd_maybe_convert_t( p.tpeak ) ;
	    p.alpha = double(p.alpha) ;
	    p.beta  = double(p.beta) ;
	    p.dpeak = calc_plaw_emd_max( p.norm, p.alpha, p.beta, p.tpeak ) ; 
	}
    }
    {
	case 5:
	( t, norm, alpha, beta, tpeak ) = () ;
	p = @plaw_emd_par ; 
	p.tpeak = plaw_emd_maybe_convert_t( tpeak ) ;
	p.alpha = double( alpha ) ; 
	p.beta  = double( beta ) ; 
	p.norm  = norm ; 
	p.dpeak = calc_plaw_emd_max( p.norm, p.alpha, p.beta, p.tpeak ) ; 
    }
    {
	error("%% plaw_emd( t, [par_struct | norm, alpha, beta, tpeak ] );");
    }

    if ( plaw_emd_test_alpha( p.alpha) ) error( "%% bad alpha; must be > -1.0") ;
    if ( plaw_emd_test_beta(p.beta)  )  error( "%% bad beta; must be  < -1.0") ;
    if ( p.norm < 0 ) error("%% dpeak bad: must be >=0");

    variable tg = [ plaw_emd_maybe_convert_t( t ) ] ;

    return( tg, p ) ; 
}


%
% power law emd, differential form:
%
define plaw_demx( )    % ( t[], par[] | par struct )
{
    variable args = __pop_args( _NARGS )  ; 
    variable tg, p ;

    ( tg, p ) = _plaw_args( __push_args( args )  ) ; 

    variable gamma  ;

    gamma = ones( length( tg ) ) * p.beta ; 
    variable l = where( tg <= p.tpeak ) ; 
    if ( length( l ) > 0 ) gamma[ l ] = p.alpha ;

    return (  p.dpeak * ( tg / p.tpeak )^gamma ) ;
}

%%%%
%
% integrated over bins:
%
define plaw_emd()   %  w = plaw_emd( tgrid, norm, alpha, beta, tpeak ) 
                     %  ( tgrid, par_struct ) 
{
    variable args = __pop_args( _NARGS )  ; 
    variable tg, p ;

    ( tg, p ) = _plaw_args( __push_args( args )  ) ; 

    variable gamma, ltg1, ltg2, l, d  ;

    ltg1 = log( tg ) ;
    ltg2 = make_hi_grid( ltg1 ) ;

    gamma = ones( length( tg ) ) * p.beta ; 

    l = where( tg <= p.tpeak ) ;
    gamma[ l ] = p.alpha ;

    d = p.dpeak * p.tpeak^(-gamma) / ( gamma+1 ) ;
    d *= ( exp( (gamma+1)*ltg2 ) - exp( (gamma+1)*ltg1 ) ) ;

    return( d ) ; 
}

define set_aped_par_plaw( model_name, norm, alpha, beta, tpeak )
{
    variable p = plaw_emd_get_default_par() ;
    p.norm = norm ;
    p.alpha = alpha ;
    p.beta = beta ;
    p.tpeak = tpeak ;

    variable tg0, tg1, tg2, dt ; 

    tg0 = log10(get_par( "${model_name}.temperature*"$ ) ) ;

    tg2 = make_hi_grid( tg0 ) ;
    dt = tg2 - tg0 ;
    tg1 = tg0 - dt / 2.0 ;
%    tg2 = tg1 + dt ; 

    variable d  = plaw_emd( tg1, p ) ;

    variable i ;
    for (i=1; i<=length(d); i++) set_par( "${model_name}.norm$i"$, d[i-1] ) ; 
}


public define plaw_dem_fit( lo, hi, par )
{
    % powerlaw emission measure parameters:
    %
    variable norm, alpha, beta, tpeak ;

    norm  = par[0] ;  %   1.e-14 * VEM / 4PId^2 ;
    alpha = par[1] ;  %   > -1; exponent for T<tpeak
    beta  = par[2] ;  %   < -1; exponent for T>tpeak
    tpeak = par[3] ;  %   [K] of max emission measure

    % also need other plasma parameters:
    %
%    variable density, vturb, redshift, metal_abund ;

%     density = par[4] ;
%     vturb   = par[5] ;
%     redshift = par[6] ;
%     metal_abund = par[7] ; 

%     % metal abundances:
%     %  C N O Ne Mg Al Si S Ar Ca Fe Ni
%     %
%     variable mabund = Double_Type[ 12 ] ;
%     abund = par[ [8:19] ] ;
    
    variable w = plaw_emd( emd_t_lo, norm, alpha, beta, tpeak ) ;

    variable tmid = 10^( (emd_logt_lo + emd_logt_hi)/2 )  ; 

    % next need to use the params in the Aped_emd function:

    variable y = eval_fun2( "Aped_emd", lo, hi, [ w, tmid, par[[4:]] ] ) ;

    return( y ) ; 
}

#iffalse
private variable params = [ "norm",  "alpha","beta", "tpeak",
                            "density", "vturb", "redshift", "metal_abund", 
                            "He", "C", "N", "O", "Ne", "Mg", 
                            "Al", "Si", "S", "Ar", "Ca", "Fe", "Ni" ] ; 
#endif

private variable params = [ "norm",  "alpha","beta", "tpeak",
                            "density", "vturb", "redshift", "metal_abund", 
                            "abund_" + Default_Elem_SList ] ;

add_slang_function( "plaw_dem", params ) ;

define plaw_dem_defaults( n )
{
    switch( n )
    {
	case 0:  % norm
	return( 1.0 , 0, 0.0, 1000 ); 
    }
    {
	case 1: % alpha
	return( 1.5, 0, -0.999, 10 ) ;
    }
    {
	case 2: % beta
	return( -2, 0, -1.001, -10 ) ;
    }
    {
	case 3: %  tpeak
	return( 1.e7, 0, 1.e6, 1.6e8 ) ;
    }
    {
	case 4: %  density
	return( 1.0, 1, 0, 0 ) ;
    }
    {
	case 5: % vturb
	return( 0.0, 1, 0, 0 ) ;
    }
    {
	case 6: % redshift
	return( 0.0, 1, 0, 0 ) ;
    }
    % the rest, 7-end, are abundances:
    {
	return( 1.0, 1, 0, 0 ) ;
    }
}

set_param_default_hook( "plaw_dem", "plaw_dem_defaults" ) ; 

%%%%%%%%
%
% to circumvent problem w/ multiple component model evaluations (and
% getting only the last one), convert to other kind of plasma model so
% that eval_fun() leaves the total flux of the composite model.
%
%  NOTE: THIS IS ONLY VALID IF ALL OTHER PLASMA MODEL PARAMS ARE
%        IDENTICAL FOR EACH COMPONENT!!!
%        density,  vturb, redshift, metal_abund, and individual element
%        abundances.
%

%
% Use plaw_emd params to generate the distribution.
% Then store as Aped_emd() fit_fun parameters.
%
% (this is to provide a single component model so that line fluxes
% will be from the composite model, not last component evaluated! )
%
%
% dph 2010.12.09 BUG: did not copy abundances to model evaluated!

define eval_multi_plaw_dem()
{
    variable i ; 
    variable saved_fit_fun = get_fit_fun;

%***
   message("eval_multi_plaw_dem: BUG: did not copy abundances to model evaluated!");%***
%***

    %
    %%% validity check
    %
#iffalse
    variable pcheck = ["density", "vturb", "redshift", 
 		       "metal_abund",
                       "He", "C", "N", "O", "Ne", "Mg", "Al", "Si", "S", 
                       "Ar", "Ca", "Fe", "Ni" ] ; 
#endif
    variable pcheck = ["density", "vturb", "redshift", 
 		       "metal_abund",
                       "abund_" + Default_Elem_SList ] ; 

    foreach i ( pcheck )
    {
	if( moment( get_par( "plaw_dem(*).$i"$ ) ).sdev != 0 )
	error( "%% Model too complex; cannot evaluate as composite because of plaw_dem(*).$i"$ );
    }
    
    fit_fun("Aped_emd(9999)" ) ;
    variable Aped_emd_par = get_par("Aped_emd(9999).*" );
    if ( saved_fit_fun != NULL ) fit_fun( saved_fit_fun ) ; 

    variable y, norms, alphas, betas, tpeaks, num_components ; 

    norms  = get_par( "plaw_dem(*).norm" ) ;
    alphas = get_par( "plaw_dem(*).alpha" ) ;
    betas  = get_par( "plaw_dem(*).beta" ) ;
    tpeaks = get_par( "plaw_dem(*).tpeak" ) ;

    num_components = length( norms ) ;

    y = 0.0 * emd_t_lo ;

    for (i=0; i<num_components; i++ )
    {
	y += plaw_emd( emd_t_lo, norms[i], alphas[i], betas[i], tpeaks[i] ) ; 
    }

    Aped_emd_par[ [0:25] ] = y ; 
    () = eval_fun2( "Aped_emd", 1.0, 200.0, Aped_emd_par ) ;
}


% convert from a plaw_emd parameter set to Aped_emd;
%
define convert_plaw_to_aped_emd( )
{
    %
    % take a model of form "plaw_emd( n )" and convert to form "Aped_emd( m )"
    % usage:   s = convert_plaw_to_aped_emd();   % use defaults
    %          s = convert_plaw_to_aped_emd( n );   % use n for plaw_emd instance; defaults to 1 for Aped_emd
    %          s = convert_plaw_to_aped_emd( n, m );   % use n for plaw_emd instance; m for Aped_emd
    %          s is the resulting fit_fun name.
    %          

    variable r = NULL ; 
    variable n = 1 ;
    variable m = 1 ; 
    variable mfrom = "plaw_dem( $n )"$ ;
    variable mto   = "Aped_emd( $m )"$ ; 
    switch( _NARGS )
    {
	case 0:
    }
    {
	case 1:
	n = () ;
    }
    {
	case 2:
	(n,m) = () ;
    }
    {
	message( "USAGE: s = convert_plaw_to_aped_emd( [n[,m]] );" );
	return( NULL );
    }
    mfrom = "plaw_dem( $n )"$ ;
    mto   = "Aped_emd( $m )"$ ; 
    
    variable s = get_fit_fun;   % save current function
    fit_fun( mfrom );           % establish plaw_emd( $n )

    variable norm     = get_par( "$mfrom.norm"$ );
    variable alpha    = get_par( "$mfrom.alpha"$ );
    variable beta     = get_par( "$mfrom.beta"$ );
    variable tpeak    = get_par( "$mfrom.tpeak"$ );
    variable density  = get_par( "$mfrom.density"$ );
    variable vturb    = get_par( "$mfrom.vturb"$ );
    variable redshift = get_par( "$mfrom.redshift"$ );
    variable mabund   = get_par( "$mfrom.metal_abund"$ );
    variable abund    = get_par( "$mfrom.abund_*"$ ) ; 

    variable t0, t1, t2, y0, y1, y2 ;
    ( t1, t2, t0 ) = emd_get_default_tgrid ;
    y0 = plaw_emd( t0, norm, alpha, beta, tpeak );
    y1 = plaw_emd( t1, norm, alpha, beta, tpeak );
    y2 = plaw_emd( t2, norm, alpha, beta, tpeak );

    % copy the values to the destination model, "Aped_emd($m)";
    % NOTE: this assumes that the tgrid and element list are identical!!! (NO CHECKING)

    fit_fun( mto );

    set_par( "$mto.norm*"$,    	  y1, 1, 0,0 );
    set_par( "$mto.density"$,  	  density, 1,0,0 );
    set_par( "$mto.vturb"$,    	  vturb, 1, 0, 0 );
    set_par( "$mto.redshift"$, 	  redshift, 1, 0, 0 );
    set_par( "$mto.metal_abund"$, mabund, 1, 0, 0 );
    set_par( "$mto.abund_*"$,      abund, 1, 0, 0 );

    fit_fun( s ) ;
    return( mto );
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2012.08.01 dph
%
% get emd and abunds from a par file (along w/ min,max - assuming conf-type par file)
%  Default model name is Aped_emd(1)
%
private variable A_tbl= [ "",
"H",  "He", "Li", "Be", "B",
"C",  "N",  "O",  "F",  "Ne",
"Na", "Mg", "Al", "Si", "P",
"S",  "Cl", "Ar", "K",  "Ca",
"Sc", "Ti", "V",  "Cr", "Mn",
"Fe", "Co", "Ni", "Cu", "Zn",
"Ga", "Ge", "As", "Se", "Br",
"Kr"
];  %that's enough...

% private variable Z_tbl =  [ 0 : length( A_tbl)-1 ]; % to match A_tbl

define get_emd_abunds_from_par()  % ( Fpar, Fname, Fid )
{
    variable Fpar = NULL, Fname = "Aped_emd", Fid = 1 ;

    switch( _NARGS )
    {
	case 1:	Fpar = () ;
    }
    {
	case 2:	( Fpar, Fname ) = () ;
    }
    {
	case 3:	( Fpar, Fname, Fid ) = () ;
    }
    {
	message("USAGE:  s = get_emd_abunds_from_par( [Fpar[, Fname[, Fid ]]] );");
	return( NULL );
    }
	
    variable sfit = get_fit_fun;  % to save/restore

    if ( Fpar != NULL ) load_par( Fpar );

    variable s = "${Fname}(${Fid})"$ ;

    variable r = struct{ t, v, vlo, vhi, a, alo, ahi, z, e } ;

    r.t = get_par( "$s.temperature*"$ );

    variable p = get_params( "$s.norm*"$ );
    r.v   = array_struct_field( p, "value" );
    r.vlo = array_struct_field( p, "min" );
    r.vhi = array_struct_field( p, "max" );
    r.vlo[ where(r.vlo <= 0 ) ] = 0.0 ;
    r.vhi[ where( isinf(r.vhi) ) ] = 1.e10;

    variable i ;

    p = get_params( "$s.abund_*"$ );
    variable t = array_struct_field( p, "name" );

    r.e = String_Type[ length( t ) ] ;
    r.z = Integer_Type[ length( t ) ] ;
    r.a = Double_Type[ length( t ) ];
    r.alo = Double_Type[ length( t ) ];
    r.ahi = Double_Type[ length( t ) ];

    for( i=0; i<length( t ); i++)
    {
	r.e[ i ] = strtok( t[i], "_" )[-1] ;
	r.z[ i ] = where( A_tbl == r.e[ i ] )[0] ; 
	p = get_par_info( t[ i ] ) ;
	r.a[ i ] = p.value ;
	r.alo[ i ] = max( [p.min, 0 ] ) ;
	r.ahi[ i ] = min( [p.max, 99 ] ) ; 
    }

    fit_fun( sfit ); % restore

    return( r ) ;
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% thermal fwhm:   (T in MK?, Wav in A)
define thermal_fwhm( T, Awt, Wav )
{
    return( 1000*2.3548* Wav / 3.e10 * sqrt( 1.38e-16/1.67e-24 * T / Awt ) );;
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2019.01.31
%
% Provide simple powerlaw  EMD (as alternative to broken powerlaw)
%
%
%   D( T ) =  D_1 ( T / T_1 ) ^ \gamma   
%
%  and D means   n_e n_H dV/dT  [ /cm^3 /K ],  differential form
%
%
% Global normalization is usually given in terms of the total Volume
% Emission Measure,
%
%  V  = \int_{T_0}^{T1}{ D(T) dT }
%
%  So  D_1 =  (gamma+1) / T_1 / [ 1 - (T0/T1)^(gamma+1) ]  * V
%    and V will be the APEC "norm",  1.e-14 * V / (4pi d^2).
%
%
%
private variable plaw_dem2_par = struct{ norm, LogTmin, LogTmax, gamma } ;


define calc_dem2( tg, n, g, t0, t1 )
{
    variable w 	 = Double_Type[ length( tg ) ] ;
    variable l 	 = where( tg >= t0 and tg <= t1);
    variable gp1 = g + 1.0 ;  
    variable k ;

    if ( g != -1 )
    {
	k =   gp1 / t1 / ( 1.0 - (t0/t1)^gp1 ) ;
    }
    else
    {
	k =  1.0 / ( t1 * log( t1 / t0 ) ) ;
    }

    w[ l ] =  n * k * ( tg[l] / t1 ) ^ g ;

    return( w );
}

% define a finer tgrid apec emd model, w/ about 0.05 dex grid
% this is so we don't overflow the Aped_emd 26-T model grid:
%
private variable emd_nTx = 2* emd_nT;  % need finer grid emd model
_Aped( emd_nTx, "Aped_emdx" );     % extended grid model for internal use

define mk_tgrid( t0dex, t1dex )
{
    variable logTrange = t1dex - t0dex ; 
    variable ddex  = 0.05 ; % default log10 temperature grid step size
    %variable ntg   = min(  [ int( ceil( logTrange / ddex )), emd_nT ]  ) ;
    variable ntg   = min(  [ int( ceil( logTrange / ddex )), emd_nTx ]  ) ;
    variable dlogT = logTrange / ntg ; 

    % to avoid insignificant numerical gridding issues which can
    % affect parameter-to-grid comparisons, truncate 0.0001 dex
    dlogT = round( dlogT*10000. ) / 10000. ; 

    variable dlnT  = dlogT / log10( E ) ; 
    variable tg    = 10^( [ t0dex : t1dex : dlogT ] ) ;

    % Aped_emd model expects a 26-T grid.
    %  Pad it on the low side to abouut 6.0, and high to about 8.5;
    %  Details won't matter because the norms will be 0.0 for those ranges:

    %while (   length( tg ) <  emd_nT )
    while (   length( tg ) <  emd_nTx ) 
    {
	if ( tg[0] > emd_t_lo[0] )
	{
	    tg = [ tg[0] / 10^dlogT , tg ] ;
	    %if ( length( tg )  == emd_nT ) return( tg, dlnT );
	    if ( length( tg )  == emd_nTx ) return( tg, dlnT );
	}
	if ( tg[-1] < emd_t_hi[-1] )
	{
	    tg = [ tg, tg[-1] * 10^dlogT ] ;
	    %if ( length( tg ) == emd_nT ) return( tg, dlnT );
	    if ( length( tg ) == emd_nTx ) return( tg, dlnT );
	}
    }
    return( tg, dlnT );
}


public define plaw_dem2_fit( lo, hi, par )
{
    % powerlaw emission measure parameters:
    %
    variable norm   = par[0] ;     %   1.e-14 * VEM / 4PId^2 ;
    variable gamma  = par[1] ;     %   exponent on T

    % to help avoid numerical issues in comparison to grid values,
    % truncate temperature bounds to some number << model resolution:

    variable T0_dex = par[2] ; 
    variable T1_dex = par[3] ; 

    T0_dex = round( T0_dex * 10000 ) / 10000. ;
    T1_dex = round( T1_dex * 10000 ) / 10000. ;

    variable T0     = 10^T0_dex ;  %   lower limit of DEM range
    variable T1     = 10^T1_dex ;  %   upper limit of DEM range

    % test for T1 > T0
    if ( T0 >= T1 ) error("%% LogTmax must be greater than LogTmin");

    % also need other plasma parameters:
    %
    %     density     = par[4] ;
    %     vturb       = par[5] ;
    %     redshift    = par[6] ;
    %     metal_abund = par[7] ; 
    %     abund       = par[ [8:] ] ;

    %      metal abundances: => Default_Elem_List
    %       He C N O Ne Mg Al Si S Ar Ca Fe Ni
    %    

    % Next need to use the params in the Aped_emd function:

    % The spectrum should be the integral of emissivity*emission_measure over dT.
    % We have a regular grid in logT, so the DEM weights should be scaled 
    %  by  T * dlnT

    % 2019.02.20 dph
    % modify: using the default emd grid introduces discretization in the temperature parameters,
    % which showed strongly in conf maps. To avoid this, define a local, custom grid from T0 to T1
    % at approximately 0.05 dex steps.
    %
    variable tg, dlnT ;
    ( tg, dlnT ) = mk_tgrid( T0_dex, T1_dex );

    variable a = calc_dem2( tg, norm, gamma, T0, T1 );
    variable w = a * tg * dlnT ; 
    %variable y = eval_fun2( "Aped_emd", lo, hi, [ w, tg, par[[4:]] ] ) ;
    variable y = eval_fun2( "Aped_emdx", lo, hi, [ w, tg, par[[4:]] ] ) ;

    return( y ) ; 
}

define plaw_dem2_par_to_plasma_state( Par )
{
    variable par, norm, gamma, T0, T1 ; 

    switch (typeof( Par ) )
    {
	case String_Type:
	par = get_par( "$Par.*"$ ) ;
    }
    {
	case Array_Type:
	par = @Par ;
    }	
    {
	error( "%%  p = plaw_dem2_par_to_plasma_state( model_name | param_array );");
    }

    norm  = par[0] ;     %   1.e-14 * VEM / 4PId^2 ;
    gamma = par[1] ;     %   exponent on T
    T0    = 10^par[2] ;  %   lower limit of DEM range
    T1    = 10^par[3] ;  %   upper limit of DEM range

    % test for T1 > T0
    if ( T0 >= T1 ) error("%% LogTmax must be greater than LogTmin");

    variable a = calc_dem2( emd_t_mid, norm, gamma, T0, T1 );
    variable w = a * emd_t_mid * emd_dlnt ; 
    variable r = default_plasma_state ; 
    r.norm        = @w ;
    r.temperature = @emd_t_mid ; 
    r.density  	  = par[ 4 ] ;
    r.vturb    	  = par[ 5 ] ;
    r.redshift 	  = par[ 6 ] ;
    r.metal_abund = par[ 7 ];
    r.elem_abund  = par[ [8: ] ];
    r.elem        = @Default_Elem_List ; 
    
    return( r ) ; 
}


private variable params = [
  "norm",
  "gamma",
  "LogTmin",
  "LogTmax",
  "density",
  "vturb",
  "redshift",
  "metal_abund", 
  "abund_" + Default_Elem_SList
] ;

add_slang_function( "plaw_dem2", params ) ;

define plaw_dem2_defaults( n )
{
    switch( n )
    {
	case 0:  % norm
	return( 1.0 , 0, 0.0, 1000 ); 
    }
    {
	case 1: % gamma
	return( -1.0, 0, -10, 10 ) ;
    }
    {
	case 2: % LogTmin
	return( 6.0, 1, 6.0, 8.5 ) ;
    }
    {
	case 3: %  LogTMax
	return( 8.5, 1, 6.1, 8.5 ) ;
    }
    {
	case 4: %  density
	return( 1.0, 1, 0, 0 ) ;
    }
    {
	case 5: % vturb
	return( 0.0, 1, 0, 0 ) ;
    }
    {
	case 6: % redshift
	return( 0.0, 1, -1, 1 ) ;
    }
    % the rest, 7-end, are abundances:
    {
	return( 1.0, 1, 0, 10 ) ;
    }
}

set_param_default_hook( "plaw_dem2", "plaw_dem2_defaults" ) ; 



%
provide("Aped_utils");
