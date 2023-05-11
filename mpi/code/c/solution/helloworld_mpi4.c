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

//static const int N=1000;

int main(int argc, char* argv[])
{

  int nbTask;
  int myRank;

  /* send / recv data array */
  int *dataS, *dataR;
  int i;

  MPI_Status status;

  int tag1 = 1;
  int tag2 = 2;
  int N =0;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  printf("I am task %d out of %d\n",myRank,nbTask);

  if (myRank == 0) {
	  N = 100;

	  dataS = (int *) malloc(N *sizeof(int));

	  /* data to send initialization */
	  for (i=0; i<N; i++) {
		  dataS[i] = (myRank+1)*i;
	  }

	  printf("[Task %d]: I'm sending data size to rank 1\n",myRank);
	  MPI_Send(&N, 1, MPI_INT, 1, tag2, MPI_COMM_WORLD);

	  printf("[Task %d]: I'm sending data to rank 1\n",myRank);
	  MPI_Send(dataS, N, MPI_INT, 1, tag1, MPI_COMM_WORLD);

	  free(dataS);


  } else if (myRank == 1) {

	  MPI_Recv(&N, 1, MPI_INT, 0, tag2, MPI_COMM_WORLD, &status);
	  printf("[Task %d] I received data size = %d from task 0\n",myRank,N);

	  dataR = (int *) malloc(N *sizeof(int));

	  MPI_Recv(dataR, N, MPI_INT, 0, tag1, MPI_COMM_WORLD, &status);
	  printf("[Task %d] I received data from task 0\n",myRank);

	  free(dataR);
  }

  MPI_Finalize();

  return 0;

}
