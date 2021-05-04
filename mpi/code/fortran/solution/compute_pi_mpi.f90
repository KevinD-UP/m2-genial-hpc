!
! mpif90 -O3 -Wall -o compute_pi_mpi compute_pi_mpi.f90 -lm
!

program compute_pi_mpi

  use mpi

  implicit none

  ! process command line argument
  integer :: argc
  character(len=64) :: arg
  integer :: length, status

  ! measure computing time
  real(kind=8) :: t1, t2

  ! algorithm parameters
  integer(kind=8) :: i ! iterator
  integer(kind=8) :: N ! number of samples

  integer(kind=8) :: sum_pi = 0, sum_pi_total = 0
  real :: pi_approx, pi_true
  real :: x,y,r

  ! mpi parameters
  integer :: nbTask
  integer :: myRank
  integer :: dest
  integer :: ierr
  integer, dimension(MPI_STATUS_SIZE) :: status_mpi


  call MPI_Init(ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myRank, ierr)

  ! init
  sum_pi = 0
  pi_true = 4.0*ATAN(1.0)

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

     ! send N to all other MPI process
     do dest=1,nbTask-1
        call MPI_Send(N, 1, MPI_INT, dest, 0, MPI_COMM_WORLD, ierr)
     end do

  else
     
     ! all other mpi processes receives information 'N'
     !call MPI_Recv(N, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
     call MPI_Recv(N, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, status_mpi, ierr)

  end if
  
  ! initialize random sequence seed
  ! make sure each task get a different seed
  call init_random_seed()

  t1 = MPI_Wtime()
  do i=1,N/nbTask-1
     ! x,y cartesian coordinate in [0, 1]
     call random_number(x)
     call random_number(y)
     
     r = x*x+y*y

     if (r<1.0) then
        sum_pi = sum_pi + 1
     end if
     
  end do

  ! monitoring
  !write(*,*) 'rank',myRank,'sum_pi',sum_pi

  ! compute global sum from local partial sum
  ! put result in sum_pi_total in rank 0
  call MPI_Reduce(sum_pi, sum_pi_total, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD, ierr)
  t2 = MPI_Wtime()

  if (myRank==0) then
    write(*,*) 'N=',N,' sum_pi=',sum_pi_total
    pi_approx = (4.0*sum_pi_total) / N
    write(*,*) 'Approx pi = ',pi_approx
    write(*,*) '(pi_approx-pi)/pi=',abs(pi_approx-pi_true)/pi_true
    print '("time in seconds (measure in proc 0): ",f9.6)',t2-t1
 end if

  call MPI_Finalize(ierr)

end program compute_pi_mpi


!
!
!
subroutine init_random_seed()
  use iso_fortran_env, only: int64
  implicit none
  integer, allocatable :: seed(:)
  integer :: i, n, un, istat, dt(8), pid
  integer(int64) :: t

  call random_seed(size = n)
  allocate(seed(n))
  ! First try if the OS provides a random number generator
  open(newunit=un, file="/dev/urandom", access="stream", &
       form="unformatted", action="read", status="old", iostat=istat)
  if (istat == 0) then
     read(un) seed
     close(un)
  else
     ! Fallback to XOR:ing the current time and pid. The PID is
     ! useful in case one launches multiple instances of the same
     ! program in parallel.
     call system_clock(t)
     if (t == 0) then
        call date_and_time(values=dt)
        t = (dt(1) - 1970) * 365_int64 * 24 * 60 * 60 * 1000 &
             + dt(2) * 31_int64 * 24 * 60 * 60 * 1000 &
             + dt(3) * 24_int64 * 60 * 60 * 1000 &
             + dt(5) * 60 * 60 * 1000 &
             + dt(6) * 60 * 1000 + dt(7) * 1000 &
             + dt(8)
     end if
     pid = getpid()
     t = ieor(t, int(pid, kind(t)))
     do i = 1, n
        seed(i) = lcg(t)
     end do
  end if
  call random_seed(put=seed)
contains
  ! This simple PRNG might not be good enough for real work, but is
  ! sufficient for seeding a better PRNG.
  function lcg(s)
    integer :: lcg
    integer(int64) :: s
    if (s == 0) then
       s = 104729
    else
       s = mod(s, 4294967296_int64)
    end if
    s = mod(s * 279470273_int64, 4294967291_int64)
    lcg = int(mod(s, int(huge(0), int64)), kind(0))
  end function lcg
end subroutine init_random_seed
