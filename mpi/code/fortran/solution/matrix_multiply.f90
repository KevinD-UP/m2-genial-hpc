program matrix_multiply

  implicit none

  integer, parameter :: NRA = 12
  integer, parameter :: NCA = 9
  integer, parameter :: NCB = 7

  integer :: i, j, k
  real(kind=8), dimension(NRA,NCA) :: a
  real(kind=8), dimension(NCA,NCB) :: b
  real(kind=8), dimension(NRA,NCB) :: c

  print *,'Starting serial matrix multiple example...'
  write(*,100) NRA,NCA,NCA,NCB,NRA,NCB
100 format(' Using matrix sizes a(',I2,',',I2,'), b(',I2,',',I2,'), c(',I2,',',I2,')')
  
  ! Initialize A and B 
  print *,'Initializing matrices...'
  do i=1, NRA
     do j=1, NCA
        a(i,j) = i+j
     end do
  end do

  do i=1, NCA
     do j=1, NCB
        b(i,j) = i*j
     end do
  end do
  
  ! Do matrix multiply
  print *,'Performing matrix multiply...'
  do k=1, NCB 
     do i=1, NRA
        c(i,k) = 0.0
        do j=1, NCA
           c(i,k) = c(i,k) + a(i,j) * b(j,k)
        end do
     end do
  end do

  ! Print results 
  print *, 'Here is the result matrix: '
  do i=1, NRA
     do j = 1, NCB
        write(*,'(1x,F8.2,$)') c(i,j)
     end do
     print *, ' '
  end do

  print *, 'Done.'
  print *, ' '

end program matrix_multiply
