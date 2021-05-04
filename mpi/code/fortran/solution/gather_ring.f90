subroutine gather_ring(x, blocksize, y)

  implicit none

  ! dummy variables
  real, intent(in),dimension(:)    :: x
  integer, intent(in) :: blocksize
  real, intent(out),dimension(:)   :: y

  ! local variables
  integer :: i, p, my_rank, succ, pred, ierr
  integer :: send_offset, recv_offset
  MPI_Status :: status

  call MPI_Comm_size (MPI_COMM_WORLD, p,       ierr)
  call MPI_Comm_rank (MPI_COMM_WORLD, my_rank, ierr)
  do i=1,blocksize
     y(i+my_rank*blocksize) = x(i)
  end do
  succ = mod (my_rank+1  , p )
  pred = mod (my_rank-1+p, p )

  do i=0,p-2
     send_offset = mod (my_rank-i+p  , p ) * blocksize + 1
     recv_offset = mod (my_rank-i-1+p, p ) * blocksize + 1
     call MPI_Send (y(send_offset:send_offset+blocksize-1), blocksize, MPI_FLOAT, succ, 0, MPI_COMM_WORLD, ierr)
     call MPI_Recv (y(recv_offset:send_offset+blocksize-1), blocksize, MPI_FLOAT, pred, 0, MPI_COMM_WORLD, status, ierr)
  end do

end subroutine gather_ring
