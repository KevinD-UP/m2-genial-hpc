!
! mpif90 -O3 -o mpi_ring mpi_ring.f90
!

program mpi_ring

  use mpi
  use iso_fortran_env, only : error_unit

  implicit none

  integer :: nbTasks, myRank, len, ierr
  character(MPI_MAX_PROCESSOR_NAME) :: hostname
  
  integer :: dataRecv
  integer :: idSend, idRecv
  integer, dimension(MPI_STATUS_SIZE)         :: status
  integer :: jeton ! initialisé à 12 sur le rang 0
  
  ! init
  call MPI_Init(ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nbTasks, ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myRank, ierr)
  call MPI_Get_processor_name(hostname, len, ierr)

  jeton = 12
  
  write(*,*) 'Hello from task ', myRank, ' on ', hostname

  if (nbTasks < 2 .and. myRank==0) then
     write(error_unit, '(a)') 'Can only be run if nbTasks is > 2 !!'
     call MPI_Abort(MPI_COMM_WORLD,0, ierr)
  end if
  
  idSend = modulo(myRank+1+nbTasks, nbTasks)
  idRecv = modulo(myRank-1+nbTasks, nbTasks)

  if (myRank == 0) then
     call MPI_Send(jeton   , 1, MPI_INTEGER, idSend, 0, MPI_COMM_WORLD, ierr)
     call MPI_Recv(dataRecv, 1, MPI_INTEGER, idRecv, 0, MPI_COMM_WORLD, status, ierr)
     write(*,*) 'MPI rank is ',myRank,' : jeton (recu) = ',dataRecv
  else
     call MPI_Recv(dataRecv, 1, MPI_INTEGER, idRecv, 0, MPI_COMM_WORLD, status, ierr)
     write(*,*) 'MPI rank is ',myRank,' : jeton (recu) = ',dataRecv
     jeton = dataRecv+1
     call MPI_Send(jeton   , 1, MPI_INTEGER, idSend, 0, MPI_COMM_WORLD, ierr)
  end if

  write(*,*) 'task ', myRank, 'received data : ', dataRecv
  
  ! end
  call MPI_Finalize(ierr)

end program mpi_ring
