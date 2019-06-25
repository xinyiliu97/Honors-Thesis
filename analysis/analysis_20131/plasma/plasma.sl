plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");

print("Starting");
% read data
variable pdir = "/home/xliu/20131/parts/part1/";

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

variable n = 4;
variable t = default_plasma_state (); % Return a structure describing the default CIE plasma state
t.norm = Double_Type[n];
t.norm[*] = 0.05;
t.temperature = 1e6*[6.3, 12.6, 31.6, 126];
t.metal_abund = 1.;
t.elem = [Ni];
t.elem_abund = [5.];
use_thermal_profile;
create_aped_fun ("xaped",t);

%fit_fun("wabs(1) * (xaped(1) + xaped(2))");
load_par("aped_4T_part0_fitted.txt");
%set_fit_statistic("cash");
%() = eval_counts();

set_fit_method("subplex");
set_fit_statistic("cash");
() = fit_counts(;fit_verbose=1);
save_par("aped_4T_part1_fitted.txt");



megmin = 1.6;
megmax = 12;
hegmin = 1.25;
hegmax = 11.8;

rs1 = get_par("xaped(1).redshift ");
rs2 = get_par("xaped(2).redshift ");

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

%print("Getting Confidence Parameters");

%(pmin, pmax) = conf_loop( NULL, 0; cl_verbose=1, save,
   %prefix="conf_loop/pars4T", num_slaves=7);

%(bmin, bmax) = conf(12);
%(rmin, rmax) = conf(25);
%fp = fopen ("zlimits.txt", "w");
%() = fprintf (fp, "BlueMax BlueMin RedMax RedMin\n");
%() = fprintf (fp, "%6.6f %6.6f %6.6f %6.6f\n",bmin, bmax, rmin, rmax);
%fclose(fp);

print("Creating Plot");

% prepare data arrays for figure
ignore(all_data);
notice(heg, 1.25, 11.8);
notice(meg, 1.6, 18);
() = eval_counts();

print("Hello");

% prepare a plot
variable device, id;
device = "plasma_part1.ps/cps";
id = open_plot(device, 1,3);

print("Hello Hello");

variable v = get_outer_viewport();
v.xmin = 0.2;
v.xmax = 0.8;
v.ymin = 0.1;
v.ymax = 0.9;
set_outer_viewport(v);
s = line_label_default_style ();
s.char_height = 1.3;
s.top_frac = 0.8;
s.bottom_frac = 0.7;
s.angle = 45;

plot_bin_density;

%charsize(1.8);
%label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
%Isis_Residual_Plot_Type = STAT;
%xrange(hegmin, hegmax);
%plot_data_counts(heg);
%oplot_model_counts(heg);

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(hegmin, 2.5);
yrange(0, 0.6);
plot_data_counts(heg);
oplot_model_counts(heg);

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(4, 7);
yrange(0, 0.6);
plot_data_counts(heg);
oplot_model_counts(heg);

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(6.5, 9);
yrange(0, 0.6);
plot_data_counts(heg);
oplot_model_counts(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(megmin, megmax);
yrange(0, 0.4);
plot_data_counts(meg);
oplot_model_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(megmin, 5);
yrange(0, 0.4);
plot_data_counts(meg);
oplot_model_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(5, 8);
yrange(0, 0.4);
plot_data_counts(meg);
oplot_model_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(8, 11);
yrange(0, 0.4);
plot_data_counts(meg);
oplot_model_counts(meg);


%label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(2.8, 8);
yrange(-0.02,0.4);
rplot_counts(heg);
s16_lines = where (wl(4.71,4.73) and el_ion(16,[16]));
plot_group (s16_lines, 2, s, rs1);
s15_lines = where (wl(5,5.06) and el_ion(16,[15]));
plot_group (s15_lines, 2, s, rs1);
si14_lines = where (wl(6.18,6.185) and el_ion(14,[14]));
plot_group (si14_lines, 2, s, rs1);
plot_group (si14_lines, 4, s, rs2);
si13_lines = where (wl(6.6, 6.65) and el_ion(14,[13]));
plot_group (si13_lines, 2, s, rs1);
plot_group (si13_lines, 4, s, rs2);
mg12_lines = where (wl(7.1, 7.106) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
xylabel(2.2,0.05,"HEG counts",90,color(1));

%label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(2.8,8);
yrange(-0.02,0.6);
rplot_counts(meg);
s16_lines = where (wl(4.71,4.73) and el_ion(16,[16]));
plot_group (s16_lines, 2, s, rs1);
s15_lines = where (wl(5,5.06) and el_ion(16,[15]));
plot_group (s15_lines, 2, s, rs1);
si14_lines = where (wl(6.18,6.185) and el_ion(14,[14]));
plot_group (si14_lines, 2, s, rs1);
plot_group (si14_lines, 4, s, rs2);
si13_lines = where (wl(6.6, 6.65) and el_ion(14,[13]));
plot_group (si13_lines, 2, s, rs1);
plot_group (si13_lines, 4, s, rs2);
mg12_lines = where (wl(7.1, 7.106) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
xylabel(2.2,0.2,"MEG counts",90,color(1));

%label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(7,hegmax);
yrange(-0.02,0.15);
rplot_counts(heg);
mg12_lines = where (wl(7.1, 7.106) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
fe24_lines = where (wl(7.45, 7.5) and el_ion(26,[24]));
plot_group (fe24_lines, 2, s, rs1);
mg12_lines = where (wl(8.41, 8.42) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
plot_group (mg12_lines, 4, s, rs2);
%mg11_lines = where (wl(9,9.2) and el_ion(12,[11]));
%plot_group (mg11_lines, 2, s, rs1);
%plot_group (mg11_lines, 4, s, rs2);
ni26_lines = where (wl(9.1,9.2) and el_ion(28,[26]));
plot_group (ni26_lines, 2, s, rs1);
ni25_lines = where (wl(9.33,9.35) and el_ion(28,[25]));
plot_group (ni25_lines, 2, s, rs1);
get_convolved_model_flux(heg);
xylabel(6.5,0.01,"HEG counts",90,color(1));

%label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(7,hegmax);
yrange(-0.02,0.3);
rplot_counts(meg);
mg12_lines = where (wl(7.1, 7.106) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
fe24_lines = where (wl(7.45, 7.5) and el_ion(26,[24]));
plot_group (fe24_lines, 2, s, rs1);
mg12_lines = where (wl(8.41, 8.42) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
plot_group (mg12_lines, 4, s, rs2);
%mg11_lines = where (wl(9.73,9.74) and el_ion(12,[11]));
%plot_group (mg11_lines, 2, s, rs1);
%plot_group (mg11_lines, 4, s, rs2);
ni26_lines = where (wl(9.1,9.2) and el_ion(28,[26]));
plot_group (ni26_lines, 2, s, rs1);
ni25_lines = where (wl(9.33,9.35) and el_ion(28,[25]));
plot_group (ni25_lines, 2, s, rs1);

get_convolved_model_flux(meg);
xylabel(6.5,0.08,"MEG counts",90,color(1));


plot_close (id);

quit();
