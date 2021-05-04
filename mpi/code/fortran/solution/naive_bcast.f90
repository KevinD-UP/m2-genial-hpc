! Naive broadcast
call MPI_Comm_rank (comm, myRank, ierr)
if (my_rank == 0) then
   do rank=1,nranks-1
      call MPI_Send( buffer, count, MPI_INT, rank, ... )
   end do
else
   call MPI_Recv( buffer, count, MPI_INT, 0, ... )
end if
