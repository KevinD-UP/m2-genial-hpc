void gather_ring(float *x, int blocksize, float *y)
{
  int i, p, my_rank, succ, pred;
  int send_offset, recv_offset;
  MPI_Status status;

  MPI_Comm_size (MPI_COMM_WORLD, &p);
  MPI_Comm_rank (MPI_COMM_WORLD, &my_rank);
  for (i=0; i<blocksize; i++)
    y[i+my_rank*blocksize] = x[i];
  succ = (my_rank+1)   % p;
  pred = (my_rank-1+p) % p;
  for (i=0; i<p-1; i++) {
    send_offset = ((my_rank-i+p)   %p ) * blocksize;
    recv_offset = ((my_rank-i-1+p) %p ) * blocksize;
    MPI_Send (y+send_offset, blocksize, MPI_FLOAT, succ, 0, MPI_COMM_WORLD);
    MPI_Recv (y+recv_offset, blocksize, MPI_FLOAT, pred, 0, MPI_COMM_WORLD, &status);
  }
}
