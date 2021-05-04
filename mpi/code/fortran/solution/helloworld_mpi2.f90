program helloworld_mpi2

  use mpi

  implicit none

  integer   :: nbTask, myRank, ierr
  integer, dimension(MPI_STATUS_SIZE)         :: status

  integer :: dataToSend, dataRecv

  call MPI_Init(ierr)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)

  write (*,*) 'I am task', myRank, 'out of',nbTask

  if (myRank == 0) then
     dataToSend = 33
     write (*,*) "[Task ",myRank,"]: I'm sending data ",dataToSend," to rank 1"
     call MPI_SEND(dataToSend, 1, MPI_INTEGER, 1, 100, MPI_COMM_WORLD, ierr)
  else if (myRank == 1) then
     call MPI_RECV(dataRecv,   1, MPI_INTEGER, 0, 100, MPI_COMM_WORLD, status, ierr)
     write (*,*) "[Task ",myRank,"] I received data ",dataRecv," from task 0"
  end if

  call MPI_Finalize(ierr)

end program helloworld_mpi2
