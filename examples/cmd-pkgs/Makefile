TEMPLATES_DIR=../..
include $(TEMPLATES_DIR)/go.make

all: $(addsuffix /install,a/a b/b) app/all
clean: $(addsuffix /clean,a/a b/b app)

PKGS=a b
$(foreach p,$(PKGS),$(eval $(call TEMPLATE_GO_PACKAGE_IN_DIR,$(p),)))

# main app
$(eval $(call TEMPLATE_GO_COMMAND_CLEAN_VARS))

targ    := app
gofiles := main.go

$(eval $(call TEMPLATE_GO_COMMAND))
