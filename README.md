# LqsgwFlapw
Linearized self-consistent quasiparticle GW method
----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
CODES for LqsgwFlapw
(Linearized quasiparticle self-consistent GW method based on Full-potential linearized augmented plane wave method)

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
LICENSE:
This code is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation (version 3).

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

(The full version of License can be found in LICENSE file)
----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- 
PACKAGE CONTENT:
After unpacking file QP.tar.gz you should see "QP" directory with the following subdirectories:

doc   - contains PDF, PS, and TXT files (they are similar) describing  input/output files.
src   - contains source files.
sys   - contains examples of make.sys files for different systems and compilers.
tests - contains the script to run the tests and precalculated results for comparison.

Beside subdirectories one should also have the following files:

INSTALL  - Text file describing the installation steps.
LICENSE  - File with GNU GENERAL PUBLIC License.
Makefile - Makefile for source code.
README   - This file.
make.sys - Default include file for "Makefile" with information about your system. Please ajust it accordingly.

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
To INSTALL the code please  follow the instructions in INSTALL file.

----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
TO RUN TESTS:

1) change to one of subdirectories in "tests" folder: Fe, Na, Si, or LiF.

2) execute runme.sh script: "sh runme.sh"  or "./runme.sh"
   The script will ask you two questions if your want to run test job in serial or parallel mode and
   the number of processes you would like to use in the test run if you choose parallel mode for execution.
   
   During a test run you will see that a few first iterations go relatively fast 
   (they are LDA iterations, their number is defined by variable "iter_dft" in 'ini' file). 
   The following iterations, however, take more time. They correspond to QPGW iterations, 
   and their number is defined by variable "iter_qp" in the same file. 
   One can estimate approximately the total time needed for a test by looking into *.out file in 
   "results-4-comparison" directories. In the end of each iteration the total execution time is given in seconds.

   REMEMBER:
   a) All test runs for comparison were obtained for a system with 48 MPI processes.
   b) The number of processes in parallel jobs is not arbitrary: it is defined by the variables "nproc_tau" and
   "nproc_k" in 'ini' file. In order to learn more about it please read the description file found in doc folder.
   "runme.sh" script takes this automatically in to account.
   
3) After a test is finished a number of files will be generated in the same directory. 
   They can be compared with files in results-4-comparison directory.
   
----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
FINALLY: 
in order to perform a new calculation for a desired material one has to create new 'ini' file.
Simple way to do it is to copy an existing 'ini' file from one of test directories (Na, Si, LiF, Fe) 
and make necessary changes following description provided in doc folder.
----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

