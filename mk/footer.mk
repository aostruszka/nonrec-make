SUBDIRS_$(d) := $(patsubst %/,%,$(addprefix $(d)/,$(SUBDIRS)))

ifneq ($(strip $(OBJS)),)
OBJS_$(d) := $(addprefix $(OBJPATH)/,$(OBJS))
else # Populate OBJS_ from SRCS

# Expand wildcards in SRCS if they are given
ifneq ($(or $(findstring *,$(SRCS)),$(findstring ?,$(SRCS)),$(findstring ],$(SRCS))),)
  SRCS := $(notdir $(foreach sd,. $(SRCS_VPATH),$(wildcard $(addprefix $(d)/$(sd)/,$(SRCS)))))
  SRCS := $(filter-out $(SRCS_EXCLUDES), $(SRCS))
endif

OBJS_$(d) := $(addprefix $(OBJPATH)/,$(addsuffix .o,$(basename $(SRCS))))
endif

CLEAN_$(d) := $(CLEAN_$(d)) $(addprefix $(d)/,$(CLEAN))

ifdef TARGETS
TARGETS_$(d) := $(addprefix $(OBJPATH)/,$(TARGETS))
$(foreach tgt,$(filter-out $(AUTO_TGTS),$(TARGETS)),$(eval $(call save_vars,$(tgt))))
else
TARGETS_$(d) := $(OBJS_$(d))
endif

INSTALL_BIN_$(d) := $(addprefix $(OBJPATH)/,$(INSTALL_BIN))
INSTALL_LIB_$(d) := $(addprefix $(OBJPATH)/,$(INSTALL_LIB))
# Documentation is a bit special since it usually is not generated and
# if it is then most probably not in OBJDIR so I'm prefixing it with
# current directory iff it is not absolute path
INSTALL_DOC_$(d) := $(filter /%,$(INSTALL_DOC)) $(addprefix $(d)/,$(filter-out /%,$(INSTALL_DOC)))

########################################################################
# Inclusion of subdirectories rules - only after this line one can     #
# refer to subdirectory targets and so on.                             #
########################################################################
$(foreach sd,$(SUBDIRS),$(eval $(call include_subdir_rules,$(sd))))

.PHONY: dir_$(d) clean_$(d) clean_extra_$(d) clean_tree_$(d) dist_clean_$(d)
.SECONDARY: $(OBJPATH)/.fake_file

# Whole tree targets
all :: $(TARGETS_$(d))

clean_all :: clean_$(d)
dist_clean :: dist_clean_$(d)

# No point to enforce clean_extra dependency if CLEAN is empty
ifeq ($(strip $(CLEAN_$(d))),)
dist_clean_$(d) :
else
dist_clean_$(d) : clean_extra_$(d)
endif
	rm -rf $(subst dist_clean_,,$@)/$(firstword $(subst /, ,$(OBJDIR)))

########################################################################
#                        Per directory targets                         #
########################################################################

# Again - no point to enforce clean_extra dependency if CLEAN is empty
ifeq ($(strip $(CLEAN_$(d))),)
clean_$(d) :
else
clean_$(d) : clean_extra_$(d)
endif
	rm -f $(subst clean_,,$@)/$(OBJDIR)/*

clean_extra_$(d) :
	rm -f $(CLEAN_$(subst clean_extra_,,$@))

clean_tree_$(d) : clean_$(d) $(foreach sd,$(SUBDIRS_$(d)),clean_tree_$(sd))

# Skip the target rules generation and inclusion of the dependencies
# when we just want to clean up things :)
ifeq ($(filter clean clean_% dist_clean,$(MAKECMDGOALS)),)

SUBDIRS_TGTS := $(foreach sd,$(SUBDIRS_$(d)),$(TARGETS_$(sd)))

# Use the skeleton for the "current dir"
$(eval $(call skeleton,$(d)))
# and for each SRCS_VPATH subdirectory of "current dir"
$(foreach vd,$(SRCS_VPATH),$(eval $(call skeleton,$(d)/$(vd))))

# Target rules for all "non automatic" targets
$(foreach tgt,$(filter-out $(AUTO_TGTS),$(TARGETS_$(d))),$(eval $(call tgt_rule,$(tgt))))

# Way to build all targets in given subtree (not just current dir as via
# dir_$(d) - see below)
tree_$(d) : $(TARGETS_$(d)) $(foreach sd,$(SUBDIRS_$(d)),tree_$(sd))

# If the directory is just for grouping its targets will be targets from
# all subdirectories
ifeq ($(strip $(TARGETS_$(d))),)
TARGETS_$(d) := $(SUBDIRS_TGTS)
endif

# This is a default rule - see Makefile
dir_$(d) : $(TARGETS_$(d))

endif
