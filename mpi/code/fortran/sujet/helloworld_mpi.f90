program helloworld_mpi

  use mpi

  implicit none

  integer   :: nbTask, myRank, ierr

  call MPI_Init(ierr)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)

  write (*,*) 'I am task', myRank, 'out of',nbTask

  call MPI_Finalize(ierr)

end program helloworld_mpi
