/*
 * mpicc -O3 -o compute_pi_mpi compute_pi_mpi.c -lm
 */

#include <stdio.h>
#include <stdlib.h>

#include <math.h> // for M_PI

#include <mpi.h>

int main(int argc, char *argv[])
{

  long int i, j; // iterator
  long int N;    // number of samples

  int Nrepeat = 1000; // repeat number

  long int sum_pi = 0;
  long int sum_pi_total = 0;
  double pi_approx;

  double t1, t2, t3;
  t1 = t2 = t3 = 0.0;

  int nbTask;
  int myRank;

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  if (myRank == 0) {
    if (argc < 2) {
      fprintf(stderr, "You must provide a number of samples\n");
      MPI_Abort(MPI_COMM_WORLD, 0);
      exit(0);
    }
  }
  // to avoid task with rank>0 to call atoi with a wrong pointer argument
  MPI_Barrier(MPI_COMM_WORLD);

  // argc is > 1, we can proceed
  N = atoi(argv[1]);

  // initialize random sequence seed
  // make sure each task get a different seed
  srand(12 * myRank);

  for (j = 0; j < Nrepeat; j++) {

    sum_pi = 0;
    sum_pi_total = 0;

    t1 += MPI_Wtime();
    for (i = 0; i < N / nbTask; i++) {
      // x,y cartesian coordinate in [0, 1]
      double x = ((double)rand()) / RAND_MAX;
      double y = ((double)rand()) / RAND_MAX;

      double r = x * x + y * y;

      if (r < 1.0)
        sum_pi++;
    }
    t2 += MPI_Wtime();

    // compute global sum from local partial sum
    // put result in sum_pi_total in rank 0
    MPI_Reduce(&sum_pi, &sum_pi_total, 1, MPI_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    t3 += MPI_Wtime();

  } // end for j

  if (myRank == 0) {
    printf("N=%ld, sum_pi=%ld\n", N, sum_pi_total);
    pi_approx = (4.0 * sum_pi_total) / N;
    printf("Approx pi = %g\n", pi_approx);
    printf("(pi_approx-pi)/pi=%8.7g\n", fabs(pi_approx - M_PI) / M_PI);
    printf("time in seconds    : %g\n", (t3 - t1) / Nrepeat);
    printf("time communications: %g\n", (t3 - t2) / Nrepeat);
  }

  MPI_Barrier(MPI_COMM_WORLD);

  if (myRank == 1) {
    printf("\n\nN=%ld, sum_pi=%ld\n", N, sum_pi_total);
    pi_approx = (4.0 * sum_pi_total) / N;
    printf("Approx pi = %g\n", pi_approx);
    printf("(pi_approx-pi)/pi=%8.7g\n", fabs(pi_approx - M_PI) / M_PI);
    printf("time in seconds    : %g\n", (t3 - t1) / Nrepeat);
    printf("time communications: %g\n", (t3 - t2) / Nrepeat);
  }

  MPI_Finalize();

  return 0;
}
