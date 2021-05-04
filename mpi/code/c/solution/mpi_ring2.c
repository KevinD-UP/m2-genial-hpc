#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>


int main (int argc, char *argv[])
{
  int nbTasks, myRank, len;
  char hostname[MPI_MAX_PROCESSOR_NAME];
  
  MPI_Status status;
  MPI_Request request;

  int dataRecv;
  int idSend, idRecv;
  
  // init
  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &nbTasks);
  MPI_Comm_rank(MPI_COMM_WORLD,&myRank);
  MPI_Get_processor_name(hostname, &len);
  printf ("Hello from task %d on %s!\n", myRank, hostname);

  if (nbTasks < 2 && myRank==0) {
    fprintf(stderr,"Can only be run if nbTasks is > 2 !!\n");
    MPI_Abort(MPI_COMM_WORLD,0);
    exit(0);
  }
  
  //MPI_Barrier(MPI_COMM_WORLD);

  idSend = (myRank+1+nbTasks) % nbTasks;
  idRecv = (myRank-1+nbTasks) % nbTasks;

  MPI_Isend(&myRank , 1, MPI_INT, idSend, 0, MPI_COMM_WORLD, &request);
  MPI_Recv(&dataRecv, 1, MPI_INT, idRecv, 0, MPI_COMM_WORLD, &status);

  /* now block until requests are complete */
  MPI_Wait(&request, &status);

  /* MPI_Barrier(MPI_COMM_WORLD); */
  printf("task %d received data %d\n", myRank, dataRecv);
  
  // end
  MPI_Finalize();

}

