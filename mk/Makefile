# When I'm using default shell on Cygwin $(shell pwd) does not give the
# same result as $(shell echo $$PWD) or $(shell echo `pwd`).  It gives
# me path with symbolic links resolved whereas the later two do not do
# that.  I prefer unresolved version and since simple $(shell pwd) looks
# nicer than other two I'm sticking with bash :).
SHELL := /bin/bash
RUNDIR := $(shell pwd)
ifndef TOP
TOP := $(shell \
       top=$(RUNDIR); \
       while [ ! -r "$$top/Rules.top" ] && [ "$$top" != "" ]; do \
           top=$${top%/*}; \
       done; \
       echo $$top)
endif

MK := $(TOP)/mk

.PHONY: dir tree all clean clean_all clean_tree dist_clean

# Default target when nothing is given on the command line.  Reasonable
# options are:
# "dir"  - updates only targets from current directory and its dependencies
# "tree" - updates targets (and their dependencies) in whole subtree
#          starting at current directory
# "all"  - updates all targets in the project
.DEFAULT_GOAL := dir

dir : dir_$(RUNDIR)
tree : tree_$(RUNDIR)

clean : clean_$(RUNDIR)
clean_tree : clean_tree_$(RUNDIR)

include $(MK)/header.mk
include $(TOP)/Rules.top
include $(MK)/footer.mk

# Optional final makefile where you can specify additional targets
-include $(TOP)/final.mk

# This is just a convenience - to let you know when make has stopped
# interpreting make files and started their execution.
$(info Rules generated $(if $(BUILD_MODE),for $(BUILD_MODE),)...)
