SUBDIRS_$(d) := $(patsubst %/,%,$(addprefix $(d)/,$(SUBDIRS)))

ifneq ($(strip $(OBJS)),)
OBJS_$(d) := $(addprefix $(OBJPATH)/,$(OBJS))
else # Populate OBJS_ from SRCS

# Expand wildcards in SRCS if they are given
ifneq ($(or $(findstring *,$(SRCS)),$(findstring ?,$(SRCS)),$(findstring ],$(SRCS))),)
  SRCS := $(notdir $(foreach sd,. $(SRCS_VPATH),$(wildcard $(addprefix $(d)/$(sd)/,$(SRCS)))))
endif

OBJS_$(d) := $(addprefix $(OBJPATH)/,$(addsuffix .o,$(basename $(SRCS))))
endif

CLEAN_$(d) := $(CLEAN_$(d)) $(addprefix $(d)/,$(CLEAN))

$(foreach sd,$(SRCS_VPATH),$(eval INCLUDES_$(d)/$(sd) := $(or $(INCLUDES_$(d)/$(sd)),$(INCLUDES_$(d)))))

ifdef TARGETS
TARGETS_$(d) := $(addprefix $(OBJPATH)/,$(TARGETS))
$(foreach tgt,$(filter-out $(AUTO_TGTS),$(TARGETS)),$(eval $(call save_vars,$(tgt))))
else
TARGETS_$(d) := $(OBJS_$(d))
endif

$(foreach sd,$(SUBDIRS),$(eval $(call include_subdir_rules,$(sd))))

.PHONY: dir_$(d) clean_$(d) clean_extra_$(d) clean_tree_$(d)
.SECONDARY: $(OBJPATH)/.fake_file

# Whole tree targets
all :: $(TARGETS_$(d))

clean_all :: clean_$(d)

dist_clean :: clean_extra_$(d)
	rm -rf $(subst clean_extra_,,$<)/$(subst $(HOST_ARCH),,$(OBJDIR))

# Per directory targets
clean_$(d) : clean_extra_$(d)
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
endif

# This is a default rule - see Makefile
dir_$(d) : $(or $(TARGETS_$(d)),$(SUBDIRS_TGTS))
