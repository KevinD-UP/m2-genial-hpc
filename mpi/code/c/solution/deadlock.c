/* example to demonstrate the order of receive operations */
MPI_Comm_rank (comm, &myRank);
if (myRank == 0) {
  MPI_Send(sendbuf1, count, MPI_INT, 2, tag, comm);
  MPI_Send(sendbuf2, count, MPI_INT, 1, tag, comm);
 } else if (myRank == 1) {
  MPI_Recv(recvbuf1, count, MPI_INT, 0, tag, comm, &status);
  MPI_Send(recvbuf1, count, MPI_INT, 2, tag, comm);
 } else if (myRank == 2) {
  MPI_Recv(recvbuf1, count, MPI_INT, MPI_ANY_SOURCE, tag, comm, &status);
  MPI_Recv(recvbuf2, count, MPI_INT, MPI_ANY_SOURCE, tag, comm, &status);
 }
