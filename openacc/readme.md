Utilisation du matériel suivant

- [Jeff Larkin (Nvidia) Introduction to OpenACC](https://www.openacc.org/sites/default/files/inline-files/OpenACC_Course_Oct2018/OpenACC%20Course%202018%20Week%201.pdf)
- [Jeff Larkin (Nvidia) OpenACC data management](https://www.openacc.org/sites/default/files/inline-files/OpenACC_Course_Oct2018/OpenACC%20Course%202018%20Week%202.pdf)
- [Jeff Larkin (Nvidia) OpenACC optimizations](https://www.openacc.org/sites/default/files/inline-files/OpenACC_Course_Oct2018/OpenACC%20Course%202018%20Week%203.pdf)
- [OpenAcc training material as notebooks](https://github.com/OpenACC/openacc-training-materials)
- [gpubootcamp](https://github.com/openhackathons-org/gpubootcamp)

# OpenAcc training

on utilise les notebooks python  [OpenAcc training material as notebooks](https://github.com/OpenACC/openacc-training-materials) fournit par Nvidia.

Suivre les étapes suivantes:

0. Sur odette, cloner le dépôt : https://github.com/OpenACC/openacc-training-materials:
```shell
git clone https://github.com/OpenACC/openacc-training-materials
```

1. Sur odette, configurer l'environement pour pouvoir utiliser le compilateur Nvidia pour OpenAcc
```shell
module use /opt/nvidia/hpc_sdk_22_5/modulefiles/
module load nvhpc/22.5
```
2. Se référer au document du TP pour lancer un serveur jupyter sur la machine distante odette et sur la machine local ouvrir un tunnel ssh pour rediriger un port local vers odette et ainsi visualiser le notebook jupyter sur vortre machine local tout en exécutant du code sur la machine distante.

3. Dans jupyter ouvrir le notebook `openacc-training-materials/labs/START HERE.ipynb`
