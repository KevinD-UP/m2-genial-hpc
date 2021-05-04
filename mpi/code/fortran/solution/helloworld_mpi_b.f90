program helloworld_mpi_b

  use mpi

  implicit none

  integer                                       :: nbTask, myRank, ierr
  character(len=MPI_MAX_PROCESSOR_NAME)         :: proc_name
  integer                                       :: string_length
  character(len=MPI_MAX_LIBRARY_VERSION_STRING) :: mpi_library_name
  integer                                       :: mpi_version_num
  integer                                       :: mpi_subversion_num

  call MPI_Init(ierr)

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nbTask, ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, myRank, ierr)
  call MPI_GET_PROCESSOR_NAME(proc_name, string_length, ierr)

  if (myRank == 0) then
     call MPI_GET_VERSION(mpi_version_num, mpi_subversion_num,ierr)
     write (*,'("MPI standard version is ",i1,".",i1)') , mpi_version_num,mpi_subversion_num
     write (*,"()") 

     ! this is a MPI-3 routine
     ! you must have openmpi 1.8.x at least
     call MPI_GET_LIBRARY_VERSION(mpi_library_name, string_length, ierr)
     write (*,*) 'MPI implementation is:',mpi_library_name

  end if

  write (*,*) 'I am task', myRank, 'out of',nbTask, ' on processor ',proc_name

  call MPI_Finalize(ierr)

end program helloworld_mpi_b
