! File:     mpi_trap3.f90
! Purpose:  Use MPI to implement a parallel version of the trapezoidal 
!           rule.  This version uses collective communications to 
!           distribute the input data and compute the global sum.
!
! Input:    None.
! Output:   Estimate of the integral from a to b of f(x)
!           using the trapezoidal rule and n trapezoids.
!
! Compile:  mpif90 -g -Wall -o mpi_trap3 mpi_trap3.f90
! Run:      mpirun -n <number of processes> ./mpi_trap3
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
! Note:  f(x) is hardwired.
!
! IPP:   Section 3.4.2 (pp. 104 and ff.)
!

program mpi_trap3

  use mpi

  implicit none

  integer      :: my_rank, comm_sz, ierr, n, local_n
  real(kind=8) :: a, b, h, local_a, local_b
  real(kind=8) :: local_int, total_int

  real(kind=8), parameter :: my_pi = 4.0*atan(1.0)

  ! Let the system do what it needs to start up MPI
  call MPI_Init(ierr)

  ! Get my process rank
  call MPI_Comm_rank(MPI_COMM_WORLD, my_rank, ierr)

  ! Find out how many processes are being used
  call MPI_Comm_size(MPI_COMM_WORLD, comm_sz, ierr)

  ! initialize
  !n = 1024*10
  !a = 0.0
  !b = 1.0
  call get_input(my_rank, a, b, n)

  h = (b-a)/n          ! h is the same for all processes
  local_n = n/comm_sz  ! So is the number of trapezoids

  ! Length of each process' interval of
  ! integration = local_n*h.  So my interval
  ! starts at:
  local_a   = a       + my_rank*local_n*h
  local_b   = local_a +         local_n*h
  call Trap(local_a, local_b, local_n, h, local_int)

  ! Add up the integrals calculated by each process
  call MPI_Reduce(local_int, total_int, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD, ierr)

  ! Print the result
  if (my_rank == 0) then
     write(*,*) 'Number of trapezoids : ', n
     write(*,*) 'Integral from ',a,' to ',b,' = ',total_int
     write(*,*) 'Exact value : ', f_primitive(b) - f_primitive(a)
     write(*,*) 'error : ',total_int-(f_primitive(b) - f_primitive(a))
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

    y = x*x

  end function f

  !------------------------------------------------------------------
  ! Function:    f_primitive : 
  ! Purpose:     Compute value of function to be integrated
  ! Input args:  x
  !------------------------------------------------------------------
  function f_primitive(x) result(y)

    implicit none

    real(kind=8), intent(in) :: x
    real(kind=8)             :: y

    y = x*x*x/3.0

  end function f_primitive

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

  ! ------------------------------------------------------------------
  ! Function:     Get_input
  ! Purpose:      Get the user input:  the left and right endpoints
  !               and the number of trapezoids
  ! Input args:   my_rank:  process rank in MPI_COMM_WORLD
  !               comm_sz:  number of processes in MPI_COMM_WORLD
  ! Output args:  a:  left endpoint               
  !               b:  right endpoint               
  !               n:  number of trapezoids
  ! ------------------------------------------------------------------
  subroutine get_input(my_rank, a, b, n)

    implicit none

    ! dummy variables
    integer,      intent(in)  :: my_rank
    real(kind=8), intent(out) :: a
    real(kind=8), intent(out) :: b
    integer,      intent(out) :: n
    
    ! local variables
    integer :: ierr

   if (my_rank == 0) then
      print *, 'Enter a : '; read(*,*) a
      write(*,*) 'Enter b : '; read(*,*) b
      write(*,*) 'Enter n : '; read(*,*) n
   end if

   call MPI_Bcast(a, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(b, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(n, 1, MPI_INT,    0, MPI_COMM_WORLD, ierr)

 end subroutine get_input

end program mpi_trap3


