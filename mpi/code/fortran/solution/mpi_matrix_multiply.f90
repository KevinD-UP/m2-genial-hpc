!   In this code, the master task distributes a matrix multiply
!   operation to numtasks-1 worker tasks.
!   NOTE1:  C and Fortran versions of this code differ because of the way
!   arrays are stored/passed.  C arrays are row-major order but Fortran
!   arrays are column-major order.

program matrix_multiply_mpi

  use mpi

  implicit none

  integer, parameter :: NRA = 62
  integer, parameter :: NCA = 15
  integer, parameter :: NCB = 7
  integer, parameter :: MASTER = 0
  integer, parameter :: FROM_MASTER = 1
  integer, parameter :: FROM_WORKER = 2
  
  integer :: numtasks,taskid,numworkers,source,dest,mtype
  integer :: cols,avecol,extra, offset,i,j,k,ierr
  integer, dimension(MPI_STATUS_SIZE) :: status
  real(kind=8) :: a(NRA,NCA), b(NCA,NCB), c(NRA,NCB)
  
  call MPI_INIT( ierr )
  call MPI_COMM_RANK( MPI_COMM_WORLD, taskid, ierr )
  call MPI_COMM_SIZE( MPI_COMM_WORLD, numtasks, ierr )
  numworkers = numtasks-1
  print *, 'task ID= ',taskid
  
! *************************** master task *************************************
  if (taskid .eq. MASTER) then
     
     ! Initialize A and B 
     do i=1, NRA
        do j=1, NCA
           a(i,j) = (i-1)+(j-1)
        end do
     end do

     do i=1, NCA
        do j=1, NCB
           b(i,j) = (i-1)*(j-1)
        end do
     end do

     ! Send matrix data to the worker tasks 
     avecol = NCB/numworkers
     extra = mod(NCB, numworkers)
     offset = 1
     mtype = FROM_MASTER
     do dest=1, numworkers
        if (dest .le. extra) then
           cols = avecol + 1
        else
           cols = avecol
        end if

        write(*,*)'   sending',cols,' cols to task',dest
        call MPI_SEND( offset, 1, MPI_INTEGER, dest, mtype, &
             &                   MPI_COMM_WORLD, ierr )
        call MPI_SEND( cols, 1, MPI_INTEGER, dest, mtype, &
             &                   MPI_COMM_WORLD, ierr )
        call MPI_SEND( a, NRA*NCA, MPI_DOUBLE_PRECISION, dest, mtype, &
             &                   MPI_COMM_WORLD, ierr )
        call MPI_SEND( b(1,offset), cols*NCA, MPI_DOUBLE_PRECISION, &
             &                   dest, mtype, MPI_COMM_WORLD, ierr )
        offset = offset + cols
     end do

     ! Receive results from worker tasks
     mtype = FROM_WORKER
     do i=1, numworkers
        source = i
        call MPI_RECV( offset, 1, MPI_INTEGER, source, &
             &                   mtype, MPI_COMM_WORLD, status, ierr )
        call MPI_RECV( cols, 1, MPI_INTEGER, source, &
             &                   mtype, MPI_COMM_WORLD, status, ierr )
        call MPI_RECV( c(1,offset), cols*NRA, MPI_DOUBLE_PRECISION,  &
             &                   source, mtype, MPI_COMM_WORLD, status, ierr )
     end do

     ! Print results 
     do i=1, NRA
        do j = 1, NCB
           write(*,'(2x,f8.2,$)') c(i,j)
        end do
        print *, ' '
     end do
  end if

  ! ***** worker task *****
  if (taskid > MASTER) then
     ! Receive matrix data from master task
     mtype = FROM_MASTER
     call MPI_RECV( offset, 1, MPI_INTEGER, MASTER, &
          &                 mtype, MPI_COMM_WORLD, status, ierr )
     call MPI_RECV( cols, 1, MPI_INTEGER, MASTER, &
          &                 mtype, MPI_COMM_WORLD, status, ierr )
     call MPI_RECV( a, NRA*NCA, MPI_DOUBLE_PRECISION, MASTER, &
          &                 mtype, MPI_COMM_WORLD, status, ierr )
     call MPI_RECV( b, cols*NCA, MPI_DOUBLE_PRECISION, MASTER, &
          &                 mtype, MPI_COMM_WORLD, status, ierr )

     ! Do matrix multiply
     do k=1, cols
        do i=1, NRA
           c(i,k) = 0.0
           do j=1, NCA
              c(i,k) = c(i,k) + a(i,j) * b(j,k)
           end do
        end do
     end do

     ! Send results back to master task
     mtype = FROM_WORKER
     call MPI_SEND( offset, 1, MPI_INTEGER, MASTER, mtype, &
          &                 MPI_COMM_WORLD, ierr )
     call MPI_SEND( cols, 1, MPI_INTEGER, MASTER, mtype,  &
          &                 MPI_COMM_WORLD, ierr )
     call MPI_SEND( c, cols*NRA, MPI_DOUBLE_PRECISION, MASTER, &
          &                  mtype, MPI_COMM_WORLD, ierr )
  end if
  call MPI_FINALIZE(ierr)

end program matrix_multiply_mpi
