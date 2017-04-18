      subroutine solid_scf
      use atom_mod
      use etot_mod
      use manager_mod
      use parallel_mod
      use solid_mod
      implicit none
      logical :: correlation
      integer :: iexit1
      maxqmt=maxel*(maxel+1)/2
      call rostart(r_atom,ro_atom)
      call writero
      call timel('***** rostart finished *************')
*  *****  the loop of self-consistency *****
      call timel('*******   SCF started **************')
      iter=1
      iexit1=0
      do while (iter<=iter_max_scf)
        call ubi_sumus(iter)
        if(maswrk) write(iun,1010)iter
        if(ubi=='dft') ubi_0=ubi
        if(nspin/=nspin_1) nspmag=max(magn,nspin)
c ---------------------------------------------------------------------     
        we_need_pol=.false.
        if(ubi==' qp') we_need_pol=.true.
        if(ubi==' gw') we_need_pol=.true.
      call set_g00
c ---------------------------------------------------------------------
        call smultro
        call vcoul
        call add_vxc     
        call exchener(1,vxch) !! for old Density
        call core_all
        call output_ro_v
        if(itest.gt.0.and..not.iheg) then
          text=' Matching : Coulon Potential!'
          call matching(0,v_mt_h,v_intr_h)
        endif
        if(ubi=='dft'.or.(ubi==' hf'.and.rad_solver==' HF')) then
          call dft_loop
        else
          call gw_loop
        endif
c -------------------------------------------------------------------- 
        call exchener(2,exch_dft)  !! for new Density
        correlation=.false.
        if(ubi==' qp'.or.ubi==' gw') 
     &    correlation=.true.
        call ROfull(correlation,1)    
        call coulener(ro_vh_old)
        call smultro
        call vcoul
        call coulener(ro_vh_new)
*  admix density for the next iteration
        if(iter>=1.and.ubi=='dft') call mixro1
        if(rad_solver==' HF'.and.ubi==' hf') call mixro1
        call writero
        iexit1=0
        if(ubi=='dft'.and.iter==iter_dft) iexit1=1
        if(ubi==' hf'.and.iter==iter_dft+iter_hf) iexit1=1
        if(ubi==' gw'.and.iter==iter_dft+iter_hf+iter_gw) iexit1=1
        if(ubi==' qp'.and.iter==iter_dft+iter_hf+iter_gw
     &                                          +iter_qp) iexit1=1
        if(iter==iter_dft.and.iter_max_scf/=iter_dft) then
          we_need_v=.false.
          if(iter_max_scf/=iter_dft) then
            we_need_v=.true.
          endif
          if(we_need_v) then
            call prod_bas
            call trans_pb_pw
          endif
        endif
        if(iter==iter_dft) then
          allocate(e_lda(nbndf,npnt,nspin))
          e_lda=e_bnd
          chem_pot_lda=chem_pot
        endif
        call properties(iexit1)
        ubi_0=ubi
        iter=iter+1
      enddo   !!! over iter
1010  format(/'                iteration ',i3/)
1020  format(1x,i4,' elements discovered for lattice')
      end
