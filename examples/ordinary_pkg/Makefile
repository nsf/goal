TEMPLATES_DIR=../..
include $(TEMPLATES_DIR)/go.make

all: makecoffee/all
install: makecoffee/install
clean: makecoffee/clean

$(eval $(call TEMPLATE_GO_PACKAGE_CLEAN_VARS))

targ=makecoffee
gofiles=makecoffee.go
pkgdir=$(call DIR_AS_PREFIX,$(PKGDIR_DEFAULT))

$(eval $(call TEMPLATE_GO_PACKAGE))
