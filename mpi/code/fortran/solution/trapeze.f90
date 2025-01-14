!
! calcul d'une integrale par la methode des trapezes.
!
! gfortran -O2 -Wall trapeze.f90 -o trapeze
!

program trapeze

  implicit none

  ! les bornes de l'integrale
  real(kind=8) :: a,b

  ! nombre de segments total
  integer :: n = 1024
 
  ! longueur d'un segment
  real(kind=8) :: dx

  ! calcul local  d'integrale
  real(kind=8) :: integral

  !a = 0.0
  !b = 1.0

  write(*,*) 'Enter a : '; read(*,*) a
  write(*,*) 'Enter b : '; read(*,*) b
  write(*,*) 'Enter n : '; read(*,*) n

  ! calcul les bornes d'integration locale
  dx = (b-a)/n

  ! compute integral
  call compute_integral(a,dx,n,integral)
  
  write(*,*) 'Resultat final : ',integral
  write(*,*) 'Erreur absolue : ',integral - (f_primitive(b) - f_primitive(a) )

contains

   function f(x) result(y)
     
     implicit none
     
     real(kind=8), intent(in) :: x
     real(kind=8)             :: y
     
     y = 4.0/(1.0+x*x)
     
   end function f

   ! utilisée a posteriori pour vérification
   function f_primitive(x) result(y)
     
     implicit none
     
     real(kind=8), intent(in) :: x
     real(kind=8)             :: y
     
     y = 4.0*atan(x)
     
   end function f_primitive

  subroutine compute_integral(start, dx, nSegments, integral)
    
    implicit none

    ! dummy variables
    real(kind=8), intent(in)  :: start
    real(kind=8), intent(in)  :: dx
    integer,      intent(in)  :: nSegments
    real(kind=8), intent(out) :: integral

    ! local variables
    integer      :: i
    real(kind=8) :: x1

    integral = 0.0

    do i=0,nSegments-1
    
       x1 = start + dx*i
       integral = integral + ( f(x1) + f(x1 + dx) ) / 2 * dx
       
    end do

  end subroutine compute_integral

end program trapeze
