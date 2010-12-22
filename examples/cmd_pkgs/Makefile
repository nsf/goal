TEMPLATES_DIR=../..
include $(TEMPLATES_DIR)/go.make

all: app/all
clean: $(addsuffix /clean,a/a b/b c/c) app/clean

PKGS=a b c

$(foreach p,$(PKGS),$(eval $(call TEMPLATE_GO_PACKAGE_IN_DIR,$(p),)))

# main app
$(eval $(call TEMPLATE_GO_COMMAND_CLEAN_VARS))

targ    := app
gofiles := main.go
deps    := a.a b.a c.a

$(eval $(call TEMPLATE_GO_COMMAND))
