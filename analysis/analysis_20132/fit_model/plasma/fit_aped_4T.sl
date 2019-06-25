plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");

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
group_data(meg, 2);
group_data(heg, 2);
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

variable n = 4;
variable t = default_plasma_state ();
t.norm = Double_Type[n];
t.norm[*] = 0.05;
t.temperature = 1e6*[6.3, 12.6, 31.6, 126.];
t.metal_abund = 1.;
t.elem = [Ni];
t.elem_abund = [5.];
use_thermal_profile;
create_aped_fun ("xaped",t);

% load_par("aped_4Tpar_est.txt");
% load_par("aped_4Tpar_alldata.txt");
% load_par("aped_4Tpar_alldata_v2.txt");
% load_par("aped_4Tpar_alldata_v3.txt");
load_par("aped_4Tpar_alldata_v4.txt");

% for chisqr fit only
% () = fit_counts(;fit_verbose=1);
% save_par("aped_4Tpar_alldata_chi2.txt");
% using chisqr
%  Parameters[Variable] = 27[9]
%             Data bins = 6703
%            Chi-square = 7841.518
%    Reduced chi-square = 1.171425

list_par;
quit();
set_fit_method("subplex");
set_fit_statistic("cash");
() = fit_counts(;fit_verbose=1);
% save_par("aped_4Tpar_alldata_v2.txt");
save_par("aped_4Tpar_alldata_v4.txt");

% result after reiterating and restarting with vturb=2000
%  Parameters[Variable] = 14[8]
%             Data bins = 3206
%            Cash Statistic = 11442.5
%   Reduced Cash Statistic = 3.578018

% Parameters[Variable] = 27[9]
%             Data bins = 6703
%            Cash Statistic = 7766.404
%    Reduced Cash Statistic = 1.160204

% final attempt at global fit with cash & conf_loop
% Parameters[Variable] = 27[9]
%            Data bins = 3349
%           Cash Statistic = 4107.12
%   Reduced Cash Statistic = 1.229677

Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(1.7, 12);
rplot_counts(meg);
xrange(6,8);
rplot_counts(meg);

xrange(1.2, 12);
rplot_counts(heg);

xrange(1.2, 2.5);
rplot_counts(heg);

% no point going further, really

print("Getting Confidence Parameters");

(pmin, pmax) = conf_loop( NULL, 0; cl_verbose=1, save,
   prefix="conf_loop/pars4T", num_slaves=7);

(bmin, bmax) = conf(12);
(rmin, rmax) = conf(25);
fp = fopen ("zlimits.txt", "w");
() = fprintf (fp, "BlueMax BlueMin RedMax RedMin\n");
() = fprintf (fp, "%6.6f %6.6f %6.6f %6.6f\n",bmin, bmax, rmin, rmax);
fclose(fp);

print("Creating Plot");

% prepare data arrays for figure
ignore(all_data);
notice(heg, 1.25, 11.8);
notice(meg, 1.6, 18);
() = eval_counts();

print("Hello");

% prepare a plot
variable device, id;
device = "Desktop/15781/fit_aped_4T_alldata.ps/cps";
id = open_plot(device, 1,2);

print("Hello Hello");

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
xrange(1.25, 11.8);
plot_data_counts(heg);
oplot_model_counts(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
xrange(1.6, 18);
plot_data_counts(meg);
oplot_model_counts(meg);

plot_close (id);
