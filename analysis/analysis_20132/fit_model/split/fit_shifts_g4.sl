_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");
require("add_observations");

define redshift_fit(lo, hi, par)
{
   return 1.0;
}
add_slang_function ("redshift", "z");

define rest_wave_fit(lo, hi, par)
{
   return 1.0;
}
add_slang_function ("rest_wave", "lambda");

define sigma_fit(lo, hi, par)
{
   return 1.0;
}
add_slang_function ("sigma", "beta");


print("Starting");

% set up RMFs for each data set
meg_rmf = load_rmf("timesel/part0/meg_1.rmf");
heg_rmf = load_rmf("timesel/part0/heg_1.rmf");
mrmf = meg_rmf;
hrmf = heg_rmf;

% read data
nparts = 7;
heg = Integer_Type[nparts];
meg = Integer_Type[nparts];

for (i=0; i<nparts; i++) {
    variable s = string(i);
    variable pdir = "timesel/part"+s+"/";
    h1 = load_data(pdir+"heg_1.pha");
    h2 = load_data(pdir+"heg_-1.pha");
    heg_arfm1 = load_arf(pdir+"heg_1.arf");
    heg_arfp1 = load_arf(pdir+"heg_-1.arf");

    m1 = load_data(pdir+"meg_1.pha");
    m2 = load_data(pdir+"meg_-1.pha");
    meg_arfm1 = load_arf(pdir+"meg_1.arf");
    meg_arfp1 = load_arf(pdir+"meg_-1.arf");

    heg[i] = add_orders(h1, h2);
    harf = add_arfs( heg_arfm1, heg_arfp1 );

    meg[i] = add_orders(m1, m2);
    marf = add_arfs( meg_arfm1, meg_arfp1 );
    
    assign_rsp(harf, hrmf, heg[i]);
    assign_rsp(marf, mrmf, meg[i]);
}


% prepare a plot
variable device, id;
device = "fit_lines_parts_fixsigma.ps/cps";
id = open_plot(device, 1,2);

for (ipart=0; ipart<nparts; ipart++) {
   ignore(all_data);
   group_data(meg[ipart], 4);
   group_data(heg[ipart], 4);
   ignore(heg[ipart], 11.8,100);
   ignore(meg[ipart], 14,100);
   ignore(heg[ipart], 0, 1.25);
   ignore(meg[ipart], 0,1.6);

   load_par("line_errs_g4.txt");

   variable gpi;

   for(i=22;i<64;i++) {
      gpi = get_par_info(i);
      set_par(i, gpi.value, 1);
   }

   set_par(1, (get_par_info(1)).value, 0, -0.05, 0.015);
   set_par(2, (get_par_info(2)).value, 0, 0.015, 0.12);
   set_par(3, (get_par_info(3)).value, 1);
   set_par(4, (get_par_info(4)).value, 1);
   set_par(5, (get_par_info(5)).value, 1);
   set_par(20, (get_par_info(20)).value, 0, .0035, .006);
   set_par(21, (get_par_info(21)).value, 0, 1.2, 2.5);

   set_fit_method("subplex");
   set_fit_statistic("cash");
   () = fit_counts(;fit_verbose=1);

   % for part0
%  Parameters[Variable] = 63[7]
%             Data bins = 1674
%            Cash Statistic = 1751.843
%    Reduced Cash Statistic = 1.050896

   limits;
   plot_bin_density;

   % some nice ways to check out the results
   Isis_Residual_Plot_Type = STAT;
   errorbars(3);
   xrange(6,8);

% provide a more informative label
   s = string(ipart);
   title( "MEG part"+s);
   rplot_counts(meg[ipart]);

   xrange(1.2, 2.5);
   title( "HEG part"+s);
   rplot_counts(heg[ipart]);

   print("Getting Confidence Parameters, part "+s);

   (pmin, pmax) = conf_loop( NULL, 0; cl_verbose=1, save,
      prefix="conf_loop/pars_fixsigma_part"+s, num_slaves=4);

   wpar = [1,2,20,21];
%   wpar = [1,2,3,4,20];
   npar = length(wpar);

   fp = fopen ("part"+s+"_paramvalues_fixsigma.txt", "w");
   () = fprintf (fp, "        Parameter     Value        Err  \n");
   for(i=0;i<4;i++) {
      idx = wpar[i];
      gpi = get_par_info(idx);
      variable val=gpi.value, err=0.5*(pmax[i]-pmin[i]);
      () = fprintf (fp, "%20s %10.3e %10.3e\n", gpi.name, val, err);
   }
   () = fclose(fp);

   variable v = get_outer_viewport();
   v.xmin = 0.2;
   v.xmax = 0.8;
   v.ymin = 0.1;
   v.ymax = 0.9;
   set_outer_viewport(v);
   ls = line_label_default_style ();
   ls.char_height = 1.3;
   ls.top_frac = 0.75;
   ls.bottom_frac = 0.7;
   ls.angle = 45.;

   plot_bin_integral;

   charsize(1.8);
   xlabel( latex2pg("Wavelength (\\A)") );
%   ylabel( latex2pg("Flux (ph/cm^{2}/s/\\A)" ) );

   title( "HEG part"+s);
   xrange(1.25, 3);
   plot_data_counts(heg[ipart]);
   oplot_model_counts(heg[ipart]);

   title( "MEG part"+s);
   xrange(4.5,10);
   plot_data_counts(meg[ipart]);
   oplot_model_counts(meg[ipart]);
}

plot_close (id);
