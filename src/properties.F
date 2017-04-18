      subroutine properties(iexit1)
      use etot_mod
      use manager_mod
      use parallel_mod
      use solid_mod
      implicit none
      integer, intent(inout) :: iexit1
c ------------ Numbers of Occupation ---------------------------------
        call occ_number
c ------ Output GW Energy -------------------------------------------
        call etot_gw_2
        if(iexit1==1.or.ubi/='dft') call output_dos
        if(iexit1==1) then
c -------------------- Bands plotting -----------------------------
          if(ubi=='dft') call plot_bands_lapw   !! LAPW bands
        endif
      end
