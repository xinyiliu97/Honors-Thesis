plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");


print("Starting");
% read data
variable pdir = "/home/xliu/20131/parts/part0/";

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


()=evalfile("Aped_utils-1.3.5.sl");
fit_fun("wabs(1) * plaw_dem2(1)");
list_par;
%load_par("aped_contT_par.txt");
%set_par("wabs(1).nH", 1.2, 0, 0, 10);
%set_par("plaw_dem2(1).norm", 0.1, 0, 0.0001, 0.05);
%set_par("plaw_dem2(1).gamma", 1, 0, 0, 20);
%set_par("plaw_dem2(1).LogTmin", 15, 1, 0, 22);
%set_par("plaw_dem2(1).LogTmax", 19, 1, 0, 22);
%set_par("plaw_dem2(1).redshift", 0.035, 0, -0.02, 0.05);
%set_par("plaw_dem2(1).density", 1e+14, 1);
%set_par("plaw_dem2(1).vturb", 1667.202, 0, 500, 4000);
%set_par("plaw_dem2(1).metal_abund", 2.819, 0, 0.1, 15);

%save_par("aped_conT_manual.txt");
load_par("aped_contT_manual_east.txt");
list_par;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set_fit_method("subplex");
%set_fit_statistic("cash");
%() = fit_counts(;fit_verbose=1);
%save_par("aped_contT_fitted_par.txt");

%set_fit_statistic("cash");
%() = fit_counts(;fit_verbose=1);
() = eval_counts();
%save_par("aped_contT_manualfitted_par.txt");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
print("Creating Plot");


megmin = 1.6;
megmax = 12;
hegmin = 1.25;
hegmax = 11.8;

% prepare data arrays for figure
ignore(all_data);
notice(heg, 1.25, 11.8);
notice(meg, 1.6, 18);
() = eval_counts();

print("Hello");

% prepare a plot
variable device, id;
device = "plasma_cont_manual_east_part0.ps/cps";
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

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(hegmin, 2.5);
yrange(0, 0.6);
%plot_data_counts(heg);
%oplot_model_counts(heg);
rplot_counts(heg);

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(4, 7);
yrange(0, 0.2);
%plot_data_counts(heg);
%oplot_model_counts(heg);
rplot_counts(heg);

charsize(1.8);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(6.5, 9);
yrange(0, 0.2);
%plot_data_counts(heg);
%oplot_model_counts(heg);
rplot_counts(heg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(megmin, 5);
yrange(0, 0.4);
%plot_data_counts(meg);
%oplot_model_counts(meg);
rplot_counts(meg);


label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(5, 8);
yrange(0, 0.4);
%plot_data_counts(meg);
%oplot_model_counts(meg);
rplot_counts(meg);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
xrange(8, 11);
yrange(0, 0.4);
%plot_data_counts(meg);
%oplot_model_counts(meg);
rplot_counts(meg);

plot_close (id);

quit();
