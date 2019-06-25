_auto_declare=1;
arf=load_arf("/home/xliu/20132/heg_1.arf");
plot_bin_integral;

variable device, id;
device = "visualarf.ps/cps";
id = open_plot(device,1,2);
charsize(1.2);
label( latex2pg("Energy (KeV)"), latex2pg("HEG m = +1 Effective Area (cm^{2})"), "");
xrange(0, 12);
hplot(get_arf(arf));
plot_close (id);
quit();
