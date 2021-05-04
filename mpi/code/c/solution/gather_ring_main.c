#include <stdlib.h>
#include <stdio.h>

#include <mpi.h>

/***********************************/
/***********************************/
/***********************************/
void gather_ring(float *x, int blocksize, float *y)
{
  int i, p, my_rank, succ, pred;
  int send_offset, recv_offset;
  MPI_Status status;

  MPI_Comm_size (MPI_COMM_WORLD, &p);
  MPI_Comm_rank (MPI_COMM_WORLD, &my_rank);

  succ = (my_rank+1)   % p;
  pred = (my_rank-1+p) % p;

  for (i=0; i<p-1; i++) {
    send_offset = ((my_rank-i+p)   %p ) * blocksize;
    recv_offset = ((my_rank-i-1+p) %p ) * blocksize;
    MPI_Send (y+send_offset, blocksize, MPI_FLOAT, succ, 0, MPI_COMM_WORLD);
    MPI_Recv (y+recv_offset, blocksize, MPI_FLOAT, pred, 0, MPI_COMM_WORLD, &status);
  }

} /* end gather_ring */

/***********************************/
/***********************************/
/***********************************/
int main(int argc, char *argv[])
{

  int nbTask;
  int myRank;
  int blocksize=4;
  int i;

  float *x;
  float *y;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTask);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  x = (float *) malloc( blocksize       *sizeof(float) );
  y = (float *) malloc( blocksize*nbTask*sizeof(float) );

  /* init x */
  for (i=0; i<blocksize; i++)
    x[i] = 1.0f*i+myRank*blocksize;

  /* init y */
  for (i=0; i<blocksize*nbTask; i++)
    y[i] = 0.0f;
  for (i=0; i<blocksize; i++)
    y[i+myRank*blocksize] = x[i];  

  /* before gather */
  for (i=0; i<blocksize*nbTask; i++)
    printf("[task %d] before y[%d]=%f\n",myRank,i,y[i]);

  gather_ring(x,blocksize,y);

  for (i=0; i<blocksize*nbTask; i++)
    printf("[task %d] after  y[%d]=%f\n",myRank,i,y[i]);

  free(y);
  free(x);

  MPI_Finalize();

  return 0;

} /* end main */
