! File:     mpi_trap1.f90
! Purpose:  Use MPI to implement a parallel version of the trapezoidal 
!           rule.  In this version the endpoints of the interval and
!           the number of trapezoids are hardwired.
!
! Input:    None.
! Output:   Estimate of the integral from a to b of f(x)
!           using the trapezoidal rule and n trapezoids.
!
! Compile:  mpif90 -g -Wall -o mpi_trap1 mpi_trap1.f90
! Run:      mpirun -n <number of processes> ./mpi_trap1
!
! Algorithm:
!    1.  Each process calculates "its" interval of
!        integration.
!    2.  Each process estimates the integral of f(x)
!        over its interval using the trapezoidal rule.
!    3a. Each process != 0 sends its integral to 0.
!    3b. Process 0 sums the calculations received from
!        the individual processes and prints the result.
!
! Note:  f(x), a, b, and n are all hardwired.
!
! IPP:   Section 3.2.2 (pp. 96 and ff.)
!

program mpi_trap1

  use mpi

  implicit none

  integer      :: my_rank, comm_sz, ierr, n, local_n
  real(kind=8) :: a, b, h, local_a, local_b
  real(kind=8) :: local_int, total_int
  integer      :: source

  real(kind=8), parameter :: my_pi = 4.0*atan(1.0)

  ! Let the system do what it needs to start up MPI
  call MPI_Init(ierr)

  ! Get my process rank
  call MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierr)

  ! Find out how many processes are being used
  call MPI_Comm_size(MPI_COMM_WORLD, comm_sz, ierr)

  ! initialize
  n = 1024*10
  a = 0.0
  b = 1.0

  h = (b-a)/n          ! h is the same for all processes
  local_n = n/comm_sz  ! So is the number of trapezoids

  ! Length of each process' interval of
  ! integration = local_n*h.  So my interval
  ! starts at:
  local_a   = a       + my_rank*local_n*h
  local_b   = local_a +         local_n*h
  call Trap(local_a, local_b, local_n, h, local_int)

  ! Add up the integrals calculated by each process
  if (my_rank /= 0) then

     write(*,*) 'Proc ', my_rank, ' sending local_int=',local_int,'to proc 0'
     call MPI_Send(local_int, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, ierr)
     
  else
     write(*,*) 'Proc ', my_rank, '         local_int=',local_int

     total_int = local_int
     do source = 1, comm_sz-1
        call MPI_Recv(local_int, 1, MPI_DOUBLE, source, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
        total_int = total_int + local_int
     end do
  end if

  ! Print the result
  if (my_rank == 0) then
     write(*,*) 'With n =',n,'trapezoids, our estimate'
     write(*,*) 'of the integral from ',a,' to ',b,' = ',total_int
     write(*,*) 'error : ',total_int-my_pi
  end if

  ! Shut down MPI
  call MPI_Finalize(ierr)

contains

  !------------------------------------------------------------------
  ! Function:    f : the function we're integrating
  ! Purpose:     Compute value of function to be integrated
  ! Input args:  x
  !------------------------------------------------------------------
  function f(x) result(y)

    implicit none

    real(kind=8), intent(in) :: x
    real(kind=8)             :: y

    y = 4.d0/(1.d0+x*x)

  end function f

  !------------------------------------------------------------------
  ! Calculate local integral
  ! Function:     Trap
  ! Purpose:      Serial function for estimating a definite integral 
  !               using the trapezoidal rule
  ! Input args:   left_endpt
  !               right_endpt
  !               trap_count 
  !               base_len
  ! Return val:   estimate defined as 
  !               Trapezoidal rule estimate of integral from
  !               left_endpt to right_endpt using trap_count
  !               trapezoids
  !------------------------------------------------------------------
  subroutine Trap(left_endpt, right_endpt, trap_count, base_len, estimate)

    implicit none

    ! dummy variables
    real(kind=8), intent(in)  :: left_endpt
    real(kind=8), intent(in)  :: right_endpt
    integer,      intent(in)  :: trap_count
    real(kind=8), intent(in)  :: base_len
    real(kind=8), intent(out) :: estimate

    ! local variables
    real(kind=8) :: x 
    integer :: i

    estimate = ( f(left_endpt) + f(right_endpt) ) / 2.0
    do i = 1,trap_count-1
       x = left_endpt + i*base_len
       estimate = estimate + f(x)
    end do
    estimate = estimate*base_len

  end subroutine Trap

end program mpi_trap1


