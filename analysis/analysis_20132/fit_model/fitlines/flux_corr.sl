plasma(aped);
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
group_data(meg, 8);
group_data(heg, 8);
% notice(heg, 1.25, 11.8);
% notice(meg, 1.6, 14);
ignore(heg, 11.8,100);
ignore(meg, 14,100);
ignore(heg, 0, 1.25);
ignore(meg, 0,1.6);

plot_bin_density;
flux_corr(meg, 2);
flux_corr(heg, 2);
%flux_corr(megn, 4);
%flux_corr(hegn, 4);

variable n = 19;
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
% Ni27
% line_wave[12] = (2*1.6579 + 1.6618) / 3.;
line_wave[12] = 1.592;
% Mg11r
line_wave[13] = 9.1688;
% Mg11i
line_wave[14] = 0.5 * (9.2282+9.2312);
% Mg11f
line_wave[15] = 9.3143;
% S16
line_wave[16] = 4.73;
% Mg12
line_wave[17] = 7.01;
%Ni26
line_wave[18] = 9.372;
%variable delz = 0.01, z1_est = 0.009;
variable delz = 0.02, z1_est = 0.0;
variable r1 = 1 + delz, r2 = 1-delz;
variable hi_wave = line_wave * r1, lo_wave = line_wave * r2;
variable z1_max = z1_est + delz, z1_min = z1_est - delz;


fit_fun("redshift(1) * redshift(2) * sigma(1) * sigma(2) * wabs(1) * " +
  "( rest_wave(1) * rest_wave(2) * rest_wave(3) * rest_wave(4) * " +
  "rest_wave(5) * rest_wave(6) * rest_wave(7) * rest_wave(8) * rest_wave(9) * " +
  " rest_wave(10) * rest_wave(11) * rest_wave(12) * rest_wave(13) * rest_wave(14) * " +
"rest_wave(15) * rest_wave(16) * rest_wave(17)  * rest_wave(18))* " + "( powerlaw(1) + gauss(1) + gauss(2) + gauss(3) + gauss(4) + " +
  " gauss(5) + gauss(6) + gauss(7) + gauss(8) + gauss(9) + " +
  " gauss(10) + gauss(11) + gauss(12) + gauss(13) + gauss(14) + gauss(15) + gauss(16)+gauss(17) + gauss(18))");


set_par("redshift(1).z", z1_est, 0, z1_min, z1_max);
set_par("redshift(2).z", 0.068, 0, 0.04, 0.09);
set_par("sigma(1).beta", 0.005, 0, 0.0025, 0.01);
set_par("sigma(2).beta", 0.005, 0, 0.0025, 0.01);
set_par("rest_wave(1).lambda", line_wave[4], 1); %Si14
set_par("rest_wave(2).lambda", line_wave[0], 1); %Mg12
set_par("rest_wave(3).lambda", line_wave[11], 1);%Ne10
set_par("rest_wave(4).lambda", line_wave[5], 1); %S15

set_par("gauss(1).center", "(1+redshift(1).z)*rest_wave(1).lambda", 1, 0, 40);
set_par("gauss(2).center", "(1+redshift(1).z)*rest_wave(2).lambda", 1, 0, 40);
set_par("gauss(3).center", "(1+redshift(1).z)*rest_wave(3).lambda", 1, 0, 40);
set_par("gauss(4).center", "(1+redshift(1).z)*rest_wave(4).lambda", 1, 0, 40);
set_par("gauss(1).sigma", "(1+redshift(1).z)*rest_wave(1).lambda*sigma(1).beta", 1);
set_par("gauss(2).sigma", "(1+redshift(1).z)*rest_wave(2).lambda*sigma(1).beta", 1);
set_par("gauss(3).sigma", "(1+redshift(1).z)*rest_wave(3).lambda*sigma(1).beta", 1);
set_par("gauss(4).sigma", "(1+redshift(1).z)*rest_wave(4).lambda*sigma(1).beta", 1);
set_par("gauss(?).area", 0.001);

set_par("rest_wave(5).lambda", line_wave[1], 1); %Si13r
set_par("rest_wave(6).lambda", line_wave[2], 1); %Si13i
set_par("rest_wave(7).lambda", line_wave[3], 1); %Si13f
set_par("gauss(5).center", "(1+redshift(1).z)*rest_wave(5).lambda", 1, 0, 40);
set_par("gauss(6).center", "(1+redshift(1).z)*rest_wave(6).lambda", 1, 0, 40);
set_par("gauss(7).center", "(1+redshift(1).z)*rest_wave(7).lambda", 1, 0, 40);
set_par("gauss(5).sigma", "(1+redshift(1).z)*rest_wave(5).lambda*sigma(1).beta", 1);
set_par("gauss(6).sigma", "(1+redshift(1).z)*rest_wave(6).lambda*sigma(1).beta", 1);
set_par("gauss(7).sigma", "(1+redshift(1).z)*rest_wave(7).lambda*sigma(1).beta", 1);
set_par("gauss(5).area", get_par("gauss(1).area"));
set_par("gauss(6).area", 0.001, 0);
set_par("gauss(7).area", 0.001, 0);

set_par("rest_wave(8).lambda", line_wave[7], 1); %Fe25 blue jet
set_par("rest_wave(9).lambda", line_wave[8], 1); %Fe 26 blue jet
set_par("gauss(8).center", "(1+redshift(2).z)*rest_wave(8).lambda", 1, 0, 40);
set_par("gauss(9).center", "(1+redshift(2).z)*rest_wave(9).lambda", 1, 0, 40);
set_par("gauss(8).sigma", "(1+redshift(2).z)*rest_wave(8).lambda*sigma(2).beta", 1);
set_par("gauss(9).sigma", "(1+redshift(2).z)*rest_wave(9).lambda*sigma(2).beta", 1);
set_par("gauss(8).area", 0.2*get_par("gauss(1).area"));
set_par("gauss(9).area", 0.2*get_par("gauss(1).area"));


set_par("rest_wave(10).lambda", line_wave[13], 1); %Mg11r
set_par("gauss(10).center", "(1+redshift(1).z)*rest_wave(10).lambda", 1, 0, 40);
set_par("gauss(10).sigma", "(1+redshift(1).z)*rest_wave(10).lambda*sigma(1).beta", 1);
set_par("gauss(10).area", 0.3*get_par("gauss(1).area"));
set_par("rest_wave(11).lambda", line_wave[14], 1);%Mg11i
set_par("gauss(11).center", "(1+redshift(1).z)*rest_wave(11).lambda", 1, 0, 40);
set_par("gauss(11).sigma", "(1+redshift(1).z)*rest_wave(11).lambda*sigma(1).beta", 1);
set_par("gauss(11).area", 0.3*get_par("gauss(1).area"));
set_par("rest_wave(12).lambda", line_wave[15], 1);%Mg11f
set_par("gauss(12).center", "(1+redshift(1).z)*rest_wave(12).lambda", 1, 0, 40);
set_par("gauss(12).sigma", "(1+redshift(1).z)*rest_wave(12).lambda*sigma(1).beta", 1);
set_par("gauss(12).area", 0.3*get_par("gauss(1).area"));


set_par("rest_wave(13).lambda", line_wave[12], 1);%Ni27
set_par("rest_wave(14).lambda", line_wave[7], 1);%Fe25 red jet
set_par("rest_wave(15).lambda", line_wave[8], 1); %Fe26 red jet
set_par("rest_wave(16).lambda", line_wave[16], 1);%S16
set_par("gauss(13).center", "(1+redshift(1).z)*rest_wave(13).lambda", 1, 0, 40);
set_par("gauss(14).center", "(1+redshift(1).z)*rest_wave(14).lambda", 1, 0, 40);
set_par("gauss(13).sigma", "(1+redshift(1).z)*rest_wave(13).lambda*sigma(1).beta", 1);
set_par("gauss(13).area", 0.5*get_par("gauss(8).area"));
set_par("gauss(14).sigma", "(1+redshift(1).z)*rest_wave(14).lambda*sigma(1).beta", 1);
set_par("gauss(14).area", 0.5*get_par("gauss(8).area"));
set_par("gauss(15).center", "(1+redshift(1).z)*rest_wave(15).lambda", 1, 0, 40);
set_par("gauss(15).sigma", "(1+redshift(1).z)*rest_wave(15).lambda*sigma(1).beta", 1);
set_par("gauss(15).area", 0.5*get_par("gauss(8).area"));
set_par("gauss(16).center", "(1+redshift(1).z)*rest_wave(16).lambda", 1, 0, 40);
set_par("gauss(16).sigma", "(1+redshift(1).z)*rest_wave(16).lambda*sigma(1).beta", 1);
set_par("gauss(16).area", 0.5*get_par("gauss(8).area"));

%Si 13(rif) in red jet 
set_par("rest_wave(17).lambda", line_wave[1], 1);
%set_par("rest_wave(18).lambda", line_wave[2], 1);
%set_par("rest_wave(19).lambda", line_wave[3], 1);%Si13f
set_par("gauss(17).center", "(1+redshift(2).z)*rest_wave(17).lambda", 1, 0, 40);
%set_par("gauss(18).center", "(1+redshift(2).z)*rest_wave(18).lambda", 1, 0, 40);
%set_par("gauss(19).center", "(1+redshift(2).z)*rest_wave(19).lambda", 1, 0, 40);
set_par("gauss(17).sigma", "(1+redshift(2).z)*rest_wave(17).lambda*sigma(2).beta", 1);
%set_par("gauss(18).sigma", "(1+redshift(2).z)*rest_wave(18).lambda*sigma(2).beta", 1);
%set_par("gauss(19).sigma", "(1+redshift(2).z)*rest_wave(19).lambda*sigma(2).beta", 1);
set_par("gauss(17).area", 0.5*get_par("gauss(8).area"));
%set_par("gauss(18).area", 0.5*get_par("gauss(8).area"));
%set_par("gauss(19).area", 0.5*get_par("gauss(8).area"));

%Si14 in red jet
set_par("rest_wave(18).lambda", line_wave[4], 1);
set_par("gauss(18).center", "(1+redshift(2).z)*rest_wave(18).lambda", 1, 0, 40);
set_par("gauss(18).sigma", "(1+redshift(2).z)*rest_wave(18).lambda*sigma(2).beta", 1);
set_par("gauss(18).area",0.5*get_par("gauss(8).area"));



%set_fit_method("subplex");
%set_fit_statistic("cash");
%() = fit_counts(;fit_verbose=1);
%save_par("fit_alllines.txt");

load_par("fit_alllines.txt");
set_fit_statistic("cash");
() = fit_counts(;fit_verbose=1);


%print("Getting Confidence Parameters");


%prepare for loop over all line normalizations

load_par("fit_alllines.txt");
wline = [26,29,32,35,38,41,44,47,50,53,56,59,62,65,68,71,74,77];
nline = length(wline);


for(i=0;i<nline;i++) {
   idx = wline[i];
   gpi = get_par_info( idx );
   variable val=gpi.value;
   if (val < 0) set_par(idx, val, 0, 3*val, val - 3.0*val);
   else set_par(idx, val, 0, 0.3*val, 3.0*val);
}
save_par("fit_alllines.txt");

%(pmin, pmax) = conf_loop( NULL, 0; cl_verbose=1, save,
%   prefix="conf_loop/pars_all", num_slaves=7);

%wpar = [1,2,3,4,5,24,25,26,29,32,35,38,41,44,47,50,53,56,59,62,65,68,71,74,77];
%npar = length(wpar);

%fp = fopen ("all_paramvalues2.txt", "w");
%() = fprintf (fp, "        Parameter     Value        Err  \n");
%for(i=0;i<npar;i++) {
%   idx = wpar[i];
%   gpi = get_par_info(idx);
%   variable val=gpi.value, err=0.5*(pmax[i]-pmin[i]);
%   () = fprintf (fp, "%20s %10.3e %10.3e\n", gpi.name, val, err);
%}
%() = fclose(fp);



%save_par("fit_alllines.txt");

rs1 = get_par("redshift(1).z");
rs2 = get_par("redshift(2).z");
hegmin = 1.25;	
hegmax = 10;
megmin = 2.5;
megmax = 13;


%flux_corr(heg);
%flux_corr(meg);

% prepare a plot
variable device, id;
device = "fitlines_flux_corr.ps/cps";
id = open_plot(device,1,2);

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

charsize(1.5);
label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(hegmin, hegmax);
plot_data_flux(heg);
%get_data_flux (heg);
oplot_model_flux(heg, 2);


label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(megmin, megmax);
plot_data_flux(meg);
oplot_model_flux(meg, 2);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(hegmin, 4.7);
yrange(-1e-6, 0.05);
plot_data_flux(heg);
fe25_lines = where (wl(1.85,1.855) and el_ion(26,[25]));
plot_group (fe25_lines, 2, s, rs1);
plot_group (fe25_lines, 4, s, rs2);
fe26_lines = where (wl(1.7,1.78) and el_ion(26,[26]));
plot_group (fe26_lines, 2, s, rs1);
plot_group (fe26_lines, 4, s, rs2);
ni27_lines = where(wl(1.58,1.59) and el_ion(28,[27]));
plot_group (ni27_lines, 2, s, rs1);
oplot_model_flux(heg ,2);


label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(4.5,hegmax);
yrange(-1e-6, 6e-3);
plot_data_flux(heg);
s15_lines = where (wl(5,5.06) and el_ion(16,[15]));
plot_group (s15_lines, 2, s, rs1);
si14_lines = where (wl(6,6.2) and el_ion(14,[14]));
plot_group (si14_lines, 2, s, rs1);
plot_group (si14_lines, 4, s, rs2);
si13_lines = where (wl(6.6, 6.65) and el_ion(14,[13]));
plot_group (si13_lines, 2, s, rs1);
plot_group (si13_lines, 4, s, rs2);
mg12_lines = where (wl(8.3, 8.5) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
mg11_lines = where (wl(9,9.2) and el_ion(12,[11]));
plot_group (mg11_lines, 2, s, rs1);
S16_lines = where (wl(4,5) and el_ion(16,[16]));
plot_group (S16_lines, 2, s, rs1);

oplot_model_flux(heg, 2);

label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(megmin, 7.5);
yrange(0, 8e-3);
plot_data_flux(meg);
oplot_model_flux(meg, 2);

s15_lines = where (wl(5,5.06) and el_ion(16,[15]));
plot_group (s15_lines, 2, s, rs1);
S16_lines = where (wl(4,5) and el_ion(16,[16]));
plot_group (S16_lines, 2, s, rs1);
si14_lines = where (wl(6,6.2) and el_ion(14,[14]));
plot_group (si14_lines, 2, s, rs1);
plot_group (si14_lines, 4, s, rs2);
si13_lines = where (wl(6.6, 6.65) and el_ion(14,[13]));
plot_group (si13_lines, 2, s, rs1);
plot_group (si13_lines, 4, s, rs2);




label( latex2pg("Wavelength (\\A)"), latex2pg("Flux (ph/cm^{2}/s/\\A)"), "");
Isis_Residual_Plot_Type = STAT;
errorbars(3);
xrange(7,megmax);
yrange(0,4e-3);
plot_data_flux(meg);
mg12_lines = where (wl(8.3, 8.5) and el_ion(12,[12]));
plot_group (mg12_lines, 2, s, rs1);
mg11_lines = where (wl(9,9.2) and el_ion(12,[11]));
plot_group (mg11_lines, 2, s, rs1);
oplot_model_flux(meg, 2);

plot_close (id);

quit();

