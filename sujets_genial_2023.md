# Examen du cours de HCP du M2 Genial

Effectuer une video de 10 à 15 minutes maximun sur l'un des sujets suivants.

Ne surtout pas envoyer la video par email, mais juste un lien où on peut la voir.

Lorsque vous écrivez du code, pensez à le mettre sur votre compte gitlab de l'UFR (https://gaufre.informatique.univ-paris-diderot.fr/) et à me donner accès à votre dépôt.

- m'envoyer avant fin juin 2023 un message me précisant où vous en êtes et me donner l'url de votre dépôt git
- date limite pour l'envoi de la video (surtout PAS par email) : vendredi 14 juillet 2023, 20h.


##########################################################################

1. Implanter le tri par bulle avec MPI, en suivant les indications du document
http://web.eecs.utk.edu/~mbeck/classes/Fall15-cs462/MPISort.pdf
On pourra :
- choisir une taille de vecteur multiple d'une puissance de 2, de façon à pouvoir exécuter le code facilement pour tous les nombres de processus MPI entre 0 et 96 sur la machine odette.
- réaliser une étude de scalabilité (efficacité de parallélisation) forte et faible sur odette

##########################################################################

2. Terminer l'implantation Master/Worker du calcul de l'ensemble de Mandelbrot.

- montrer qu'on obtient les bons résultats (comparer l'image de Mandelbrot obtenue avec celle de la version naïve)
- mesurer et comparer les performances avec celles de la version naïve,
- illustrer l'amélioration de l'équilibrage de charge en utilisant tau/jumpshot

##########################################################################

3. Faire l'exercice 4 du TP MPI.

Situation initial : des données sont réparties de manière non équitables entre des processus MPI.

La taille initiale des données possédées par le processus de rang `myRank` sera tirée au hasard de la manière suivante
```c++
  #include <cstdlib>
  //...
  MPI_Comm_size(MPI_COMM_WORLD, &nbTasks);
  MPI_Comm_rank(MPI_COMM_WORLD, &myRank);

  // on initialise la graine du générateur aléatoire
  std::srand(myRank+1);

  // on tire au hasard un nombre ici entre 40 et 60
  int size = 40 + std::rand()/((RAND_MAX + 1u)/20);
  std::cout << size << "\n";
```

Situation finale: faire en sorte que les données soient équi-réparties entre tous les prcessus MPI.

* Indication pour la question 1 : on pourra utiliser `MPI_Allreduce` pour déterminer la somme totale des tailles des tableaux possédés par les processus MPI et en déduire la taille que devra avoir le tableau de données après que l'equipartiton est réalisée.

* On pourra aussi déterminer l'offset du début des données de chaque processus MPI avant (utiliser la commande `MPI_Exscan` pour cela) et après équipartion.

* Déterminer ensuite les communications point à point nécessaire pour réaliser l'équipartition.


##########################################################################

4. Utiliser MPL (MPI c++ interface) :
- installer depuis https://github.com/rabauke/mpl
- exécuter quelques exemples et expliciter les différences avec l'API C de MPI
- revisiter l'exercice sur l'ensemble de Mandelbrot (ré-écrire les appels MPI avec l'interface MPL)

##########################################################################

5. Algorithme de tri parallélisé avec MPI et [Thrust](https://github.com/NVIDIA/thrust)
- utiliser le code suivant: https://github.com/kspaff/sample_sort
- compiler les versions
  * MPI + Thrust/OpenMP
  * MPI + Thrust/CUDA
- expliquer simplement comment fonctionne l'algorithme, illustrer l'algorithme avec un petit nombre de processus (2 ou 4 par exemple) en utilisant TAU/Jumpshot
- mesurer les performances, courbe de scalabilité (efficacité parallèle)

##########################################################################

6. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant le noyau de calcul avec CUDA. Faire une étude de performance comparative entre la version MPI et la version CUDA pour plusieurs tailles d'image entre 512x512 et 4096x4096.

##########################################################################

7. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant le noyau de calcul avec OpenACC. Faire une étude de performance comparative entre la version MPI et la version CUDA pour plusieurs tailles d'image entre 512x512 et 4096x4096.

##########################################################################

8. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant l'application à l'aide de la bibliothèque thrust.

Indications:
- prendre exemple sur le code vu en TP: `saxpy_thrust_v2.cu`
- on pourra utiliser la routine `thrust::transform`,
  documentation https://thrust.github.io/doc/group__transformations.html
  la version qui prend quatre arguments:
  ```c++
  thrust::transform(
      InputIterator  	first,
      InputIterator  	last,
      OutputIterator  	result,
      UnaryFunction  	op
	);
  ```
- les deux premiers iterators peuvent simplement être des `counting iterators`, le 3eme argument un iterateur vers le tableau d'ouput qui contiendra l'ensemble de Mandelbrot et le 4eme argument une classe de type functor pour le calcul de l'ensemble de Mandelbrot.

* Etudier les performances (mesure de temps de calcul) pour différentes tailles.
* thrust permet également d'exécuter des calculs parallèles sur un CPU multicore avec OpenMP, simplement en remplacant `thrust` par `thrust::omp` (cf l'exemple `reduce_openmp.cpp`).

##########################################################################

9. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant l'application à l'aide de l'interface python.

- suivre les instructions du document de TP pour installer les outils python avec support CUDA
- utiliser les slides du cours + le document de TP pour se familiaser avec NUMBA
- s'exercer sur l'exemple fournit implanter l'algorithme saxpy dans le répertoire ``cuda/code/python_cuda/numba/numba_saxpy.ipynb``
- transformer le code original du calcul de l'ensemble de Mandelbrot de c++ vers python avec accélération GPU/numba
- montrer que le code python fonctionner; mesurer le temps d'exécution pour plusieurs taille d'image; comparer avec une version python sans accélération GPU

##########################################################################

10. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant l'application à l'aide de cuNumeric/legate (module alternatif à numpy, permettant d'utiliser la puissance de calcul des GPUs).

Etape 1:
On pourra s'inspirer de la page suivante pour voir comment calculer un ensemble de Mandelbrot avec numpy:
`https://www.learnpythonwithrune.org/numpy-compute-mandelbrot-set-by-vectorization/`
- mesurer le temps d'exécution du code numpy sur CPU, à l'aide du module python `timeit`, pour différentes tailles de tableau, e.g. 800x100, 1600x2000, 3200x4000

Etape 2:
- installer cuNumeric/legate, en se créant un environement conda spécifique
```shell
conda create -n cunumeric2023
conda activate cunumeric2023
conda install -c nvidia -c conda-forge -c legate legate-core cunumeric matplotlib
```

- cloner le dépôt des sources avec exemples de [cunumeric](https://github.com/nv-legate/cunumeric/tree/branch-23.07), se familiariser avec cuNumeric, présenter brièvement les fonctionnalités de cuNumeric
- exemple de manipulation, commenter vos observations
```shell
git clone git@github.com:nv-legate/cunumeric.git
cd cunumeric/examples/
# make sure to have conda cunumeric2023 environment activated
# 1. read legate help to learn about command line flags
legate -h
# 2. run on CPU
legate --cpus 1 --cores-per-node 6 ./stencil.py --time
# 3. run on GPU
legate --gpus 1 ./stencil.py --time
```

- apporter toutes les modifications nécessaires pour faire en sorte que l'on puisse exécuter le script du calcul de l'ensemble de Mandelbrot (étape 1) avec `import cuNumeric` à la place de `import numpy`; re-mesurer les performances (temps de calcul et comparer avec l'étape 1).

##########################################################################

11. Revisiter l'exercice sur le calcul de l'ensemble de Mandelbrot (uniquement la version naïve) en ré-écrivant l'application à l'aide de la bibliothèque [C++/MatX](https://github.com/NVIDIA/MatX)

- commencer par se familiariser avec la bibliothèque (cloner le dépôt, compiler / exécuter des exemples, consulter le quick start guide)

- consulter la page `https://www.learnpythonwithrune.org/numpy-compute-mandelbrot-set-by-vectorization/` qui explique comment calculer l'ensemble de Mandelbrot avec python/numpy

- réaliser une adaptation de de script en le ré-écrivant en C++ avec la bibliothèque MatX. Faire une étude performance.


##########################################################################

12. Paralléliser le code suivant avec le modèle de programmation cuda.

https://github.com/pkestene/buddhabrot

Buddhabrot est une sorte de généralisation de l'ensemble de Mandelbrot.

On pourra :
- utiliser le header `/usr/local/cuda-11.8/include/cuComplex.h` pour le calcul en complex dans les noyaux Cuda.
- analyser et présenter brièvement le code séquentiel
- mesurer et comparer les performances des versions séquentielle et parallèle

##########################################################################

13. Etude du code Lulesh refactoré avec le parallélisme du c++17 stdpar (parallélisme de la librairie standard)

- préliminaire: lire la page de blog: https://developer.nvidia.com/blog/accelerating-standard-c-with-gpus-using-stdpar/
- regarder les planches suivantes https://gtc21.event.nvidia.com/media/Inside+NVC%2B%2B+and+NVFORTRAN+%5BS31358%5D/1_hw2mm7hn ; surtout les planches 12 / 13; voir aussi https://www.olcf.ornl.gov/wp-content/uploads/4-7-22-ORNL-Stdpar.pdf
- expliquer les fonctionalités apportées stdpar (c++17 et parallélisme)
- utiliser l'implantation de stdpar par Nvidia (nvc++); sur odette:
  ```shell
  # pour charger le compilateur nvidia avec support stdpar (pour GPU et CPU)
  module use /opt/nvidia/hpc_sdk_22_11/modulefiles
  module load nvhpc/22.11
  ```
- compiler / exécuter les performances de l'application LULESH sur CPU et GPU; retrouvez-vous le speed-up mentionné à la fin du blog ? Pour compiler la version CPU/multicore, il vous faudra éditer le Makefile et changer les flags de compilation.
- Comment varie le facteur d'accélération quand on change la taille du problème (option -s) ? Tracer la courbe qui donne l'accélération (rapport du temps d'exécution de la version CPU sur GPU) en fonction de la taille du problème, comment cela évolue-t'il en fonction de la taille ?
- Recompiler LULESH en utilisant le compilateur `dpcpp` qui supporte également stdpar
  ```shell
  # pour charger le compilateur Intel avec support stdpar via tbb
  module use /opt/intel/oneapi/modulefiles
  module load compiler
  ```
  utiliser le dépôt suivant : `https://github.com/pkestene/LULESH` avec la branche `2.0.2-dev-oneapi` qui a été modifiée pour utiliser le compilateur dpcpp. Comment se compare les performances de la version compilée avec dpcpp avec celles compilées avec `nvc++` multicore ?

##########################################################################

14. Parallélisme du c++17 : stdpar

- préliminaire: lire la page de blog: https://developer.nvidia.com/blog/accelerating-standard-c-with-gpus-using-stdpar/
- regarder les planches suivantes https://gtc21.event.nvidia.com/media/Inside+NVC%2B%2B+and+NVFORTRAN+%5BS31358%5D/1_hw2mm7hn ; surtout les planches 12 / 13; voir aussi https://www.olcf.ornl.gov/wp-content/uploads/4-7-22-ORNL-Stdpar.pdf
- expliquer les fonctionalités apportées stdpar (c++17 et parallélisme)
- utiliser l'implantation de stdpar par Nvidia (nvc++); sur odette:
  ```shell
  # pour charger le compilateur nvidia avec support stdpar (pour GPU et CPU)
  module use /opt/nvidia/hpc_sdk_22_11/modulefiles
  module load nvhpc/22.11
  ```

- refactorer la version naïve du calcul de l'ensemble Mandelbrot (le code C++ séquentiel se trouve dans le dépôt git du cours sur le serveur gauffre, `mpi/code/c/solution/mandelbrot/seq_mandelbrot.cpp`) pour en faire une version parallèle avec stdpar. On pourra utiliser au choix `std::for_each` ou `std::transform` pour paralléliser la boucle de calcul principale.

- compiler le code avec le compilateur nvidia `nvc++` (disponible grâce au module nvhpc); utiliser les flags de compilation pour fabriquer un exécutable CPU, puis GPU
- comparer les performances sur CPU, puis GPU en faisant varier la taille de l'ensemble de Mandelbrot.


##########################################################################

15. Mise en oeuvre d'entrées/sorties parallèles.

- regarder les planches d'introduction à MPI-IO: https://wgropp.cs.illinois.edu/courses/cs598-s16/lectures/lecture32.pdf
- expliquer en quoi lire/écrire des fichiers en parallèle est différent du cas séquentiel, quels problèmes de performance on peut rencontrer
- se familiariser avec la lecture/écriture de fichier en parallèle avec le code du dépôt : https://github.com/pkestene/mpi-io-examples/tree/update-error-handling ; regarder en particulier le
 fichier `mpi_file_set_view.c` qui permet d'écrire collectivementt un seul fichier par N processus MPI.
 - mettre en oeuvre une sortie fichier parallèle dans le code `mpi_mandelbrot.cpp` en gardant le format PPM (header ASCII + data binaire)

Les bonnes questions à se poser:
- l'écriture du header doit-elle être parallèle ?
- l'écriture des données doit-elle être parallèle ?
- MPI-IO possède toutes les API pour faire des écritures binaires (e.g. `MPI_File_write_all`), mais il n'y a pas d'équivalent à `fprintf` (utilisée pour l'écriture ascii du header dans la version séquentielle du code). Montrer qu'on peut quand même se débrouiller pour écrire le header avec MPI-IO.


Répartition:
1. Ugo
2. Lilian
3. Julien
4. Kevin
5. Anes
6. Thierry
7. Remi
8. Natacha
9. Antoine
10. Vincent Wei
11. Majid
12. Robin
13. Aissat
14. Louis
15. Alexandre
