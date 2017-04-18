#PLEASE EDIT make.sys file ONLY
include ./make.sys
#
all: 
	@(cd src; ${MAKE} all )

mods: 
	@(cd src; ${MAKE}  mods)

clean: 
	@(cd src; ${MAKE}  clean)

