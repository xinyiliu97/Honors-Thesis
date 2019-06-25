set_par("rest_wave(5).lambda", line_wave[1], 1); %Si13r 6.74029
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

set_par("rest_wave(8).lambda", line_wave[7], 1); %Fe25 1.8545
set_par("rest_wave(9).lambda", line_wave[8], 1); %Fe26 1.7799
set_par("gauss(8).center", "(1+redshift(2).z)*rest_wave(8).lambda", 1, 0, 40);
set_par("gauss(9).center", "(1+redshift(2).z)*rest_wave(9).lambda", 1, 0, 40);
set_par("gauss(8).sigma", "(1+redshift(2).z)*rest_wave(8).lambda*sigma(2).beta", 1);
set_par("gauss(9).sigma", "(1+redshift(2).z)*rest_wave(9).lambda*sigma(2).beta", 1);
set_par("gauss(8).area", 0.5*get_par("gauss(1).area"));
set_par("gauss(9).area", 0.2*get_par("gauss(1).area"));


set_par("rest_wave(10).lambda", line_wave[13], 1); %Mg11r 9.1688
set_par("gauss(10).center", "(1+redshift(1).z)*rest_wave(10).lambda", 1, 0, 40);
set_par("gauss(10).sigma", "(1+redshift(1).z)*rest_wave(10).lambda*sigma(1).beta", 1);
set_par("gauss(10).area", 0.3*get_par("gauss(1).area"));
set_par("rest_wave(11).lambda", line_wave[14], 1); %Mg11i
set_par("gauss(11).center", "(1+redshift(1).z)*rest_wave(11).lambda", 1, 0, 40);
set_par("gauss(11).sigma", "(1+redshift(1).z)*rest_wave(11).lambda*sigma(1).beta", 1);
set_par("gauss(11).area", 0.3*get_par("gauss(1).area"));
set_par("rest_wave(12).lambda", line_wave[15], 1); %Mg11f
set_par("gauss(12).center", "(1+redshift(1).z)*rest_wave(12).lambda", 1, 0, 40);
set_par("gauss(12).sigma", "(1+redshift(1).z)*rest_wave(12).lambda*sigma(1).beta", 1);
set_par("gauss(12).area", 0.3*get_par("gauss(1).area"));


set_par("rest_wave(13).lambda", line_wave[12], 1); %Ni27 1.592
set_par("rest_wave(14).lambda", line_wave[7], 1); %Fe25 1.8545
set_par("rest_wave(15).lambda", line_wave[8], 1); %Fe26
set_par("rest_wave(16).lambda", line_wave[16], 1);%S16  4.7292
set_par("gauss(13).center", "(1+redshift(2).z)*rest_wave(13).lambda", 1, 0, 40);
set_par("gauss(13).sigma", "(1+redshift(2).z)*rest_wave(13).lambda*sigma(2).beta", 1);
set_par("gauss(13).area", 0.2*get_par("gauss(9).area"));
set_par("gauss(14).center", "(1+redshift(1).z)*rest_wave(14).lambda", 1, 0, 40);
set_par("gauss(14).sigma", "(1+redshift(1).z)*rest_wave(14).lambda*sigma(1).beta", 1);
set_par("gauss(14).area", 0.5*get_par("gauss(9).area"));
set_par("gauss(15).center", "(1+redshift(1).z)*rest_wave(15).lambda", 1, 0, 40);
set_par("gauss(15).sigma", "(1+redshift(1).z)*rest_wave(15).lambda*sigma(1).beta", 1);
set_par("gauss(15).area", 0.1*get_par("gauss(9).area"));
set_par("gauss(16).center", "(1+redshift(1).z)*rest_wave(16).lambda", 1, 0, 40);
set_par("gauss(16).sigma", "(1+redshift(1).z)*rest_wave(16).lambda*sigma(1).beta", 1);
set_par("gauss(16).area", 0.2*get_par("gauss(9).area"));

%Si 13(rif) in red jet 
set_par("rest_wave(17).lambda", line_wave[1], 1); %Si13i 6.74029
%set_par("rest_wave(18).lambda", line_wave[2], 1);
%set_par("rest_wave(19).lambda", line_wave[3], 1);
set_par("gauss(17).center", "(1+redshift(2).z)*rest_wave(17).lambda", 1, 0, 40);
%set_par("gauss(18).center", "(1+redshift(2).z)*rest_wave(18).lambda", 1, 0, 40);
%set_par("gauss(19).center", "(1+redshift(2).z)*rest_wave(19).lambda", 1, 0, 40);
set_par("gauss(17).sigma", "(1+redshift(2).z)*rest_wave(17).lambda*sigma(2).beta", 1);
%set_par("gauss(18).sigma", "(1+redshift(2).z)*rest_wave(18).lambda*sigma(2).beta", 1);
%set_par("gauss(19).sigma", "(1+redshift(2).z)*rest_wave(19).lambda*sigma(2).beta", 1);
set_par("gauss(17).area", 0.5*get_par("gauss(9).area"));
%set_par("gauss(18).area", 0.5*get_par("gauss(8).area"));
%set_par("gauss(19).area", 0.5*get_par("gauss(8).area"));

%Si14 in red jet
%set_par("rest_wave(20).lambda", line_wave[4], 1);%Si14 6.182
%set_par("gauss(20).center", "(1+redshift(2).z)*rest_wave(20).lambda", 1, 0, 40);
%set_par("gauss(20).sigma", "(1+redshift(2).z)*rest_wave(20).lambda*sigma(2).beta", 1);
%set_par("gauss(20).area",0.5*get_par("gauss(9).area"));
