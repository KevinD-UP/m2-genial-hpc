/*
 * calcul d'une integrale par la methode des trapezes.
 */


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

double f(double x) {

  return 4.0/(1+x*x);

}

double compute_integral(double start, double dx, int nSegments)
{

  int i;
  double integral = 0.0;

  for (i=0; i<nSegments; i++) {

    double x1 = start + dx*i;
    integral += ( f(x1) + f(x1 + dx) ) / 2 * dx;

  }

  return integral;
}


int main (int argc, char* argv[])
{

  // les bornes de l'integrale
  double a,b;

  // nombre de segments total
  int n = 1024;

  // longueur d'un segment
  double dx;

  // calcul local  d'integrale
  double integral;

  a=0.0;
  b=1.0;

  // calcul les bornes d'integration locale
  dx=(b-a)/n;

  // compute  integral
  integral = compute_integral(0,dx,n);

  printf("Resultat final : %g\n",integral);
  printf("Erreur absolue : %g\n",integral-4*atan(1.0));

  return EXIT_SUCCESS;

}
