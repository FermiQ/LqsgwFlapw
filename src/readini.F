      subroutine readini
      use atom_mod
      use etot_mod
      use manager_mod
      use parallel_mod
      use solid_mod
      use units_mod
      implicit none
#ifdef MPI
      include 'mpif.h'
#endif
      character*1 :: chh,txt*20
      integer :: iatom,i,it,isort,lb,lpb,l,ll,n,ntl(0:10)
      if(maswrk) then
        open(1,file='ini',status='old')
        read(1,'(a1)')chh
        read(1,*)txt,txt,iter_dft,txt,iter_hf,txt,iter_gw,txt,
     &                                      iter_qp
        read(1,*)txt,admix,txt,adspin,txt,adm_gw,txt,acc_it_gw
        read(1,*)txt,iexch,txt,scal_spin
        read(1,*)txt,nproc_tau,txt,nproc_k
        read(1,*)txt,irel,txt,clight,txt,rel_interst,txt,
     &        irel_core
        if(irel==0) irel_core=0
        irel_core=max(irel,irel_core)
        nrel=1
        if(irel.eq.2) nrel=2
        nrel_core=1
        if(irel_core.eq.2) nrel_core=2
        read(1,*)txt,temperature
        read(1,'(a1)')chh
        read(1,*)txt,allfile
        read(1,*)txt,txt,symgen
        read(1,*)txt,txt,par,txt,natom,txt,nsort,txt,istruc
      endif
      if(goparr) then
#ifdef MPI
        call brdcst(msgint,iter_dft,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,iter_hf,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,iter_qp,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,admix,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,adspin,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,clight,8,master,MPI_COMM_WORLD)
        call brdcst(msgint,iexch,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,irel,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,irel_core,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,nrel,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,nrel_core,4,master,MPI_COMM_WORLD)
        call brdcstc(allfile,72,master,MPI_COMM_WORLD)
        call brdcst(msgint,nproc_tau,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,nproc_k,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,rel_interst,4,master,MPI_COMM_WORLD)
        call brdcstc(symgen,60,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,par,8,master,MPI_COMM_WORLD)
        call brdcst(msgint,natom,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,nsort,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,istruc,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,scal_spin,8,master,MPI_COMM_WORLD)
#endif        
      endif
      allocate(is(natom))
      allocate(tau(3,natom))
      allocate(txtel(nsort))
      allocate(z(nsort))
      allocate(z_dop(nsort))
      allocate(zcor(nsort))
      allocate(magn_shift(nsort))
      allocate(smt(nsort))
      allocate(h(nsort))
      allocate(nrad(nsort))
      allocate(lmb(nsort))
      allocate(lmpb(nsort))
      if(maswrk) then
        read(1,*)txt,(is(iatom),iatom=1,natom)
        read(1,*)txt,b_a,txt,c_a
        read(1,*)txt,(rbas(i,1),i=1,3)
        read(1,*)txt,(rbas(i,2),i=1,3)
        read(1,*)txt,(rbas(i,3),i=1,3)
        do iatom=1,natom
          if(iatom==1) read(1,*)txt,(tau(i,iatom),i=1,3)
          if(iatom/=1) read(1,*)(tau(i,iatom),i=1,3)
        enddo
        read(1,*)txt,txt,txt,txt,mdiv
        read(1,*)txt,nrdiv
        read(1,*)txt,txt,cut_lapw_ratio,txt,cut_pb_ratio
        read(1,*)txt,eps_pb
        read(1,*)txt,txt,nbndf
        read(1,*)txt,txt,emindos,txt,emaxdos,txt,ndos
        read(1,*)txt,n_cont_frac,txt,e_small
        read(1,*)txt,txt,(ndiv(i),i=1,3),txt,metal,txt,
     &                                 n_k_div,txt,k_line
        read(1,*)txt,txt,v_v0
        read(1,*)txt,txt,b_extval,txt,iter_h_ext
c -------- Transform to internal magnetic field --------------
        read(1,*)txt,(b_ext(i),i=1,3)
        b_ext=b_ext/sqrt(dot_product(b_ext,b_ext))
        read(1,*)txt,txt,txt,n_tau,txt,n_tau_int
        read(1,*)txt,txt,txt,n_omega_exa,txt,n_omega_asy,txt,
     &                                  omega_max
        read(1,*)txt,interp_omega_d
        read(1,*)txt,txt,txt,n_nu_exa,txt,n_nu_asy,txt,nu_max
        read(1,*)txt,interp_nu_d
        read(1,'(a1)')chh
        maxb=0
        maxpb=0
        maxntle=0
        it=0
        do isort=1,nsort
          read(1,'(a1)')chh
          read(1,'(a1)')chh
          read(1,*)txt,lb,txt,lpb
          read(1,'(a1)')chh
          maxb=max(maxb,lb)
          maxpb=max(maxpb,lpb)
          read(1,*)txt,(ntl(l),l=0,lb)
          read(1,'(a1)')chh
          it=it+6
          do l=0,lb
            do n=1,ntl(l)
              it=it+1
              read(1,'(a1)')chh
            enddo
            maxntle=max(maxntle,abs(ntl(l)))
          enddo
        enddo
      endif
      if(goparr) then
#ifdef MPI
        call brdcst(msgdbl,cut_lapw_ratio,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,cut_pb_ratio,8,master,MPI_COMM_WORLD)
        call brdcst(msgint,maxb,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,maxpb,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,maxntle,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,metal,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_k_div,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_cont_frac,4,master,MPI_COMM_WORLD)
        call brdcstc(k_line,3,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_gamma,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,iter_h_ext,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,omega_max,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,nu_max,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,e_small,8,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_tau,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_tau_int,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,interp_omega_d,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,interp_nu_d,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,ndiv,4*3,master,MPI_COMM_WORLD)
        call brdcst(msgint,mdiv,4*3,master,MPI_COMM_WORLD)
        call brdcst(msgint,nrdiv,4*3,master,MPI_COMM_WORLD)
#endif        
      endif
      allocate(konfig(0:maxb,nsort))
      allocate(atoc(maxntle,0:maxb,nsort))
      allocate(idmd(maxntle,0:maxb,nsort))
      allocate(ntle(0:maxb,nsort))
      allocate(augm(maxntle,0:maxb,nsort))
      allocate(correlated(maxntle,0:maxb,nsort))
      allocate(ptnl(maxntle,0:maxb,nsort,2))
      allocate(lim_pb_mt(0:maxpb,nsort))
      h=0.d0
      nrad=0
      z=0.d0
      z_dop=0.d0
      atoc=0.d0
      if(maswrk) then
        do i=1,it
          backspace 1
        enddo
        do isort=1,nsort
          read(1,*)txt,txtel(isort),txt,z(isort),txt,
     &                                    magn_shift(isort)
          read(1,*)txt,smt(isort),txt,
     &    h(isort),txt,nrad(isort),txt,z_dop(isort)
          read(1,*)txt,lmb(isort),txt,lmpb(isort)
          read(1,*)txt,(lim_pb_mt(i,isort),i=0,lmpb(isort))
          read(1,*)txt,(ntle(l,isort),l=0,lmb(isort))
          read(1,'(a1)')chh
c ------- Reading the type of the functions for L <= L_b ------
          do l=0,lmb(isort)
            konfig(l,isort)=10
            do n=1,ntle(l,isort)
              read(1,*)ll,
     &        augm(n,l,isort),atoc(n,l,isort),ptnl(n,l,isort,1),
     &          correlated(n,l,isort),idmd(n,l,isort)
              ptnl(n,l,isort,2)=ptnl(n,l,isort,1)
              konfig(l,isort)=min(konfig(l,isort),
     &                            int(ptnl(n,l,isort,1)))
            enddo
          enddo
        enddo
        close(1)
      endif
      if(goparr) then
#ifdef MPI
        call brdcst(msgint,n_omega_exa,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_omega_asy,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_nu_exa,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,n_nu_asy,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,omega_max,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,nu_max,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,adm_gw,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,b_a,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,c_a,8,master,MPI_COMM_WORLD)
        call brdcst(msgint,is,4*natom,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,rbas,8*9,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,tau,8*3*natom,master,MPI_COMM_WORLD)
        call brdcst(msgint,nbndf,4,master,MPI_COMM_WORLD)
        call brdcst(msgint,ndos,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,emindos,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,emaxdos,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,v_v0,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,b_extval,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,b_ext,8*3,master,MPI_COMM_WORLD)
        call brdcst(msgint,iter_gw,4,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,acc_it_gw,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,temperature,8,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,eps_pb,8,master,MPI_COMM_WORLD)
        call brdcstc(txtel,4*nsort,master,MPI_COMM_WORLD)
        call dgop(z,nsort,'  +',MPI_COMM_WORLD)
        call dgop(z_dop,nsort,'  +',MPI_COMM_WORLD)
        call brdcst(msgdbl,magn_shift,8*nsort,master,MPI_COMM_WORLD)
        call brdcst(msgdbl,smt,8*nsort,master,MPI_COMM_WORLD)
        call dgop(h,nsort,'  +',MPI_COMM_WORLD)
        call igop(nrad,nsort,'  +',MPI_COMM_WORLD)
        call dgop(atoc,nsort*(maxb+1)*maxntle,'  +',MPI_COMM_WORLD)
        call brdcstc(correlated,nsort*(maxb+1)*maxntle,master,
     &             MPI_COMM_WORLD)
        call brdcst(msgint,idmd,4*nsort*(maxb+1)*maxntle,master,
     &            MPI_COMM_WORLD)
        call brdcst(msgdbl,ptnl,16*nsort*(maxb+1)*maxntle,master,
     &            MPI_COMM_WORLD)
        call brdcstc(augm,3*nsort*(maxb+1)*maxntle,master,
     &             MPI_COMM_WORLD)
        call brdcst(msgint,lmb,4*nsort,master,MPI_COMM_WORLD)
        call brdcst(msgint,lmpb,4*nsort,master,MPI_COMM_WORLD)
        call brdcst(msgint,lim_pb_mt,4*nsort*(maxpb+1),master,
     &            MPI_COMM_WORLD)
        call brdcst(msgint,konfig,4*nsort*(maxb+1),master,
     &          MPI_COMM_WORLD)
        call brdcst(msgint,ntle,4*nsort*(maxb+1),master,MPI_COMM_WORLD)
#endif        
      endif
      z=z+z_dop
c ---------------------------------------------------------------------
      call set_control
      end
