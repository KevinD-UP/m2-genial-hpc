/*
 * calcul d'une integrale par la methode des trapezes.
 *
 * A faire pour la prochaine fois :
 *
 * 1. remplacer les MPI_Send/MPI_Recv par un appel a MPI_Reduce pour collecter
 *    les integrales partielles
 * 2. Modifier l'interface du programme: le parametre n est passe sur la ligne
 *    de commande, recupere par la tache 0 et ensuite "broadcaste" aux autres.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <mpi.h>

double f(double x) {

  return 4.0/(1+x*x);

}

double compute_integral(double start, double dx, int nSegments)
{

  int i;
  double local_int = 0.0;

  for (i=0; i<nSegments; i++) {
    
    double x1 = start + dx*i;
    local_int += ( f(x1) + f(x1 + dx) ) / 2 * dx;
    
  }

  return local_int;
}


int main (int argc, char* argv[])
{
  int iProc;

  // les bornes de l'integrale
  double a,b;

  // nombre de segments total
  int n = 1024;
 
  // nombre de segment par tache MPI
  int nSegments;

  // longueur d'un segment
  double dx;

  // bornes d'integrations locales
  double x_start,x_end;

  // calcul local  d'integrale
  double local_integral;
  double global_integral = 0.0;

  // MPI variables
  int myRank;
  int nbTasks;
  MPI_Status status;

  a=0.0;
  b=1.0;

  MPI_Init(&argc, &argv);

  MPI_Comm_size(MPI_COMM_WORLD, &nbTasks);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  // calcul les bornes d'integration locale
  dx=(b-a)/n;

  nSegments = n/nbTasks+1;
  if (myRank == nbTasks-1)
    nSegments = n - (n/nbTasks+1)*(nbTasks-1);
  x_start = a + myRank*(n/nbTasks+1)*dx;
  x_end   = x_start + nSegments*dx;

  // compute local integral
  local_integral = compute_integral(x_start,dx,nSegments);

  for (iProc=0; iProc<nbTasks; iProc++) {
    if (myRank == iProc)
      printf("[myRank=%d] %f %f %d %f\n",myRank,x_start,x_end,nSegments,local_integral);
    MPI_Barrier(MPI_COMM_WORLD);
  }

  // rassemble les morceaux
  if (myRank == 0) {
    
    global_integral = local_integral;

    for (iProc=1; iProc<nbTasks; iProc++) {
      
      MPI_Recv(&local_integral, 1, MPI_DOUBLE, iProc, iProc, MPI_COMM_WORLD, &status);
      
      global_integral += local_integral;
      
    }

    printf("Resultat final : %g\n",global_integral);
    printf("Erreur absolue : %g\n",global_integral-4*atan(1.0));


  } else {

    MPI_Send(&local_integral, 1, MPI_DOUBLE, 0, myRank, MPI_COMM_WORLD);

  }



  MPI_Finalize();

  return EXIT_SUCCESS;
  
}
