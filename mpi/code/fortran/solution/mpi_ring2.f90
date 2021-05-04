!
! mpif90 -O3 -o mpi_ring2 mpi_ring2.f90
!
! todo: change MPI_Send by MPI_Isend
!

program mpi_ring2

  use mpi
  use iso_fortran_env, only : error_unit

  implicit none

  integer :: nbTasks, myRank, len, ierr
  character(MPI_MAX_PROCESSOR_NAME) :: hostname
  
  integer :: dataRecv
  integer :: idSend, idRecv
  integer, dimension(MPI_STATUS_SIZE)         :: status
  integer :: stats(MPI_STATUS_SIZE,1), reqs(1)

  ! init
  call MPI_Init(ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nbTasks, ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myRank, ierr)
  call MPI_Get_processor_name(hostname, len, ierr)

  write(*,*) 'Hello from task ', myRank, ' on ', hostname

  if (nbTasks < 2 .and. myRank==0) then
     write(error_unit, '(a)') 'Can only be run if nbTasks is > 2 !!'
     call MPI_Abort(MPI_COMM_WORLD,0, ierr)
  end if
  
  idSend = modulo(myRank+1+nbTasks, nbTasks)
  idRecv = modulo(myRank-1+nbTasks, nbTasks)

  call MPI_Irecv(dataRecv, 1, MPI_INTEGER, idRecv, 0, MPI_COMM_WORLD, reqs(1), ierr)
  call MPI_Send(myRank   , 1, MPI_INTEGER, idSend, 0, MPI_COMM_WORLD, ierr)

  ! do some work

  call MPI_Waitall(1, reqs, stats, ierr)

  write(*,*) 'task ', myRank, 'received data : ', dataRecv
  
  ! end
  call MPI_Finalize(ierr)

end program mpi_ring2
