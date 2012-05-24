ifndef d
d := $(or $(TOP),$(shell pwd))
dir_stack :=
# Automatic inclusion of the skel.mk at the top level - that way
# Rules.top has exactly the same structure as other Rules.mk
include $(MK)/skel.mk
endif

# Clear vars used by this make system
SRCS :=
SRCS_EXCLUDES :=
OBJS :=
CLEAN :=
TARGETS :=
SUBDIRS :=

# Clear user vars
$(foreach v,$(VERB_VARS) $(OBJ_VARS) $(DIR_VARS),$(eval $(v) := ))
