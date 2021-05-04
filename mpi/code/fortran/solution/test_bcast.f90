!
! mpif90 -O3 -Wall -o test_bcast test_bcast.f90 -lm
!

program test_bcast

  use mpi
  implicit none

  ! process command line argument
  integer :: argc
  character(len=64) :: arg
  integer :: length, status

  ! algorithm parameters
  integer :: i ! iterator
  integer :: N ! number of samples

  integer, dimension(:), allocatable :: fakeData

  ! mpi parameters
  integer :: nbTask
  integer :: myRank
  !integer :: dest
  integer :: ierr
  !integer, dimension(MPI_STATUS_SIZE) :: status_mpi

  call MPI_Init(ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myRank, ierr)

  ! process command line (on rank 0)
  if (myRank==0) then
     argc = COMMAND_ARGUMENT_COUNT()
     if (argc<1) then
        write(*,*) 'Error: argc must be >= 1 : ',argc
        call MPI_Abort(MPI_COMM_WORLD, -1, ierr)
     end if

     ! convert argument argv[1] into a long integer
     call GET_COMMAND_ARGUMENT(1, arg, length, status)
     read(arg, '(I10)') N
  end if

  ! broadcast N from rank 0, so that every other proc can allocate fakeData
  call MPI_Bcast(N, 1, MPI_INT, 0, MPI_COMM_WORLD, ierr)

  write(*,*) 'I am task', myRank, 'out of',nbTask, '  and N=',N
  
  ! memory allocation for fakeData
  allocate(fakeData(N))

  ! initialize fakeData on rank 0, all other just reset
  if (myRank == 0) then
     do i=1,N
        fakeData(i)=i*i
     end do
  else
     do i=1,N
        fakeData(i)=0
     end do
  end if
  
  ! broadcast fakeData
  call MPI_Bcast(fakeData, N, MPI_INT, 0, MPI_COMM_WORLD, ierr)

  deallocate(fakeData)
  
  call MPI_Finalize(ierr)

end program test_bcast

