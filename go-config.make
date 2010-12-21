# Copyright 2009 The Go Authors. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# GOROOT must be set.
ifeq ($(GOROOT),)
$(error $$GOROOT is not set; use gomake or set $$GOROOT in your environment)
endif

# Set up GOROOT_FINAL, GOARCH, GOOS if needed.
GOROOT_FINAL?=$(GOROOT)

ifeq ($(GOHOSTOS),)
GOHOSTOS:=$(shell uname | tr A-Z a-z | sed 's/mingw/windows/; s/.*windows.*/windows/')
endif

ifeq ($(GOOS),)
GOOS:=$(GOHOSTOS)
endif

ifeq ($(GOOS),darwin)
else ifeq ($(GOOS),freebsd)
else ifeq ($(GOOS),linux)
else ifeq ($(GOOS),tiny)
else ifeq ($(GOOS),plan9)
else ifeq ($(GOOS),windows)
else
$(error Invalid $$GOOS '$(GOOS)'; must be darwin, freebsd, linux, plan9, tiny, or windows)
endif

ifeq ($(GOHOSTARCH),)
ifeq ($(GOHOSTOS),darwin)
# Even on 64-bit platform, darwin uname -m prints i386.
# Check for amd64 with sysctl instead.
GOHOSTARCH:=${shell if sysctl machdep.cpu.extfeatures | grep EM64T >/dev/null; then echo amd64; else uname -m | sed 's/i386/386/'; fi}
else
# Ask uname -m for the processor.
GOHOSTARCH:=${shell uname -m | sed 's/^..86$$/386/; s/^.86$$/386/; s/x86_64/amd64/; s/arm.*/arm/'}
endif
endif

ifeq ($(GOARCH),)
GOARCH:=$(GOHOSTARCH)
endif

# darwin requires GOHOSTARCH match GOARCH
ifeq ($(GOOS),darwin)
GOHOSTARCH:=$(GOARCH)
endif

ifeq ($(GOARCH),386)
O:=8
else ifeq ($(GOARCH),amd64)
O:=6
else ifeq ($(GOARCH),arm)

O:=5
ifeq ($(GOOS),linux)
else
$(error Invalid $$GOOS '$(GOOS)' for GOARCH=arm; must be linux)
endif

else
$(error Invalid $$GOARCH '$(GOARCH)'; must be 386, amd64, or arm)
endif

# Save for recursive make to avoid recomputing.
export GOARCH GOOS GOHOSTARCH GOHOSTOS

# ugly hack to deal with whitespaces in $GOROOT
nullstring :=
space := $(nullstring) # a space at the end
QUOTED_GOROOT:=$(subst $(space),\ ,$(GOROOT))

# default GOBIN
ifndef GOBIN
GOBIN=$(QUOTED_GOROOT)/bin
endif
QUOTED_GOBIN=$(subst $(space),\ ,$(GOBIN))

AS=${O}a
CC=${O}c
GC=${O}g
LD=${O}l
OS=568vq
CFLAGS=-FVw

HOST_CC=gcc
HOST_LD=gcc
HOST_O=o
HOST_YFLAGS=-d
HOST_AR?=ar

# These two variables can be overridden in the environment
# to build with other flags.  They are like $CFLAGS and $LDFLAGS
# in a more typical GNU build.  We are more explicit about the names
# here because there are different compilers being run during the
# build (both gcc and 6c, for example).
HOST_EXTRA_CFLAGS?=-ggdb -O2
HOST_EXTRA_LDFLAGS?=

HOST_CFLAGS=-I"$(GOROOT)/include" $(HOST_EXTRA_CFLAGS)
HOST_LDFLAGS=$(HOST_EXTRA_LDFLAGS)
PWD=$(shell pwd)

# CGO flags
CGO_CFLAGS_386=-m32
CGO_CFLAGS_amd64=-m64
CGO_LDFLAGS_freebsd=-shared -lpthread -lm
CGO_LDFLAGS_linux=-shared -lpthread -lm
CGO_LDFLAGS_darwin=-dynamiclib -Wl,-undefined,dynamic_lookup
CGO_LDFLAGS_windows=-shared -lm -mthreads

# Default destination for packages
PKGDIR_DEFAULT:=$(GOROOT)/pkg/$(GOOS)_$(GOARCH)

# Make environment more standard.
LANG:=
LC_ALL:=C
LC_CTYPE:=C
GREP_OPTIONS:=
GREP_COLORS:=
export LANG LC_ALL LC_CTYPE GREP_OPTIONS GREP_COLORS

go-env:
	@echo export GOARCH=$(GOARCH)
	@echo export GOOS=$(GOOS)
	@echo export GOHOSTARCH=$(GOHOSTARCH)
	@echo export GOHOSTOS=$(GOHOSTOS)
	@echo export O=$O
	@echo export AS="$(AS)"
	@echo export CC="$(CC)"
	@echo export GC="$(GC)"
	@echo export LD="$(LD)"
	@echo export OS="$(OS)"
	@echo export CFLAGS="$(CFLAGS)"
	@echo export LANG="$(LANG)"
	@echo export LC_ALL="$(LC_ALL)"
	@echo export LC_CTYPE="$(LC_CTYPE)"
	@echo export GREP_OPTIONS="$(GREP_OPTIONS)"
	@echo export GREP_COLORS="$(GREP_COLORS)"
	@echo MAKE_GO_ENV_WORKED=1

# Don't let the targets in this file be used
# as the default make target.
.DEFAULT_GOAL:=
# vim: ft=make

