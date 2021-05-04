/*
 * gcc -O3 -o compute_pi compute_pi.c -lm
 */

#include <stdlib.h> // for rand, srand
#include <stdio.h> // for printf

#include <math.h> // for M_PI

#include <unistd.h> // for sysconf
#include <sys/times.h> // for times and struct tms

double wtime( void )
{
 struct tms buf;
 return ( (double) (times( &buf ) ) ) / ( (double) ( sysconf( _SC_CLK_TCK ) ) );
} 

int main(int argc, char* argv[])
{

  long int i; // iterator
  long int N; // number of samples

  long int sum_pi = 0;
  double pi_approx;

  double t1, t2;

  if (argc<2) {
    fprintf(stderr, "Error: argc must be > 1\n");
    exit(-1);
  }

  // convert argument argv[1] into a long integer
  N=atol(argv[1]);

  // initialize random sequence seed
  srand(12);

  t1=wtime();
  for (i=0; i<N; i++) {
    // x,y cartesian coordinate in [0, 1]
    double x = ( (double) rand() ) / RAND_MAX;
    double y = ( (double) rand() ) / RAND_MAX;

    double r = x*x+y*y;
    
    if (r<1.0)
      sum_pi++;
    
  }
  t2=wtime();

  printf("N=%ld, sum_pi=%ld\n",N,sum_pi);
  pi_approx=(4.0*sum_pi)/N;
  printf("Approx pi = %g\n",pi_approx);
  printf("(pi_approx-pi)/pi=%8.7g\n",fabs(pi_approx-M_PI)/M_PI);
  printf("time in seconds: %g\n",t2-t1);

  return 0;
}
