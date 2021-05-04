/*
 * mpicc -o helloworld_mpi3 helloworld_mpi3.c
 */

#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

int main(int argc, char* argv[])
{

  int nbTask;
  int myRank;

  MPI_Status status;

  int tag1 = 1;
  int tag2 = 2;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  printf("I am task %d out of %d\n",myRank,nbTask);

  if (myRank == 0) {

    int dataRecv, dataToSend = 33;
    printf("[Task %d] I'm sending data %d to rank 1\n",myRank,dataToSend);
    MPI_Send(&dataToSend, 1, MPI_INT, 1, tag1, MPI_COMM_WORLD);

    MPI_Recv(&dataRecv,   1, MPI_INT, 1, tag2, MPI_COMM_WORLD, &status);
    printf("[Task %d] I received data %d from task 1\n",myRank,dataRecv);

  } else if (myRank == 1) {

    int dataRecv, dataToSend = 34;
    MPI_Recv(&dataRecv,   1, MPI_INT, 0, tag1, MPI_COMM_WORLD, &status);
    printf("[Task %d] I received data %d from task 0\n",myRank,dataRecv);

    printf("[Task %d] I'm sending data %d to rank 0\n",myRank,dataToSend);
    MPI_Send(&dataToSend, 1, MPI_INT, 0, tag2, MPI_COMM_WORLD);

  }

  MPI_Finalize();

  return 0;

}
