#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

int main(int argc, char* argv[])
{
  int N=100;
  int size, rank, *fakeData;
  int i;
  
  MPI_Init ( &argc , &argv ) ;
  MPI_Comm_size ( MPI_COMM_WORLD, &size );
  MPI_Comm_rank ( MPI_COMM_WORLD, &rank );

  // if command has one argument, use it to specify fakeData array length
  if (argc > 1)
    N = atoi(argv[1]);
  
  fakeData = (int *) malloc(N*sizeof(int));
  
  if ( 0 == rank ) {
    for (i=0; i<N; ++i)
      fakeData[i] = i*i;
  }
  MPI_Bcast ( fakeData, N, MPI_INT, 0, MPI_COMM_WORLD ) ;
  
  free(fakeData);
    
  MPI_Finalize ( ) ;
  return EXIT_SUCCESS;
}
