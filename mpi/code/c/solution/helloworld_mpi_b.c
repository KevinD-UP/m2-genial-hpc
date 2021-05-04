#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

int main(int argc, char* argv[])
{

  int nbTask;
  int myRank;

  char proc_name[MPI_MAX_PROCESSOR_NAME];
  char mpi_library_name[MPI_MAX_LIBRARY_VERSION_STRING];
  int string_length;

  int mpi_version, mpi_subversion;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  if (myRank == 0) {
    MPI_Get_version(&mpi_version, &mpi_subversion);
    printf("MPI standard version is %d.%d\n\n",mpi_version,mpi_subversion);

    // this is a MPI-3 routine
    // you must have openmpi 1.8.x at least
    MPI_Get_library_version(mpi_library_name, &string_length);
    printf("MPI implementation is:\n%s\n",mpi_library_name);

  }

  MPI_Get_processor_name(proc_name, &string_length);

  printf("I am task %d out of %d on processor %s\n",myRank,nbTask,proc_name);

  MPI_Finalize();

  return 0;

}
