!
! calcul d'une integrale par la methode des trapezes.
!
! A faire pour la prochaine fois :
!
! 1. remplacer les MPI_Send/MPI_Recv par un appel a MPI_Reduce pour collecter
!    les integrales partielles
! 2. Modifier l'interface du programme: le parametre n est passe sur la ligne
!    de commande, recupere par la tache 0 et ensuite "broadcaste" aux autres.
!
! 
!
! Compile:  mpif90 -g -Wall -o mpi_trapeze mpi_trapeze.f90
! Run:      mpirun -n <number of processes> ./mpi_trapeze


program mpi_trapeze

  use mpi

  implicit none

  integer :: iProc, ierr

  ! les bornes de l'integrale
  real(kind=8) :: a,b

  ! nombre de segments total
  integer :: n = 1024
 
  ! nombre de segment par tache MPI
  integer :: nSegments

  ! longueur d'un segment
  real(kind=8) :: dx

  ! bornes d'integrations locales
  real(kind=8) :: x_start,x_end

  ! calcul local  d'integrale
  real(kind=8) :: local_integral
  real(kind=8) :: global_integral = 0.0

  ! MPI variables
  integer :: myRank
  integer :: nbTasks

  ! initialiation
  a = 0.0
  b = 1.0

  call MPI_Init(ierr)

  call MPI_Comm_size(MPI_COMM_WORLD, nbTasks, ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, myRank, ierr)

  ! calcul les bornes d'integration locale
  dx = (b-a)/n

  nSegments = n/nbTasks+1
  if (myRank == nbTasks-1) then
     nSegments = n - (n/nbTasks+1)*(nbTasks-1)
  end if
  x_start = a + myRank*(n/nbTasks+1)*dx
  x_end   = x_start + nSegments*dx

  ! compute local integral
  call compute_integral(x_start,dx,nSegments,local_integral)

  do iProc=0,nbTasks-1
     if (myRank == iProc) then
        write(*,*) '[myRank=', myRank, ']', x_start, x_end, nSegments, local_integral
     end if
     call MPI_Barrier(MPI_COMM_WORLD,ierr)
  end do

  ! rassemble les morceaux
  if (myRank == 0) then
     
     global_integral = local_integral
     
     do iProc=1,nbTasks-1
        
        call MPI_Recv(local_integral, 1, MPI_DOUBLE, iProc, iProc, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)
        
        global_integral = global_integral + local_integral
        
     end do
     
     write(*,*) 'Resultat final : ',global_integral
     write(*,*) 'Erreur absolue : ',global_integral - (f_primitive(b) - f_primitive(a))
     
  else
     
     call MPI_Send(local_integral, 1, MPI_DOUBLE, 0, myRank, MPI_COMM_WORLD, ierr)
     
  end if
  
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
    ! Function:     compute_integral
    ! Purpose:      Serial function for estimating a definite integral 
    !               using the trapezoidal rule
    ! Input args:   start
    !               dx
    !               nSegments
    ! Return val:   integral defined as 
    !               Trapezoidal rule estimate of integral
    !------------------------------------------------------------------
    subroutine compute_integral(start, dx, nSegments, integral)

      implicit none

      ! dummy variables
      real(kind=8), intent(in)   :: start
      real(kind=8), intent(in)   :: dx
      integer     , intent(in)   :: nSegments
      real(kind=8), intent(out)  :: integral

      ! local variables
      integer :: i
      real(kind=8) :: local_int = 0.0
      real(kind=8) :: x1
      

      do i=0, nSegments-1
         
         x1 = start + dx*i
         local_int = local_int + ( f(x1) + f(x1 + dx) ) / 2 * dx
    
      end do

      integral = local_int
      
    end subroutine compute_integral

end program mpi_trapeze
