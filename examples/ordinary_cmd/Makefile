TEMPLATES_DIR=../..
include $(TEMPLATES_DIR)/go.make

all: bin2go/all
install: bin2go/install
clean: bin2go/clean

$(eval $(call TEMPLATE_GO_COMMAND_CLEAN_VARS))

targ=bin2go
gofiles=bin2go.go

$(eval $(call TEMPLATE_GO_COMMAND))
