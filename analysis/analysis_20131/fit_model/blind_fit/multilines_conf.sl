%This file does the following:
% 1. load X-ray data files from a desired directory
% 2. define a function describing the continuum spectrum
% 3. set the parameters of the continuum spectrum
% 4. plot the graph with both data and the model that fits the continuum spectrum
% 5. define a new function, which just adds multiple emission lines in a certain range using voigt profile to the previous function
% 6. set the parameters of the voigt profile
% 7. start the fitting 
% 8. plot the graph again

% Output: some parameter information in the command window and one .ps files




_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");

%%%%%%%% read data %%%%%%%%
variable pdir = "/home/xliu/20131/parts/part1/";

mp1 = load_data(pdir+"meg_1.pha");
mm1 = load_data(pdir+"meg_-1.pha");
meg = add_orders(mp1, mm1);

arfp1 = load_arf(pdir+"meg_1.arf");
arfm1 = load_arf(pdir+"meg_-1.arf");
marf = add_arfs(arfp1, arfm1);

mrmf = load_rmf(pdir+"meg_1.rmf");

hp1 = load_data(pdir+"heg_1.pha");
hm1 = load_data(pdir+"heg_-1.pha");
heg = add_orders(hp1, hm1);

harfp1 = load_arf(pdir+"heg_1.arf");
harfm1 = load_arf(pdir+"heg_-1.arf");
harf = add_arfs( harfp1, harfm1);

hrmf = load_rmf(pdir+"heg_1.rmf");

%%%%%% Assign ARF/RMF pairs to a specific spectrum %%%%%%
assign_rsp( marf, mrmf, meg);
assign_rsp( harf, hrmf, heg);

%%%%%% Compute the flux corrected spectrum %%%%%%

flux_corr(meg, 2);
flux_corr(heg, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% define the function (now only the continuum spectrum) to fit %%%%%%
fit_fun("wabs(1)*Powerlaw(1)");
%%%%%% see what parameters there are %%%%%%
list_par;

%%%%%% define approx. continuum parameters %%%%%%
nh = 0.5;
norm_pl = 0.0126;
gamma = 0.86;

%%%%%% Set continuum parameters %%%%%%
set_par(1, nh, 1);
set_par(2, norm_pl);
set_par(3, -gamma, 0, -5, 3);


%%%%%% Automatically adjust fit normalization %%%%%
() = renorm_counts();


%%%%%% now add one emission line to the previous function using voigt profile %%%%%

lines = [1.65, 1.85, 1.93, 1.94]; % set the line centers
guess_flux = [100, 220, 1000, 800]; % estimate the fluxes of lines
lam = [1.4,2];

n = length(lines);


fun_string = "wabs(1)*Powerlaw(1)";

i = 0; while (i < n){
    fun_string = fun_string + "+voigt("+string(i+1)+")";
    i = i+1;
}
fit_fun(fun_string);
list_par;



i = 0; while (i < n) {
    c = lines[i];
    g = guess_flux[i]/1000000;
    dlam = max( [0.02,c *(0.03/7.)]); % set a range of the line center for fitting
%%%%%% set the parameters of the voigt profile; search what each  parameter does %%%%%
    set_par(4 + 4*i, g, 0, g/4., 5*g);  
    set_par(5 + 4*i, _A(c), 0, _A(c+dlam), _A(c-dlam) ); %_A converts angstrom to energy 
    set_par(6 + 4*i, 0.001, 1);
    set_par(7 + 4*i, 2300./100000, 0, 1000./100000, 4000./100000);
    i = i+1;
}
list_par;


%%%%% start the fitting (not sure why using two methods though)%%%%%%%%%%
set_fit_statistic("cash");
set_fit_method("subplex");
() = fit_counts;
set_fit_method("marquardt");
() = fit_counts;

save_par("par_test.txt");
%set_fit_statistic("cash");
%load_par("par_test.txt");
%() = fit_counts(;fit_verbose=1);

%%%%% plot the data and the model with the continuum spectrum and one line"

() = open_plot("lines_range1.ps/cps", 1, 3);
xrange(1.5,2.2);
rplot_counts(heg);
get_convolved_model_flux(heg);

close_plot();


%%%%% Using conf loop to find errors for each parameter %%%%%%

fp = fopen("lineinfo1.txt", "w"); %open a file to write line info in 



variable nrg_sigma;

%%%find errors for the flux of the line %%%%%
i = 0; while (i < n){
  freeze([4:4*n+3]);
  idx = 4*i+4;
  thaw(idx+[0,1]); % allow normalizations and line centers to vary while searching for the best fit to the data.
  f = 1000000*get_par(idx);
  (lo_flux, hi_flux) = conf(idx, 0);
  if (lo_flux == hi_flux ) (lo_flux, hi_flux) = conf(idx, 0);
  if (lo_flux == hi_flux ) (lo_flux, hi_flux) = conf(idx, 0);
  flux_sigma = 1000000*(0.5*(hi_flux-lo_flux));


%%%find errors for the center of the line %%%%%
  idx = 5 + 4*i;
  w = _A( get_par(idx) );
  (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  if (lo_wave == hi_wave ) (lo_wave, hi_wave) = conf(idx, 0);
  nrg_sigma = 0.5*(hi_wave-lo_wave);
  wave_sigma = nrg_sigma * w^2 / Const_hc;

  idx = 7 + 4*i;
  s = get_par(idx); 
  thaw(idx);
  (lo_width, hi_width) = conf(idx, 0);
  if (lo_width == hi_width ) (lo_width, hi_width) = conf(idx, 0);
  if (lo_width == hi_width ) (lo_width, hi_width) = conf(idx, 0);
  width_sigma = 0.5*(hi_width-lo_width);




  
  ok = fprintf (fp, "%8.3f %8.3f %8.1f %8.1f %8.4f %8.4f\n", w, wave_sigma, f, flux_sigma, s, width_sigma);
  i = i+1;

}


quit();
