      subroutine start_par_mb
      use manager_mod
      use parallel_mod
      use solid_mod
      implicit none
#ifdef MPI
      include 'mpif.h'
      integer :: ierr,color
#endif
c ---- Memory distribution for Double Parallelization  -----------------------
      if(nproc/=nproc_tau*nproc_k) then
        if(me==0) write(iun,*)
     &  ' NPROC /= NPROC_TAU*NPROC_K'
        call ending
      endif
      if(mod(n_tau/2+1,nproc_tau)/=0) then
        if(me==0) write(iun,*)' N_TAU does not match NPROC_TAU'
        call ending
      endif
      if(mod(n_omega+1,nproc_tau)/=0) then
        if(me==0) write(iun,*)' N_OMEGA does not match NPROC_TAU'
        call ending
      endif
      if(mod(n_nu+1,nproc_tau)/=0) then
        if(me==0) write(iun,*)' N_NU does not match NPROC_TAU'
        call ending
      endif
      if(mod(npnt,nproc_k)/=0) then
        if(me==0) write(iun,*)' NPNT does not match NPROC_K'
        call ending
      endif
      ndim3_tau=(n_tau/2+1)/nproc_tau
      ndim3_omega=(n_omega+1)/nproc_tau
      ndim3_nu=(n_nu+1)/nproc_tau
      allocate(ndim_tau(nproc))
      allocate(ndim_omega(nproc))
      allocate(ndim_nu(nproc))
      allocate(ndim_istar(nproc))
      allocate(n_mpi_tau(nproc))
      allocate(n_mpi_omega(nproc))
      allocate(n_mpi_nu(nproc))
      allocate(n_mpi_istar(nproc))
c ---- Memory distribution for Omega-mesh ---------------------------------
      call size_shift_par(n_omega+1,nproc,ndim_omega,n_mpi_omega)
c ---- Memory distribution for Tau-mesh ---------------------------------
      call size_shift_par(n_tau/2+1,nproc,ndim_tau,n_mpi_tau)
c ---- Memory distribution for Nu-mesh ---------------------------------
      call size_shift_par(n_nu+1,nproc,ndim_nu,n_mpi_nu)
c ------------ Communicators ----------------------
      me3_tau=mod(me,nproc_tau)
      me3_k=mod(me/nproc_tau,nproc_k)
      me4_kk=mod(me/(nproc_tau*nproc_k),1)
      me4_pbr=mod(me/(nproc_tau*nproc_k),1)
      me_tau_kk_pbr=me3_tau
      me_tau_k=nproc_tau*me3_k+me3_tau
      me_kk_pbr=me4_kk
#ifdef MPI
! -- Processes with the same me3_k
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,me3_k,me,comm_tau_kk_pbr,ierr)
! -- Processes with the same triplet: me4_pbr : me4_kk : me3_k
      color=1000000*(me4_pbr+1)+1000*(me4_kk+1)+me3_k
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,color,me,comm_pnk,ierr)
! -- Processes with the same triplet: me4_pbr : me4_kk : me3_tau
      color=1000000*(me4_pbr+1)+1000*(me4_kk+1)+me3_tau
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,color,me,comm_pnt,ierr)
! -- Processes with the same triplet: me4_pbr : me3_k : me3_tau
      color=1000000*(me4_pbr+1)+1000*(me3_k+1)+me3_tau
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,color,me,comm_pkt,ierr)
! -- Processes with the same triplet: me3_k : me4_kk : me3_tau
      color=1000000*(me3_k+1)+1000*(me4_kk+1)+me3_tau
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,color,me,comm_knt,ierr)
! -- Processes with the same doublet:  me3_tau + me3_k = me_tau_k
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,me_tau_k,me,comm_tau_k,ierr)
#endif      
      end
