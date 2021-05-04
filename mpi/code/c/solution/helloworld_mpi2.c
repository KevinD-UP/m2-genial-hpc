/*
 * 1. build standard:
 *
 *   mpicc -o helloworld_mpi2 helloworld_mpi2.c
 *
 * 2. build pour faire du tracing temporel
 *
 *    - module load tau
 *    - export TAU_MAKEFILE=$TAU_ROOT/x86_64/lib/Makefile.tau-mpi
 *    - export TAU_TRACE=1
 *    - tau_cc.sh -o helloworld_mpi2 helloworld_mpi2.c
 *    - mpirun -np 2 ./helloworld_mpi2
 *    - tau_treemerge.pl
 *    - tau2slog2 tau.trc tau.edf -o tau.slog2
 *    - jumpshot
 *
 * Note : les 3 dernières étapes peuvent se condenser en une seule:
 *    - jumpshot -merge
 */

#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

int main(int argc, char* argv[])
{

  int nbTask;
  int myRank;

  MPI_Status status;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  printf("I am task %d out of %d\n",myRank,nbTask);

  if (myRank == 0) {
    int dataToSend = 33;
    printf("[Task %d]: I'm sending data %d to rank 1\n",myRank,dataToSend);
    MPI_Send(&dataToSend, 1, MPI_INT, 1, 100, MPI_COMM_WORLD);
  } else if (myRank == 1) {
    int dataRecv;
    MPI_Recv(&dataRecv, 1, MPI_INT, 0, 100, MPI_COMM_WORLD, &status);
    printf("[Task %d] I received data %d from task 0\n",myRank,dataRecv);
  }

  MPI_Finalize();

  return 0;

}
