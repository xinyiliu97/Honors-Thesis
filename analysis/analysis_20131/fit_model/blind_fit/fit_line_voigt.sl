% fit_lines.sl
% requires three arrays to be defined:
%  fp = file pointer
%  lam = wavelength boundaries to notice
%  lines = list of line wavelengths
%  guess_flux = estimates of line fluxes

% work on a wavelength group
ignore(all_data);
notice([heg],lam[0], min( [lam[1], 12] ));
notice([meg],max( [1.75,lam[0]] ), min( [lam[1], 16.5] ));
ignore([heg,meg], lam_ignore[0], lam_ignore[1]);

n = length(lines);
flux_est = guess_flux/1000000.;

% Define the fitting function with different number of emission lines using a for loop
fun_string = "wabs(1)*Powerlaw(1)";
i = 0; while (i < n){
   fun_string = fun_string + "+voigt("+string(i+1)+")";
   i = i+1;
}
fit_fun(fun_string);

% Set approx. continuum parameters
set_par(1, nh, 1);
set_par(2, norm_pl);
set_par(3, -gamma, 0, -5, 3);

variable dlam;

% Here is the for loop. i is the number of lines in each range. Set voigt parameters, freezing the centers and sigma
i = 0; while (i < n){
   g = flux_est[i]; c = lines[i];
   dlam = max( [0.02,lines[i]*(0.03/7.)] );
   set_par(4 + 4*i, g, 0, g/4., 5*g);  
   set_par(5 + 4*i, _A(c), 0, _A(c+dlam), _A(c-dlam) );
   set_par(6 + 4*i, 0.001, 1);
   set_par(7 + 4*i, 2300./100000, 0, 1000./100000, 4000./100000);
   i = i+1;
}

% allow one sigma to float
tie(7, [11:4*n+3:4]);
() = renorm_counts();
set_fit_method("subplex");
() = fit_counts;
set_fit_method("marquardt");
() = fit_counts;

list_par;

limits;
xrange(lam[0], lam[1]);
plot_data_flux(heg);
oplot_model_flux(heg);
plot_data_flux(meg);
oplot_model_flux(meg);


%%%%%%%%%% You do not need to worry about conf() loop right now %%%%%%%%%%%%%%%%%%
idx = 7;
s = get_par(idx);
(lo_width, hi_width) = conf(idx, 0);
if (lo_width == hi_width ) (lo_width, hi_width) = conf(idx, 0);
if (lo_width == hi_width ) (lo_width, hi_width) = conf(idx, 0);
width_sigma = 0.5*(hi_width-lo_width);

variable nrg_sigma;

i = 0; while (i < n){
  freeze([4:4*n+3]);
  idx = 4*i+4;
  thaw(idx+[0,1]);
  f = 1000000*get_par(idx);
  (lo_flux, hi_flux) = conf(idx, 0);
  if (lo_flux == hi_flux ) (lo_flux, hi_flux) = conf(idx, 0);
  if (lo_flux == hi_flux ) (lo_flux, hi_flux) = conf(idx, 0);
  flux_sigma = 1000000*(0.5*(hi_flux-lo_flux));

  
  idx = 5 + 4*i;
  w = _A( get_par(idx) );
  (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  nrg_sigma = 0.5*(hi_wave-lo_wave);
  wave_sigma = nrg_sigma * w^2 / Const_hc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  ok = fprintf (fp, "%8.3f %8.3f %8.1f %8.1f\n", w, wave_sigma, f, flux_sigma);
  
  %ok = fprintf (fp, "%8.4f\n %7.4f\n %10.7f\n %10.7f\n", w,
  %    wave_sigma, f, flux_sigma);
  i = i+1;
}

