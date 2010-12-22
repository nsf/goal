#------------------------------------------------------------------------------
# TEMPLATE_CGO_PACKAGE (used internally in TEMPLATE_GO_PACKAGE)
#------------------------------------------------------------------------------
define TEMPLATE_CGO_PACKAGE

$(eval gofiles+=$(patsubst %.go,%.cgo1.go,$(cgofiles)) $(curdir)_cgo_gotypes.go)
$(eval cgo_ofiles+=$(patsubst %.go,%.cgo2.o,$(cgofiles)) $(curdir)_cgo_export.o)
$(eval ofiles+=$(curdir)_cgo_defun.$O $(curdir)_cgo_import.$O $(cgo_ofiles))


$(curdir)_cgo_defun.c: $(cgofiles)
	$(call CDPREFIX,$(curdir))$(if $(targdir),CGOPKGPATH=$(targdir),) cgo --$(call PRESPACE,$(cgo_cflags)) $(cgofiles_np)

$(curdir)_cgo_gotypes.go $(curdir)_cgo_export.c $(curdir)_cgo_export.h $(curdir)_cgo_main.c: $(curdir)_cgo_defun.c
	@true

$(curdir)%.cgo1.go $(curdir)%.cgo2.c: $(curdir)_cgo_defun.c
	@true

# Compile rule for gcc source files
$(curdir)%.o: $(curdir)%.c
	$(HOST_CC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(CGO_CFLAGS_$(GOARCH)))\
		-g -fPIC -O2 -o $$@ -c$(call PRESPACE,$(cgo_cflags)) $(curdir)$$*.c

$(curdir)_cgo_main.o: $(curdir)_cgo_main.c
	$(HOST_CC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(CGO_CFLAGS_$(GOARCH)))\
		-g -fPIC -O2 -o $$@ -c$(call PRESPACE,$(cgo_cflags)) $(curdir)_cgo_main.c

$(curdir)_cgo1_.o: $(curdir)_cgo_main.o $(cgo_ofiles)
	$(HOST_CC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(CGO_CFLAGS_$(GOARCH)))\
		-g -fPIC -O2 -o $$@ $$^ $(cgo_ldflags)

$(curdir)_cgo_import.c: $(curdir)_cgo1_.o
	cgo -dynimport $(curdir)_cgo1_.o >$$@_ && mv -f $$@_ $$@

$(curdir)_cgo_defun.$O: $(curdir)_cgo_defun.c
	$(CC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(cflags)) -I"$(GOROOT)/src/pkg/runtime" -o $$@ $(curdir)_cgo_defun.c


$(eval cleanfiles+=$(curdir)*.cgo1.go $(curdir)*.cgo2.c $(curdir)_cgo_defun.c $(curdir)_cgo_gotypes.go)
$(eval cleanfiles+=$(curdir)_cgo_.c $(curdir)_cgo_import.c $(curdir)_cgo_main.c $(curdir)_cgo_export.*)
$(eval cleanfiles+=$(curdir)*.c_)

endef

#------------------------------------------------------------------------------
# TEMPLATE_GO_PACKAGE
#-IN---------------------------------------------------------------------------
# curdir       - current directory in a form of a prefix (can be empty)
# pkgdir       - installation destination in a form of a prefix (can be empty)
# targ         - target name
# gcflags      - package local GC compiler flags
# cflags       - package local C compiler flags
# cgo_cflags   - cgo compiler flags
# cgo_ldflags  - cgo linker flags
# deps         - package dependencies
#-------
# FILES: (all files should be relative to $(curdir))
#-------
# installfiles - additional list of installation files
# cleanfiles   - additional list of files for removing during clean
# gofiles      - list of the go source files
# ofiles       - additional object files
# hfiles       - list of header files (adding them to %.$O as dependencies)
# cgofiles     - list of cgo files
# cgo_ofiles   - list of additional cgo object files
#-OUT--------------------------------------------------------------------------
# creates a bunch of targets:
#   $(pkgdir)$(targ).a
#   $(curdir)$(targ).a
#   $(curdir)$(targ)/all
#   $(curdir)$(targ)/install
#   $(curdir)$(targ)/clean
#------------------------------------------------------------------------------
define TEMPLATE_GO_PACKAGE

$(eval gofiles      := $(addprefix $(curdir),$(gofiles)))
$(eval ofiles       := $(addprefix $(curdir),$(ofiles)))
$(eval cleanfiles   := $(addprefix $(curdir),$(cleanfiles)))
$(eval hfiles       := $(addprefix $(curdir),$(hfiles)))
$(eval cgofiles_np  := $(cgofiles))
$(eval cgofiles     := $(addprefix $(curdir),$(cgofiles)))
$(eval cgo_ofiles   := $(addprefix $(curdir),$(cgo_ofiles)))
$(eval targdir      := $(call DIR_OF,$(targ)))
$(eval installfiles := $(pkgdir)$(targ).a $(installfiles))
$(eval curdirI      := $(call DIR_AS_I_FLAG,$(curdir)))

$(curdir)$(targ)/all: $(curdir)$(targ).a

$(if $(cgofiles),$(call TEMPLATE_CGO_PACKAGE),)

$(curdir)$(targ).a: $(curdir)_go_.$O $(ofiles)
	$(call MKDIRP,$(curdir)$(targdir))
	rm -f $$@
	gopack grc $$@ $(curdir)_go_.$O $(ofiles)

$(curdir)_go_.$O: $(gofiles) $(deps)
	$(GC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(gcflags)) -o $$@ $(gofiles)

# should be used only when curdir != pkgdir
$(pkgdir)$(targ).a: $(curdir)$(targ).a
	$(call MKDIRP,$(pkgdir)$(targdir))
	cp $(curdir)$(targ).a $$@

$(curdir)$(targ)/install: $(installfiles)

$(curdir)$(targ)/clean:
	rm -rf $(curdir)*.o $(curdir)*.a $(curdir)*.[$(OS)]\
		$(curdir)[$(OS)].out $(cleanfiles)

$(curdir)%.$O: $(curdir)%.c
	$(CC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(cflags)) -o $$@ $(curdir)$$*.c

$(curdir)%.$O: $(curdir)%.s
	$(AS)$(call PRESPACE,$(curdirI)) -o $$@ $(curdir)$$*.s


ifdef hfiles
$(curdir)%.$O: $(hfiles)
endif

.PHONY: $(curdir)$(targ)/all\
	$(curdir)$(targ)/clean\
	$(curdir)$(targ)/install

# target local variables
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: curdir       := $(curdir)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: targ         := $(targ)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: ofiles       := $(ofiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: targdir      := $(targdir)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: gofiles      := $(gofiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: gcflags      := $(gcflags)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: pkgdir       := $(pkgdir)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: installfiles := $(installfiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: cleanfiles   := $(cleanfiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: cflags       := $(cflags)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: hfiles       := $(hfiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: deps         := $(deps)

endef
#------------------------------------------------------------------------------
# TEMPLATE_GO_PACKAGE_CLEAN_VARS
#------------------------------------------------------------------------------
# Template that cleans vars for TEMPLATE_GO_PACKAGE.
#------------------------------------------------------------------------------
define TEMPLATE_GO_PACKAGE_CLEAN_VARS

curdir       := 
targ         := 
ofiles       := 
targdir      := 
gofiles      := 
gcflags      := 
pkgdir       := 
installfiles := 
cleanfiles   := 
cflags       := 
hfiles       := 
cgofiles     :=
cgo_ofiles   :=
cgo_cflags   :=
cgo_ldflags  :=
deps         :=

endef

#------------------------------------------------------------------------------
# TEMPLATE_GO_PACKAGE_IN_DIR
#-ARGS-------------------------------------------------------------------------
# $1 - directory of a package
# $2 - installation destination of a package
#------------------------------------------------------------------------------
define TEMPLATE_GO_PACKAGE_IN_DIR

$(eval $(TEMPLATE_GO_PACKAGE_CLEAN_VARS))
$(eval curdir := $(call DIR_AS_PREFIX,$1))
$(eval pkgdir := $(call DIR_AS_PREFIX,$2))
$(eval include $(curdir)Make.def)
$(eval $(TEMPLATE_GO_PACKAGE))

endef

# vim: ft=make
