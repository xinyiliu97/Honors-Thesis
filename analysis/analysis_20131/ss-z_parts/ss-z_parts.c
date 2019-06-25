/* Calculate z(MJD) for SS 433.

Binary ephemeris:

 Orbital period (P_o) and reference time when eclipse happens (mjdref_o)
  P_o = 13.08211  (Cherepashchuk 2002, Marshall+2013)
  mjdref_o = JD 2450023.62 = MJD 50023.12 (Cherepashchuk 2002, Marshall+2013)

 Precession period (P_p) and reference time when z=zmax (mjdref_p)
  P_p = 162.151 (Gies+2002, Marshall+2013)
  mjdref_p = JD 2451458.12 = MJD 51457.62

 Nutation period (P_n), reference time (mjdref_n), and nutation amplitude (z_n)
  P_n = 6.2877           (Gies+2002, Marshall+2013)
  mjdref_n = 50000.44
  z_n = 0.009

We use kinematic model, and symbols by Abell & Margon (AM79) where
i  = angle between l.o.s and precession axis (=78.83 deg =1.375843 rad).
q  = amount of beam's rotation (theta in AM79 =19.85 deg =0.34644786 rad).
wp = ang. vel. of precession (=2pi/(162.151 days) =0.0387489766 rad/day).
wo = orbital ang. vel. (2pi/(13.08211 days) = 0.480288371 rad/day).
v  = jet speed in units of c (=0.27).
l  = angle between instantaneous blue jet direction and l.o.s.
z  = instantaneous redshift of the blue jet.

Then:
 l = aa*cos(wp*t) + bb for red jet and l'=-l for blue jet, where
       aa=sin(i)*sin(q) = and bb=cos(i)*cos(q)=0.1822107

Good orbital phase: 
  0.88 < phi_o < 0.98 [Entering eclipse]
Good precession phase:
  0.50 +/- 0.10 (Red jet beamed brightest)

Compile: $ gcc ss-z.c -o ss-z -lm -Wall -W -O0 -ansi -pedantic -Winline
Run:     $ ./ss-z

Output: An ASCII file called ss-z.d is created with the following columns:
1. MJDs sampled.
2. Redshift z of the red jet corresponding to the MJD in column 1.
3. Redshift z of the blu jet corresponding to the MJD in column 1.
4. Flag indicating if the orbital phase is good (1) or bad (0) for us.
5. Flag indicating if the precessional phase is good (1) or bad (0) for us.
6. Flag indicating if both the orbital AND precessional phases are good (1)
   or bad (0) for us.

MJDs that are good for our proposal must have the 6-th column value 1.

The gnuplot script ss-z.gnu takes the output file (ss-z.d) produced by this
code (ss-z.c) and produces ss-z.ps

*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define pi 3.1415926535

int main (void);

int main (void) 
{
	double P_o, P_p, P_n, mjdref_o, mjdref_p, mjdref_n;
	double sc_minmjd, sc_maxmjd, phi_o_min, phi_o_max;
	/*double mjd, phi_o, phi_p, dphi_p, phi_n, z_n, mjdstep, prev_good_mjd;*/
	double mjd, phi_o, phi_p, dphi_p, phi_n, z_n, mjdstep;
	/* double i, q, wp, wo, v, aa, bb, gg; */
	double v, aa, bb, gg;
	double lblu,lred, zblu,zred;
	int gti_orb, gti_pre, gti_final;
	FILE *op;

	/* i  = 1.375843; */
	/* q  = 0.34644786; */
	/* wp = 0.0387489766; */
	/* wo = 0.480288371;*/
	v  = 0.27;
	aa = 0.3331265;
	bb = 0.1822107;
	gg = 1./sqrt(1.-v*v);


	/*sc_minmjd = 58171.0;  Chandra visibility starts */
	/*sc_maxmjd = 58452.0;  Chandra visibility ends   */
	/*sc_minmjd = 58340.50758; /* Chandra visibility starts */
	/*sc_maxmjd = 58340.75083; /* Chandra visibility ends   */
        sc_minmjd = 58343.62893332;
        sc_maxmjd = 58343.85713227;

	phi_o_min = 0.88;    /* Start HETG at this phi_o  */
	phi_o_max = 0.898;    /* End HETG at this phi_o    */

	P_o = 13.08211;
	mjdref_o = 50023.12;

	P_p = 162.151;
	mjdref_p = 51457.62;
	dphi_p = 0.1;

	P_n = 6.2877;
	mjdref_n = 50000.44;
	z_n = 0.009;

	/* prev_good_mjd=0.;*/
	mjdstep=0.1;
 
        /*mjd = 58340.50758102; /*start of 20131 part 0*/
	/*mjd = 58344.54172910; /*Start of 20131*/
	mjd = 58344.54172910; /*End of 20131 */
	phi_p = fmod ((mjd - mjdref_p) , P_p) / P_p;
	phi_o = fmod ((mjd - mjdref_o) , P_o) / P_o;
	phi_n = fmod ((mjd - mjdref_n) , P_n) / P_n;
	lred = aa*cos(2.*pi*phi_p) + bb;
	lblu = -lred;
	zred = gg*(1.+lred*v) - 1.;
	zblu = gg*(1.+lblu*v) - 1.;

	/* Add nutation*/
	zblu+= z_n*cos(2.*pi*phi_n);
	zred-= z_n*cos(2.*pi*phi_n);

	fprintf(stdout,"%f %f %f %f %f %f\n", 
		mjd, phi_o, phi_p, phi_n, zred, zblu);


	op = fopen("ss-z_part5.d","w");
	for (mjd = sc_minmjd; mjd < sc_maxmjd; mjd+=mjdstep) 
	{
		phi_p = fmod ((mjd - mjdref_p) , P_p) / P_p;
		phi_o = fmod ((mjd - mjdref_o) , P_o) / P_o;
		phi_n = fmod ((mjd - mjdref_n) , P_n) / P_n;
		
		gti_orb=0;
		if (phi_o>=phi_o_min && phi_o<phi_o_max) gti_orb=1;

		gti_pre=0;
		if (phi_p>0.5-dphi_p && phi_p<0.5+dphi_p) gti_pre=1;

		gti_final = gti_orb * gti_pre;
		
		lred = aa*cos(2.*pi*phi_p) + bb;
		lblu = -lred;
		zred = gg*(1.+lred*v) - 1.;
		zblu = gg*(1.+lblu*v) - 1.;

		/* Add nutation*/
		zblu+= z_n*cos(2.*pi*phi_n);
		zred-= z_n*cos(2.*pi*phi_n);

		fprintf(op,"%f %f %f %f %f %f %d %d %d\n", 
				mjd, zred, zblu, phi_p, phi_o, lblu, gti_orb, gti_pre, gti_final);
	}
	fclose(op);

	return 0;
}

