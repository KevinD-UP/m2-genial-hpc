!
! gfortran -O3 -o test_random_number test_random_number.f90 -lm
!

program test_random_number

  implicit none

  ! process command line argument
  integer :: argc
  character(len=64) :: arg
  integer :: length, status

  ! measure computing time
  real :: t1, t2

  ! algorithm parameters
  integer(kind=8) :: N ! number of samples
  integer(kind=8) :: i ! iterator

  real :: x
  integer(kind=8) :: x_int

  ! process command line
  argc = COMMAND_ARGUMENT_COUNT()
  if (argc<1) then
     write(*,*) 'Error: argc must be >= 1 : ',argc
     stop
  end if

  ! convert argument argv[1] into a long integer
  call GET_COMMAND_ARGUMENT(1, arg, length, status)
  read(arg, '(I10)') N

  ! initialize random sequence seed
  !call random_seed(put=12)
  call init_random_seed()

  write(*,*) 'Random values in intervale 5-9'
  
  ! compute approximated value of pi
  do i=1,N
     ! x,y cartesian coordinate in [0, 1]
     call random_number(x)
     x_int = int(x*5+5)
     write(*,*) 'x = ',x,' ',x_int
  end do

end program test_random_number

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
