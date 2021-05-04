! File:    trap.f90
! Purpose: Calculate definite integral using trapezoidal 
!          rule.
!
! Input:   a, b, n
! Output:  Estimate of integral from a to b of f(x)
!          using n trapezoids.
!
! Compile: gfortran -g -Wall -o trap trap.f90
! Usage:   ./trap
!
! Note:    The function f(x) is hardwired.
!
! IPP:     Section 3.2.1 (pp. 94 and ff.) and 5.2 (p. 216)
!

program trap
  
  implicit none

   real(kind=8)  :: integral   ! Store result in integral
   real(kind=8)  :: a, b       ! Left and right endpoints
   integer       :: n          ! Number of trapezoids
   real(kind=8)  :: h          ! Height of trapezoids


   write(*,*) 'Enter a : '; read(*,*) a
   write(*,*) 'Enter b : '; read(*,*) b
   write(*,*) 'Enter n : '; read(*,*) n

   h = (b-a)/n
   call trap_compute(a, b, n, h, integral)

   write (*,*) 'With n = ',n,' trapezoids, our estimate'
   write (*,*) 'of the integral from ',a,' to ',b,' = ',integral

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
   ! Function:     Trap
   ! Purpose:      Serial function for estimating a definite integral 
   !               using the trapezoidal rule
   ! Input args:   a : left endpoint
   !               b : right ndpoint
   !               n : number of segments
   !               h : base_len
   ! Return val:   estimate defined as 
   !               Trapezoidal rule estimate of integral from
   !               left_endpt to right_endpt using trap_count
   !               trapezoids
   !------------------------------------------------------------------
   subroutine trap_compute(a, b, n, h, integral)
     
     implicit none
     
     ! dummy variables
     real(kind=8), intent(in)  :: a
     real(kind=8), intent(in)  :: b
     integer,      intent(in)  :: n
     real(kind=8), intent(in)  :: h
     real(kind=8), intent(out) :: integral
     
     ! local variables
     integer :: k
     
     integral = ( f(a) + f(b) ) / 2.0
     do k = 1,n-1
        integral = integral + f(a+k*h)
     end do
     integral = integral*h;
     
   end subroutine trap_compute
   
 end program trap
