!==============================================================!
!                                                              !
! This file has been written as a sample solution to an        !
! exercise in a course given at the CSCS Summer School.        !
! It is made freely available with the understanding that      !
! every copy of this file must include this header and that    !
! CSCS take no responsibility for the use of the enclosed      !
! teaching material.                                           !
!                                                              !
! Purpose: Measuring bandwidth using a ping-pong               !
!                                                              !
! Contents: F-Source                                           !
!==============================================================!

! 1. start mpi using 2 nodes with one process per node:
! 2. try on only one node, explain the bandwidth values
!
! use gnuplot to plot the results (both curves):
! gnuplot bandwidth.gp
!
! comments / explanations ?

program bandwidth

  use mpi
  implicit none

  integer, parameter :: PROCESS_A=0

  integer, parameter :: PROCESS_B=1

  integer, parameter :: PING=17 ! message tag

  integer, parameter :: PONG=23 ! message tag

  integer, parameter :: NMESSAGES=100

  integer, parameter :: INI_SIZE=1

  integer, parameter :: FACT_SIZE=2

  integer, parameter :: REFINE_SIZE_MIN=1*1024

  integer, parameter :: REFINE_SIZE_MAX=16*1024

  integer, parameter :: SUM_SIZE=1*1024

  integer, parameter :: MAX_SIZE=536870912

  DOUBLE PRECISION :: tstart, tstop, transfer_time
  integer, dimension(MPI_STATUS_SIZE) :: status

  CHARACTER, ALLOCATABLE :: buffer(:)

  integer :: length_of_message
  integer :: ierror, my_rank, size
  integer :: k

  allocate(buffer(MAX_SIZE))

  open(1,file='mpi_bandwidth.dat',status='replace')

  CALL MPI_INIT(ierror)

  CALL MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)

  length_of_message = INI_SIZE
  do while (length_of_message <= MAX_SIZE)

     ! Write a loop of NMESSAGES iterations which do a ping pong.
     ! Make the size of the message variable and display the bandwidth for each of them.
     ! What do you observe? (plot it)

     tstart = MPI_Wtime()
     do k = 1, NMESSAGES
        if (my_rank.EQ.PROCESS_A) then
           CALL MPI_SEND(buffer, length_of_message, MPI_BYTE, PROCESS_B, PING, MPI_COMM_WORLD, ierror)
           CALL MPI_RECV(buffer, length_of_message, MPI_BYTE, PROCESS_B, PONG, MPI_COMM_WORLD, status, ierror)
        else if (my_rank.EQ.PROCESS_B) then
           CALL MPI_RECV(buffer, length_of_message, MPI_BYTE, PROCESS_A, PING, MPI_COMM_WORLD, status, ierror)
           CALL MPI_SEND(buffer, length_of_message, MPI_BYTE, PROCESS_A, PONG, MPI_COMM_WORLD, ierror)
        end if
     end do

     tstop = MPI_Wtime()

     if (my_rank == PROCESS_A) then
        transfer_time = (tstop - tstart) / (2 * NMESSAGES)

        ! write on screen
        WRITE(*,*) length_of_message,' ',transfer_time,' ',(length_of_message/transfer_time)/(1024*1024)
        
        ! write in file
        WRITE(1,*) length_of_message,' ',transfer_time,' ',(length_of_message/transfer_time)/(1024*1024)
     end if

     if (length_of_message >= REFINE_SIZE_MIN .AND. length_of_message < REFINE_SIZE_MAX) then
        length_of_message = length_of_message + SUM_SIZE
     else
        length_of_message = length_of_message * FACT_SIZE
     end if

  end do

  close(1)
  deallocate(buffer)

  CALL MPI_FINALIZE(ierror)

end program bandwidth
