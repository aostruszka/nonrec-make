# Clear vars used by this make system
SRCS :=
SRCS_EXCLUDES :=
OBJS :=
CLEAN :=
TARGETS :=
SUBDIRS :=

# Clear user vars
$(foreach v,$(VERB_VARS) $(OBJ_VARS) $(DIR_VARS),$(eval $(v) := ))
