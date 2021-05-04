/*
 * A very simple example use of MPI_Comm_split.
 */


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <mpi.h>

int getColor(int rank)
{

  return rank%2;

}


int main (int argc, char* argv[])
{

  int var = 0;
  int iProc;

  // MPI variables
  int myRank;
  int nbTasks;
  MPI_Status status;

  MPI_Comm newComm;
  
  MPI_Init(&argc, &argv);
  
  MPI_Comm_size(MPI_COMM_WORLD, &nbTasks);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  var = myRank*myRank;

  // create a new communicator
  MPI_Comm_split(MPI_COMM_WORLD, getColor(myRank), myRank, &newComm);

  {
    int myRankSplit;
    int nbTasksSplit;

    int reduceVar;

    MPI_Comm_size(newComm, &nbTasksSplit);
    MPI_Comm_rank(newComm, &myRankSplit);

    for (iProc=0; iProc<nbTasks; iProc++) {
      if (myRank == iProc && getColor(myRank) == 0)
	printf("[myRank=%d] I'm rank %d in the new communicator out of %d (color = %d)\n",myRank, myRankSplit, nbTasksSplit, getColor(myRank));
      MPI_Barrier(MPI_COMM_WORLD);
    }

    // compute sum of rank inside the new communicator
    MPI_Reduce(&myRank, &reduceVar, 1, MPI_INT, MPI_SUM, 0, newComm);

    if (myRankSplit == 0)
      printf("Sum of rank for color %d is : %d\n",getColor(myRank),reduceVar);

  }

  MPI_Finalize();

  return EXIT_SUCCESS;
}
