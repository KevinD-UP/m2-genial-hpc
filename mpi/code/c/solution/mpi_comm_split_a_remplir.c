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

  // create a new communicator

  // compute Sum of myRank inside each partition of the new communicator
  // print "I'm rank %d in the new communicator with color %d\n"
  // also print "Sum of rank for color %d is : %d\n"

  MPI_Finalize();

  return EXIT_SUCCESS;
}
