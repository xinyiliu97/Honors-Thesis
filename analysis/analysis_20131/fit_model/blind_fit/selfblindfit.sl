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


flux_corr(meg, 2);
flux_corr(heg, 2);

errorbars(5);


% set approx. continuum parameters
nh = 0.5;
norm_pl = 0.0126;
gamma = 0.86;


lines = [1.65, 1.85, 1.92, 1.935];
guess_flux = [100, 220, 800, 1000];
lam = [1.4,2];
lam_ignore = [0,1.4];


ignore(all_data);
%group_data(meg, 4);
%group_data(heg, 4);
notice([heg],lam[0], min( [lam[1], 12] ));
notice([meg],max( [1.75,lam[0]] ), min( [lam[1], 16.5] ));
ignore([heg,meg], lam_ignore[0], lam_ignore[1]);

fit_fun("wabs(1)* powerlaw(1) + voigt(1) + voigt(2) + voigt(3) + voigt(4)");

set_par(1, nh, 1);
set_par(2, norm_pl);
set_par(3, -gamma, 0, -3, 3);


n = length(lines);
i = 0; while (i < n){
    g = guess_flux[i]/1000000;
    c = lines[i];
    dlam = max( [0.02,lines[i]*(0.03/7.)] );
    set_par(4 + 4*i, g, 0, g/4., 5*g);
    set_par(5 + 4*i, _A(c), 0, _A(c+dlam), _A(c-dlam));
    set_par(6 + 4*i, 0.001, 1);
    set_par(7 + 4*i, 2300./80000, 0, 1000./80000, 4000./80000);
    i = i+1;
}

set_fit_method("subplex");
() = fit_counts;
%set_fit_method("marquardt");
%() = fit_counts;
save_par("voigtfit0_womarq.txt");

list_par;

() = open_plot("fit_all_lines_voigt.ps/cps", 1, 2);
%fp = fopen("alllinefits_voigt.txt", "w");

limits;
xrange(lam[0], lam[1]);
plot_data_flux(heg);
oplot_model_flux(heg);
plot_data_flux(meg);
oplot_model_flux(meg);

%() = fclose(fp);
close_plot();
quit();








