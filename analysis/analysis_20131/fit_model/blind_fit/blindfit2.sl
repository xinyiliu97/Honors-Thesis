plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");
require("add_orders");


public variable heg, meg, lam, lines, guess_flux;
public variable bg_guess, lam_ignore;
public variable n, midlam, sigma, flux_est;
public variable i, fun_string, g, c, lo_width, hi_width, width, width_sigma;
public variable dvee, sig_dvee, ok, lo_flux, hi_flux, flux_sigma;
public variable w, f, wave_sigma, lo_wave, hi_wave, fp, idx, s;
public variable nh, norm_pl, gamma;


print("Starting");
% read data
variable pdir = "/home/xliu/20131/parts/part2/";

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


flux_corr(meg, 2);
flux_corr(heg, 2);

yrange(0,.04);
xrange(1.3,16.);
errorbars(5);


% set approx. continuum parameters
nh = 0.5;
norm_pl = 0.0126;
gamma = 0.86;


() = open_plot("fit_all_lines_voigt2.ps/cps", 1, 2);
fp = fopen("alllinefits_voigt2.txt", "w");

lines = [1.65, 1.85, 1.9, 1.93];
guess_flux = [100, 220, 400, 400];
lam = [1.4,2];
lam_ignore = [0,1.4];
() = evalfile("fit_line_voigt.sl");
save_par("voigt2_0.txt");


lines = [4.9, 5.05, 5.2, 5.4];
guess_flux = [200, 100, 100, 50];
lam = [4.5, 5.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt2_1.txt");

%lines = [6.4, 6.65, 6.83, 6.9, 6.94, 7.35];
lines = [6.4,6.65, 6.85, 7, 7.1, 7.18];
guess_flux = [800, 200, 400,100, 100, 50];
lam = [5.5, 7.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt2_2.txt");


lines = [8.7];
guess_flux = [100];
lam = [7.5, 9];
() = evalfile("fit_line_voigt.sl");
save_par("voigt2_3.txt");


() = fclose(fp);
close_plot();
quit();
