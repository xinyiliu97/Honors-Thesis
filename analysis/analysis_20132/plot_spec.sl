_auto_declare=1;   % So we don't have to declare variables

% Load the PHA file
() = load_data("pha2");

% List contents of the PHA file
list_data;
% Current Spectrum List:
%  id    instrument part/m  src    use/nbins   A   R     totcts   exp(ksec)  target
%   1     HETG-ACIS  heg-3   1    8192/ 8192   -   -  2.2400e+02    23.352  SS 433
%   2     HETG-ACIS  heg-2   1    8192/ 8192   -   -  5.6600e+02    23.352  SS 433
%   3     HETG-ACIS  heg-1   1    8192/ 8192   -   -  7.3020e+03    23.352  SS 433
%   4     HETG-ACIS  heg+1   1    8192/ 8192   -   -  6.8670e+03    23.352  SS 433
%   5     HETG-ACIS  heg+2   1    8192/ 8192   -   -  4.3500e+02    23.352  SS 433
%   6     HETG-ACIS  heg+3   1    8192/ 8192   -   -  1.8700e+02    23.352  SS 433
%   7     HETG-ACIS  meg-3   1    8192/ 8192   -   -  1.0730e+03    23.352  SS 433
%   8     HETG-ACIS  meg-2   1    8192/ 8192   -   -  2.6900e+02    23.352  SS 433
%   9     HETG-ACIS  meg-1   1    8192/ 8192   -   -  1.0598e+04    23.352  SS 433
%  10     HETG-ACIS  meg+1   1    8192/ 8192   -   -  1.2199e+04    23.352  SS 433
%  11     HETG-ACIS  meg+2   1    8192/ 8192   -   -  2.2900e+02    23.352  SS 433
%  12     HETG-ACIS  meg+3   1    8192/ 8192   -   -  8.5200e+02    23.352  SS 433


% Load first order ARFs and RMFs
heg_m1_arf = load_arf("heg_-1.arf");
heg_p1_arf = load_arf("heg_1.arf");
meg_p1_arf = load_arf("meg_1.arf");
meg_m1_arf = load_arf("meg_-1.arf");

heg_m1_rmf = load_rmf("heg_-1.rmf");
heg_p1_rmf = load_rmf("heg_1.rmf");
meg_p1_rmf = load_rmf("meg_1.rmf");
meg_m1_rmf = load_rmf("meg_-1.rmf");

% Assign ARFs and RMFs to Dataset IDs
assign_arf(heg_m1_arf, 3);  % Dataset  3 = HEG-1
assign_arf(heg_p1_arf, 4);  % Dataset  4 = HEG+1
assign_arf(meg_m1_arf, 9);  % Dataset  9 = MEG-1
assign_arf(meg_p1_arf,10);  % Dataset 10 = MEG+1

assign_rmf(heg_m1_rmf, 3);  % Dataset  3 = HEG-1
assign_rmf(heg_p1_rmf, 4);  % Dataset  4 = HEG+1
assign_rmf(meg_m1_rmf, 9);  % Dataset  9 = MEG-1
assign_rmf(meg_p1_rmf,10);  % Dataset 10 = MEG+1

flux_corr([3,4,9,10]);

%xrange(1.25, 12.8);
xrange(1.5,4.5);
yrange(0, 60);

% Group data
group_data([3,4],2);         % Group HEG data by a factor of 2
group_data([9,10],4);         % Group MEG data by a factor of 4
heg = combine_datasets(3,4); % In memory combination of HEG data
meg = combine_datasets(9,10); % In memory combination of MEG data

hd = get_combined(heg, &get_data_counts);
label("Wavelength(A)","Counts/Bin","Combined HEG Data");
hplot(hd.bin_lo,hd.bin_hi,hd.value);


%xnotice([3,4],1.65,2.3); % Only notice the 1.65-2.3 A data for HEG
%exclude(9,10);            % Ignore MEG data for now



