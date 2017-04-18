      Program MAIN
      use manager_mod
      use parallel_mod
c***********************************************************
!              The main module                             *
!***********************************************************
      implicit none
      call beging
      mem_using=0.d0
      mem_max=0.d0
      mem_where='qft'
      call init
      if(maswrk) write(iun,*)' Number of processors is ',nproc
      call start_par_mb
      call tau_frequency_meshes
! --------------------------------------------------------------
      call solid
!     ***********************************************************
      call ending
      end
