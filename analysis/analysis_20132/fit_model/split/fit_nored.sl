% How it should work:
% Read in data (hetg), decide number of gaussians to fit, 
% then decide which parameters to set as initial 
% guesses and which to freeze at user defined values.

plasma(aped);
_auto_declare=1;
Remove_Spectrum_Gaps=1;
require("readascii");

public variable heg, meg, lam, lines, guess_flux;
public variable bg_guess, lam_ignore;
public variable n, midlam, sigma, flux_est;
public variable i, fun_string, g, c, lo_width, hi_width, width, width_sigma;
public variable dvee, sig_dvee, ok, lo_flux, hi_flux, flux_sigma;
public variable w, f, wave_sigma, lo_wave, hi_wave, fp, idx, s;
public variable nh, norm_pl, gamma;

% () = open_plot("/xwin",1,2);
plot_unit ("Angstrom");
plot_bin_density;
set_fit_statistic("cash");

% read data
heg = load_data("bluejet_counts_heg.txt");
() = readascii("bluejet_arf_heg.txt", &wave_lo, &wave_hi, &h_arf; format="%f %f %f");
harf = define_arf(wave_lo, wave_hi, h_arf, 0.*h_arf);
set_arf_exposure(harf, 1.);
assign_arf(harf, heg);

meg = load_data("bluejet_counts_meg.txt");
() = readascii("bluejet_arf_meg.txt", &wave_lo, &wave_hi, &m_arf; format="%f %f %f");
marf = define_arf(wave_lo, wave_hi, m_arf, 0.*m_arf);
set_arf_exposure(marf, 1.);
assign_arf(marf, meg);

flux_corr(meg, 2);
flux_corr(heg, 2);

yrange(0,.04);
xrange(1.3,16.);
% plot_data_flux(heg);
% plot_data_flux(meg);
errorbars(5);

% set approx. continuum parameters
nh = 0.5;
norm_pl = 0.0126;
gamma = 0.86;

% () = open_plot("fit_all_lines_nored.ps/cps", 1, 2);
% fp = fopen("alllinefits_nored.txt", "w");
% 
% lines = [1.60, 1.78, 1.86];
% guess_flux = [220, 230, 630];
% lam = [1.55,1.95];
% lam_ignore = [0,1.5];
% () = evalfile("fit_line_nored.sl");
% save_par("group1params.txt");
% 
% lines = [3.03, 3.19, 3.73, 3.96, 4.74];
% guess_flux = [20, 30, 35, 50, 100];
% lam = [2.8,5.];
% () = evalfile("fit_line_nored.sl");
% save_par("group2params.txt");
% 
% lines = [5.06, 5.22, 6.19];
% guess_flux = [90, 10, 150];
% lam = [4.85,6.5];
% () = evalfile("fit_line_nored.sl");
% save_par("group3params.txt");
% 
% lines = [6.65, 6.75, 7.10, 7.17, 7.48];
% guess_flux = [77, 30, 30, 30, 25];
% lam = [6.5,7.8];
% () = evalfile("fit_line_nored.sl");
% save_par("group4params.txt");
% 
% lines = [7.99, 8.32, 8.42, 8.8];
% guess_flux = [20, 26, 55, 20];
% lam = [7.8,9.0];
% () = evalfile("fit_line_nored.sl");
% save_par("group5params.txt");
% 
% lines = [9.09, 9.38, 9.55, 9.75];
% guess_flux = [30, 20, 20, 20];
% lam = [8.9,9.9];
% () = evalfile("fit_line_nored.sl");
% save_par("group6params.txt");
% 
% lines = [9.97, 10.62, 11.03, 11.20, 11.45, 11.80];
% guess_flux = [30, 30, 20, 20, 10, 15];
% lam = [9.9,12.0];
% () = evalfile("fit_line_nored.sl");
% save_par("group7params.txt");
% 
% lines = [12.17, 12.44, 12.85, 14.05, 15.05, 16.05];
% guess_flux = [25, 5, 5, 9, 5, 5];
% lam = [12.0,16.5];
% () = evalfile("fit_line_nored.sl");
% save_par("group8params.txt");
% 
% () = fclose(fp);
% close_plot();

() = open_plot("fit_all_lines_voigt.ps/cps", 1, 2);
fp = fopen("alllinefits_voigt.txt", "w");

lines = [1.53, 1.59, 1.78, 1.86];
guess_flux = [100, 220, 230, 630];
lam = [1.45,1.95];
lam_ignore = [0,1.45];
() = evalfile("fit_line_voigt.sl");
save_par("voigt0.txt");

lines = [1.86, 3.03, 3.19];
guess_flux = [630, 20, 30];
lam = [1.82,3.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt1.txt");

lines = [3.73, 3.96, 4.74, 5.06, 5.22, 6.19];
guess_flux = [35, 50, 100, 90, 10, 150];
lam = [3.5,6.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt2.txt");

lines = [6.65, 6.75, 7.10, 7.17, 7.46, 7.99, 8.32, 8.43, 8.85];
guess_flux = [77, 30, 30, 30, 25, 20, 26, 55, 20];
lam = [6.5,9.];
() = evalfile("fit_line_voigt.sl");
save_par("voigt3.txt");

lines = [9.09, 9.38, 9.55, 9.73, 9.97, 10.62, 11.03, 11.20, 11.45];
guess_flux = [30, 20, 20, 20, 30, 30, 20, 20, 10, 15];
lam = [8.9,11.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt4.txt");

lines = [11.78, 12.15, 12.44, 12.91, 14.10, 15.05, 16.02];
guess_flux = [15, 25, 5, 5, 9, 5, 5];
lam = [11.5,16.5];
() = evalfile("fit_line_voigt.sl");
save_par("voigt5.txt");

() = fclose(fp);
close_plot();
