ifndef d
d := $(or $(TOP),$(shell pwd))
dir_stack :=
# Automatic inclusion of the skel.mk at the top level - that way
# Rules.top has exactly the same structure as other Rules.mk
include $(MK)/skel.mk
endif

SRCS :=
OBJS :=
CLEAN :=
TARGETS :=
SUBDIRS :=
