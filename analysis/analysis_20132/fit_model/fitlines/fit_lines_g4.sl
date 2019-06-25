% plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");

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
% read data
variable pdir = "/home/xliu/20132/";

mp1 = load_data(pdir+"meg_1.pha");
mm1 = load_data(pdir+"meg_-1.pha");
meg = add_orders(mp1, mm1);

arfp1 = load_arf(pdir+"meg_1.arf");
arfm1 = load_arf(pdir+"meg_-1.arf");
marf = add_arfs( arfp1, arfm1);

mrmf = load_rmf(pdir+"meg_1.rmf");

hp1 = load_data(pdir+"heg_1.pha");
hm1 = load_data(pdir+"heg_-1.pha");
heg = add_orders(hp1, hm1);

harfp1 = load_arf(pdir+"heg_1.arf");
harfm1 = load_arf(pdir+"heg_-1.arf");
harf = add_arfs( harfp1, harfm1);

hrmf = load_rmf(pdir+"heg_1.rmf");

%%%%%%%  Done loading observations %%%%%%
assign_rsp( marf, mrmf, meg);
assign_rsp( harf, hrmf, heg);

limits;

ignore(all_data);
group_data(meg, 4);
group_data(heg, 4);
% notice(heg, 1.25, 11.8);
% notice(meg, 1.6, 14);
ignore(heg, 11.8,100);
ignore(meg, 14,100);
ignore(heg, 0, 1.25);
ignore(meg, 0,1.6);

plot_bin_density;
% flux_corr(meg, 2);
% flux_corr(heg, 2);
%flux_corr(megn, 2);
%flux_corr(hegn, 2);

variable n = 16;
line_wave = Double_Type[n];
% Mg12
line_wave[0] = (2*8.4193 + 8.4247) / 3.;
% Si13r ... FIXED on 1/11/17
line_wave[1] = 6.64795;
% Si13i
line_wave[2] = 0.5 * (6.68499+6.68819);
% Si13f
line_wave[3] = 6.74029;
% Si14
line_wave[4] = (2*6.18050 + 6.1859) / 3.;
% S15
line_wave[5] = 5.0553;
% S16
line_wave[6] = (2*4.72740 + 4.73280) / 3.;
% Fe25
line_wave[7] = 1.8545;
% Fe26
line_wave[8] = (2*1.77810 + 1.78350) / 3.;
% Fe1
line_wave[9] = 1.9374;
% Si1
line_wave[10] = 7.1264;
% Ne10
line_wave[11] = 12.1351;
% Ni1
% line_wave[12] = (2*1.6579 + 1.6618) / 3.;
line_wave[12] = 1.5883;
% Mg11r
line_wave[13] = 9.1688;
% Mg11i
line_wave[14] = 0.5 * (9.2282+9.2312);
% Mg11f
line_wave[15] = 9.3143;

fit_fun("wabs(1) * powerlaw(1)");
set_par("wabs(1).nH", 0.8, 0);
set_par("powerlaw(1).norm", 0.00658);
set_par("powerlaw(1).PhoIndex", 1.787);
() = renorm_counts();

variable delz = 0.015, z1_est = -0.01;
variable r1 = 1 + delz, r2 = 1-delz;
variable hi_wave = line_wave * r1, lo_wave = line_wave * r2;
variable z1_max = z1_est + delz, z1_min = z1_est - delz;

fit_fun("redshift(1) * sigma(1) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) ) * " +
  "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) )");
set_par("redshift(1).z", z1_est, 0, z1_min, z1_max);
set_par("sigma(1).beta", 0.005, 0, 0.0025, 0.01);
set_par("rest_wave(1).lambda", line_wave[4], 1);
set_par("rest_wave(2).lambda", line_wave[0], 1);
set_par("rest_wave(3).lambda", line_wave[11], 1);
set_par("rest_wave(4).lambda", line_wave[5], 1);

set_par("gauss(1).center", "(1+redshift(1).z)*rest_wave(1).lambda", 1, 0, 40);
set_par("gauss(2).center", "(1+redshift(1).z)*rest_wave(2).lambda", 1, 0, 40);
set_par("gauss(3).center", "(1+redshift(1).z)*rest_wave(3).lambda", 1, 0, 40);
set_par("gauss(4).center", "(1+redshift(1).z)*rest_wave(4).lambda", 1, 0, 40);

% set v/c to a reasonable value and range

set_par("gauss(1).sigma", "(1+redshift(1).z)*rest_wave(1).lambda*sigma(1).beta", 1);
set_par("gauss(2).sigma", "(1+redshift(1).z)*rest_wave(2).lambda*sigma(1).beta", 1);
set_par("gauss(3).sigma", "(1+redshift(1).z)*rest_wave(3).lambda*sigma(1).beta", 1);
set_par("gauss(4).sigma", "(1+redshift(1).z)*rest_wave(4).lambda*sigma(1).beta", 1);
set_par("gauss(?).area", 0.001);

% load_par("aped_4Tpar_est.txt");

list_par;
set_fit_method("subplex");
set_fit_statistic("cash");
() = fit_counts(;fit_verbose=1);

% Parameters[Variable] = 21[9]
%             Data bins = 3349
%            Cash Statistic = 4566.658
%    Reduced Cash Statistic = 1.367263

% x4 grouping
%  Parameters[Variable] = 21[9]
%             Data bins = 1674
%            Cash Statistic = 2604.488
%    Reduced Cash Statistic = 1.564257

save_par("par_4lines_g4.txt");


% % add a fluorescent line and continue
% 
% fit_fun("redshift(1) * sigma(1) * sigma(2) * wabs(1) * " +
%   "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) * rest_wave(5) ) * " +
%   "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) + gauss(5) )");
% 
% set_par("rest_wave(5).lambda", line_wave[9], 1);
% set_par("sigma(2).beta", 0.002, 0, 0.001, 0.02);
% set_par("gauss(5).center", "rest_wave(5).lambda", 1, 0, 40);
% 
% % set v/c to a reasonable value and range
% set_par("gauss(5).sigma", "rest_wave(5).lambda*sigma(2).beta", 1);
% set_par("gauss(5).area", 0.001);
% 
% () = fit_counts(;fit_verbose=1);
% save_par("par_5lines.txt");


% add Si XIII and continue

fit_fun("redshift(1) * sigma(1) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * " +
  "rest_wave(4) * rest_wave(5) * rest_wave(6) * rest_wave(7) ) * " +
  "( powerlaw(1) + gauss(1) + gauss(2) + " +
  " gauss(3) + gauss(4) + gauss(5) + gauss(6) + gauss(7))");

set_par("rest_wave(5).lambda", line_wave[1], 1);
set_par("rest_wave(6).lambda", line_wave[2], 1);
set_par("rest_wave(7).lambda", line_wave[3], 1);
set_par("gauss(5).center", "(1+redshift(1).z)*rest_wave(5).lambda", 1, 0, 40);
set_par("gauss(6).center", "(1+redshift(1).z)*rest_wave(6).lambda", 1, 0, 40);
set_par("gauss(7).center", "(1+redshift(1).z)*rest_wave(7).lambda", 1, 0, 40);

% set v/c to a reasonable value and range
set_par("gauss(5).sigma", "(1+redshift(1).z)*rest_wave(5).lambda*sigma(1).beta", 1);
set_par("gauss(6).sigma", "(1+redshift(1).z)*rest_wave(6).lambda*sigma(1).beta", 1);
set_par("gauss(7).sigma", "(1+redshift(1).z)*rest_wave(7).lambda*sigma(1).beta", 1);
set_par("gauss(5).area", get_par("gauss(1).area"));
% set_par_fun("gauss(6).area", NULL);
set_par("gauss(6).area", 0.001, 0);
% set_par_fun("gauss(7).area", NULL);
set_par("gauss(7).area", 0.001, 0);

() = fit_counts(;fit_verbose=1);

%  Parameters[Variable] = 33[12]
%             Data bins = 3349
%            Cash Statistic = 4014.087
%    Reduced Cash Statistic = 1.202903

%  Parameters[Variable] = 33[12]
%             Data bins = 1674
%            Cash Statistic = 2127.188
%    Reduced Cash Statistic = 1.279896

save_par("par_5lines_g4.txt");

% add redshifted Fe XXV and Fe XXVI and continue

fit_fun("redshift(1) * redshift(2) * sigma(1) * sigma(2) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) * " +
  "rest_wave(5) * rest_wave(6) * rest_wave(7) * rest_wave(8) * rest_wave(9) ) * " +
  "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) + " +
  " gauss(5) + gauss(6) + gauss(7) + gauss(8) + gauss(9))");

set_par("redshift(2).z", 0.05, 0, .02, .09);
set_par("sigma(2).beta", 0.005, 0, 0.0025, 0.01);
set_par("rest_wave(8).lambda", line_wave[7], 1);
set_par("rest_wave(9).lambda", line_wave[8], 1);
set_par("gauss(8).center", "(1+redshift(2).z)*rest_wave(8).lambda", 1, 0, 40);
set_par("gauss(9).center", "(1+redshift(2).z)*rest_wave(9).lambda", 1, 0, 40);

% set v/c to a reasonable value and range
set_par("gauss(8).sigma", "(1+redshift(2).z)*rest_wave(8).lambda*sigma(2).beta", 1);
set_par("gauss(9).sigma", "(1+redshift(2).z)*rest_wave(9).lambda*sigma(2).beta", 1);
set_par("gauss(8).area", 0.2*get_par("gauss(1).area"));
set_par("gauss(9).area", 0.2*get_par("gauss(1).area"));

() = fit_counts(;fit_verbose=1);
save_par("par_7lines_g4.txt");

%  Parameters[Variable] = 43[16]
%             Data bins = 3349
%            Cash Statistic = 3844.46
%    Reduced Cash Statistic = 1.153453

%  Parameters[Variable] = 43[16]
%             Data bins = 1674
%            Cash Statistic = 1917.887
%    Reduced Cash Statistic = 1.156747

% add Mg XI and continue

fit_fun("redshift(1) * redshift(2) * sigma(1) * sigma(2) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) * " +
  "rest_wave(5) * rest_wave(6) * rest_wave(7) * rest_wave(8) *" +
  " rest_wave(9) * rest_wave(10) * rest_wave(11) * rest_wave(12)) * " +
  "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) + " +
  " gauss(5) + gauss(6) + gauss(7) + gauss(8) + gauss(9) +" +
  " gauss(10) + gauss(11) + gauss(12))");

set_par("rest_wave(10).lambda", line_wave[13], 1);
set_par("rest_wave(11).lambda", line_wave[14], 1);
set_par("rest_wave(12).lambda", line_wave[15], 1);
set_par("gauss(10).center", "(1+redshift(1).z)*rest_wave(10).lambda", 1, 0, 40);
set_par("gauss(11).center", "(1+redshift(1).z)*rest_wave(11).lambda", 1, 0, 40);
set_par("gauss(12).center", "(1+redshift(1).z)*rest_wave(12).lambda", 1, 0, 40);

% set v/c to a reasonable value and range
set_par("gauss(10).sigma", "(1+redshift(1).z)*rest_wave(10).lambda*sigma(1).beta", 1);
set_par("gauss(11).sigma", "(1+redshift(1).z)*rest_wave(11).lambda*sigma(1).beta", 1);
set_par("gauss(12).sigma", "(1+redshift(1).z)*rest_wave(12).lambda*sigma(1).beta", 1);
set_par("gauss(10).area", 0.3*get_par("gauss(1).area"));
set_par("gauss(11).area", 0.3*get_par("gauss(1).area"));
set_par("gauss(12).area", 0.3*get_par("gauss(1).area"));

() = fit_counts(;fit_verbose=1);
%  Parameters[Variable] = 55[19]
%             Data bins = 3349
%            Cash Statistic = 3745.626
%    Reduced Cash Statistic = 1.124813

%  Parameters[Variable] = 55[19]
%             Data bins = 1674
%            Cash Statistic = 1815.922
%    Reduced Cash Statistic = 1.097234

save_par("par_8lines_g4.txt");

% Finally, add Ni 27 (red) and Fe 25 (blue)

fit_fun("redshift(1) * redshift(2) * sigma(1) * sigma(2) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) * " +
  "rest_wave(5) * rest_wave(6) * rest_wave(7) * rest_wave(8) * rest_wave(9) * " +
  " rest_wave(10) * rest_wave(11) * rest_wave(12) * rest_wave(13) * rest_wave(14)) * " +
  "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) + " +
  " gauss(5) + gauss(6) + gauss(7) + gauss(8) + gauss(9) +" +
  " gauss(10) + gauss(11) + gauss(12) + gauss(13) + gauss(14))");

set_par("rest_wave(13).lambda", line_wave[12], 1);
set_par("rest_wave(14).lambda", line_wave[7], 1);
set_par("gauss(13).center", "(1+redshift(2).z)*rest_wave(13).lambda", 1, 0, 40);
set_par("gauss(14).center", "(1+redshift(1).z)*rest_wave(14).lambda", 1, 0, 40);

% set v/c to a reasonable value and range
set_par("gauss(13).sigma", "(1+redshift(2).z)*rest_wave(13).lambda*sigma(2).beta", 1);
set_par("gauss(13).area", 0.5*get_par("gauss(8).area"));
set_par("gauss(14).sigma", "(1+redshift(1).z)*rest_wave(14).lambda*sigma(1).beta", 1);
set_par("gauss(14).area", 0.5*get_par("gauss(8).area"));

() = fit_counts(;fit_verbose=1);
%  Parameters[Variable] = 63[21]
%             Data bins = 3349
%            Cash Statistic = 3730.894
%    Reduced Cash Statistic = 1.121062

%  Parameters[Variable] = 63[21]
%             Data bins = 1674
%            Cash Statistic = 1802.352
%    Reduced Cash Statistic = 1.090352

set_par("sigma(2).beta", get_par("sigma(2).beta"), 0, 0.005, 0.015);
() = fit_counts(;fit_verbose=1);

%  Parameters[Variable] = 63[21]
%             Data bins = 1674
%            Cash Statistic = 1802.216
%    Reduced Cash Statistic = 1.09027

save_par("par_9lines_g4.txt");


% some nice ways to check out the results
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(1.7, 14);
rplot_counts(meg);
xrange(6,8);
rplot_counts(meg);

xrange(1.2, 12);
rplot_counts(heg);
xrange(4.5, 9.5);
rplot_counts(heg);

xrange(1.2, 2.5);
rplot_counts(heg);




print("Getting Confidence Parameters");

(pmin, pmax) = conf_loop( [1,2,3,4], 0; cl_verbose=1, save,
   prefix="conf_loop/pars_all_lines", num_slaves=7);

fp = fopen ("paramvalues.txt", "w");
() = fprintf (fp, "        Parameter     Value        Err  \n");
for(i=0;i<4;i++) {
   gpi = get_par_info(i+1);
   variable val=gpi.value, err=0.5*(pmax[i]-pmin[i]);
   () = fprintf (fp, "%20s %10.3e %10.3e\n", gpi.name, val, err);
}
() = fclose(fp);

%prepare for loop over all line normalizations
%load_par("pars_all_lines.txt");
load_par("par_9lines_g4.txt");
wline = [23,26,29,32,35,38,47,50,59,62];
nline = length(wline);

% % this is just a test
% for(i=0;i<nline;i++) {
%    idx = wline[i];
%    gpi = get_par_info( idx );
%    variable val=gpi.value;
%    () = printf( "%2d %2d %20s %10.3e\n", i, idx, gpi.name, val);
% }

for(i=0;i<nline;i++) {
   idx = wline[i];
   gpi = get_par_info( idx );
   variable val=gpi.value;
   set_par(idx, val, 0, 0.3*val, 3.0*val);
}

(pmin, pmax) = conf_loop( NULL, 0; cl_verbose=1, save,
   prefix="conf_loop/pars_all", num_slaves=7);

wpar = [1,2,3,4,5,20,21,22,25,28,31,34,37,40,43,46,49,52,55,58,61];
npar = length(wpar);

fp = fopen ("all_paramvalues.txt", "w");
() = fprintf (fp, "        Parameter     Value        Err  \n");
for(i=0;i<18;i++) {
   idx = wpar[i];
   gpi = get_par_info(idx);
   variable val=gpi.value, err=0.5*(pmax[i]-pmin[i]);
   () = fprintf (fp, "%20s %10.3e %10.3e\n", gpi.name, val, err);
}
() = fclose(fp);

print("Creating Plot");

flux_corr(heg);
flux_corr(meg);

% prepare a plot
variable device, id;
device = "fit_lines_alldata.ps/cps";
id = open_plot(device, 1,2);

variable v = get_outer_viewport();
v.xmin = 0.2;
v.xmax = 0.8;
v.ymin = 0.1;
v.ymax = 0.9;
set_outer_viewport(v);
s = line_label_default_style ();
s.char_height = 1.3;
s.top_frac = 0.75;
s.bottom_frac = 0.7;
s.angle = 45.;

plot_bin_density;

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.25, 10);
plot_data_counts(heg);
oplot_model_counts(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.6, 13);
plot_data_counts(meg);
oplot_model_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.25, 3);
plot_data_counts(heg);
oplot_model_counts(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(4.5,10);
plot_data_counts(meg);
oplot_model_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.55, 10);
plot_data_flux(heg);
oplot_model_flux(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.6, 13);
plot_data_flux(meg);
oplot_model_flux(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.55, 3);
plot_data_flux(heg);
oplot_model_flux(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(4.5,10);
plot_data_flux(meg);
oplot_model_flux(meg);

plot_close (id);

