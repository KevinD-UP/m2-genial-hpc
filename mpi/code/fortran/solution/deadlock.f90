! example to demonstrate the order of receive operations
call MPI_Comm_rank (comm, myRank, ierr)
if (myRank == 0) then
   call MPI_Send(sendbuf1, count, MPI_INT, 2, tag, comm, ierr)
   call MPI_Send(sendbuf2, count, MPI_INT, 1, tag, comm, ierr)
else if (myRank == 1) then
   call MPI_Recv(recvbuf1, count, MPI_INT, 0, tag, comm, status, ierr)
   call MPI_Send(recvbuf1, count, MPI_INT, 2, tag, comm, ierr)
else if (myRank == 2) then
   call MPI_Recv(recvbuf1, count, MPI_INT, MPI_ANY_SOURCE, tag, comm, status, ierr)
   call MPI_Recv(recvbuf2, count, MPI_INT, MPI_ANY_SOURCE, tag, comm, status, ierr)
end if
