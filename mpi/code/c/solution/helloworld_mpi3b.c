/*
 * first example with a deadlock
 *
 * take care that the deadlock 'disappear' for small message length
 *
 * Try to use N=1000 (no deadlock with OpenMPI) and N=10000 (deadlock)
 *
 * Try to use mpirun option '--mca btl_vader_eager_limit 8192' to increase
 * the eager limit
 */

#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

static const int N=10000;

int main(int argc, char* argv[])
{

  int nbTask;
  int myRank;

  /* send / recv data array */
  int dataS[N], dataR[N];
  int i;

  MPI_Status status;

  int tag1 = 1;
  int tag2 = 2;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  /* data to send initialization */
  for (i=0; i<N; i++) {
    dataS[i] = (myRank+1)*i;
    dataR[i] = 0;
  }

  printf("I am task %d out of %d\n",myRank,nbTask);

  if (myRank == 0) {

    printf("[Task %d]: I'm sending data to rank 1\n",myRank);
    MPI_Send(&(dataS[0]), N, MPI_INT, 1, tag1, MPI_COMM_WORLD);

    MPI_Recv(&(dataR[0]), N, MPI_INT, 1, tag2, MPI_COMM_WORLD, &status);
    printf("[Task %d] I received data from task 1\n",myRank);

  } else if (myRank == 1) {

    printf("[Task %d]: I'm sending data to rank 0\n",myRank);
    MPI_Send(&(dataS[0]), N, MPI_INT, 0, tag2, MPI_COMM_WORLD);

    MPI_Recv(&(dataR[0]), N, MPI_INT, 0, tag1, MPI_COMM_WORLD, &status);
    printf("[Task %d] I received data from task 0\n",myRank);
  }

  MPI_Finalize();

  return 0;

}
