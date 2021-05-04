/* Naive broadcast */
if (my_rank == 0) {
  for (rank=1; rank<nranks; rank++)
    MPI_Send( (void*)a, /* target= */ rank, ... );
} else {
  MPI_Recv( (void*)a, 0, ... );
}
