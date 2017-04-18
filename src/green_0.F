      subroutine green_0(correlation)
      use atom_mod
      use manager_mod
      use parallel_mod
      use solid_mod
      implicit none
      logical, intent(in) :: correlation
      integer :: k,ispin,len,k0,i
      real*8 :: de,green0
c ------------- Forming G_FULL(0-) --> G_FULL_0 ----------------------
      if(.not.correlation) g_full_00=0.d0
      if(correlation) g_full_0=(0.d0,0.d0)
      if(me3_tau==0) then
        do ispin=1,nspin
          do k=1,ndim3_k
            k0=ndim3_k*me3_k+k
            if(.not.correlation) then
              g_full_00(:,k,ispin)=0.d0
                   do i=1,n_bnd(k0,ispin)
                de=e_bnd(i,k0,ispin)-chem_pot
                g_full_00(i,k,ispin)=-green0(de,tau_mesh(n_tau))
              enddo
            else
            call ferm_unpack_tau(g_full_0(1,1,k,ispin),
     &                       g_full(1,1,1,1,k,ispin),
     &                             n_bnd(k0,ispin),nbndf,nbndf,2)
              g_full_0(:,:,k,ispin)=-g_full_0(:,:,k,ispin)
            endif
          enddo   !! over k
        enddo  !! over ispin
      endif
      if(nproc_tau/=1) then
        if(.not.correlation) then
          len=nbndf*ndim3_k*nspin_0
          if(len/=0) call dgop(g_full_00,len,'  +',comm_pnk)
        else
          len=nbndf**2*ndim3_k*nspin_0
          if(len/=0) call dgop(g_full_0,2*len,'  +',comm_pnk)
        endif
      endif
      end
