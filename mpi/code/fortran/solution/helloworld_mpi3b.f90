!
! first example with a deadlock 
!
! take care that the deadlock 'disappear' for small message length
!
! Try to use N=1000 (no deadlock with OpenMPI) and N=10000 (deadlock)
!


program helloworld_mpi3

  use mpi

  implicit none

  integer   :: nbTask, myRank, ierr
  integer, dimension(MPI_STATUS_SIZE)         :: status

  integer, parameter :: N=10000
  integer :: dataToSend(N), dataRecv(N)

  call MPI_Init(ierr)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)

  write (*,*) 'I am task', myRank, 'out of',nbTask

  if (myRank == 0) then

     dataToSend = 33

     write (*,*) "[Task ",myRank,"] I'm sending data to rank 1", dataToSend
     call MPI_SEND(dataToSend, N, MPI_INTEGER, 1, 100, MPI_COMM_WORLD, ierr)

     call MPI_RECV(dataRecv,   N, MPI_INTEGER, 1, 100, MPI_COMM_WORLD, status, ierr)
     write (*,*) "[Task ",myRank,"] I received data  from task 0",dataRecv

  else if (myRank == 1) then

     dataToSend = 34

     write (*,*) "[Task ",myRank,"] I'm sending data to rank 0"
     call MPI_SEND(dataToSend, N, MPI_INTEGER, 0, 100, MPI_COMM_WORLD, ierr)

     call MPI_RECV(dataRecv,   N, MPI_INTEGER, 0, 100, MPI_COMM_WORLD, status, ierr)
     write (*,*) "[Task ",myRank,"] I received data  from task 0"


  end if

  call MPI_Finalize(ierr)

end program helloworld_mpi3
