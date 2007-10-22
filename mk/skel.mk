# For the reference here are some automatic variables defined by make.
# There are also their D/F variants e.g. $(<D) - check the manual.
#
# $@ - file name of the target of the rule
# $% - target member name when the target is archive member
# $< - the name of the first dependency
# $? - the names of all dependencies that are newer then the target
# $^ - the names of all dependencies

# Directory specific flags.  You just define in Rules.mk say
# INCLUDES_$(d) := ....
# and this will get expanded properly during compilation (see e.g. COMPILE.c)
# Of course you can still use the target specific variables if you want
# to have special setting for just one target and not the whole
# directory.
DIR_INCLUDES = $(addprefix -I,$(INCLUDES_$(<D)))
DIR_CFLAGS = $(CFLAGS_$(<D))
DIR_CXXFLAGS = $(CXXFLAGS_$(<D))

CFLAGS = -g -W -Wall $(DIR_CFLAGS)
CXXFLAGS = -g -W -Wall $(DIR_CXXFLAGS)

# List of includes that all (or at least majority) needs
INCLUDES :=

# Here's an example of settings for preprocessor.  -MMD is to
# automatically build dependency files as a side effect of compilation.
# This has some drawbacks (e.g. when you move/rename a file) but it is
# good enough for me.  You can improve this by using a special script
# that builds the dependency files (one can find examples on the web).
# Note that I'm adding DIR_INCLUDES before INCLUDES so that they have
# precedence.
CPPFLAGS = -MMD -D_REENTRANT -D_POSIX_C_SOURCE=200112L -D__EXTENSIONS__ \
	   -DDEBUG $(DIR_INCLUDES) $(addprefix -I,$(INCLUDES))

# Linker flags for all configurations
LDFLAGS :=
LDLIBS := # -lpthread

############# This is the end of generic flags #############

# Now we suck in configuration ...
include $(MK)/config.mk
# ... host and build specific settings ...
ifneq ($(wildcard $(MK)/config-$(BUILD_ARCH)_$(HOST_ARCH).mk),)
  include $(MK)/config-$(BUILD_ARCH)_$(HOST_ARCH).mk
else
  include $(MK)/config-default.mk
endif

# ... and here's a good place to translate some of these settings into
# compilation flags/variables.  As an example a preprocesor macro for
# target endianess
ifeq ($(ENDIAN),big)
  CPPFLAGS += -DBIG_ENDIAN
else
  CPPFLAGS += -DLITTLE_ENDIAN
endif

######### A more advanced part - if you change anything below    ######
######### you should have at least vague idea how this works :D  ######

# I define these for convenience - you can use them in your command for
# updating the target.  Since I'm using fake file dependency to make
# sure the OBJDIR exists I filter it out here.  Mnemonic for these
# ? ^ versions is Real (that is not fake :))
DEP_LIBS = $(filter %.a, $^)
DEP_OBJS = $(filter %.o, $^)
?R = $(filter-out %/.fake_file,$?)
^R = $(filter-out %/.fake_file,$^)

# Targets that match this pattern (make pattern) will use rules defined
# in:
# - def_rules.mk included below (explicit or via `skeleton' macro)
# - built in make rules
# Other targets will have to use _DEPS (and so on) variables which are
# saved in `save_vars' and used in `tgt_rule' (see below).
AUTO_TGTS := %.o

# Where to put the compiled objects.  You can e.g. make it different
# depending on the target platform (e.g. for cross-compilation a good
# choice would be OBJDIR := obj/$(HOST_ARCH)) or debugging being on/off.
OBJDIR := obj
OBJPATH = $(d)/$(OBJDIR)

# This variable contains a list of subdirectories where to look for
# sources.  That is if you have some/dir/Rules.mk where you name object
# say client.o this object will be created in some/dir/$(OBJDIR)/ and
# corresponding source file will be searched in some/dir and in
# some/dir/{x,y,z,...} where "x y z ..." is value of this variable.
SRCS_VPATH := src

# These are commands that are used to update the target.  If you have
# a target that make handles with built in rules just add its pattern to
# the AUTO_TGTS below.  Otherwise you have to supply the command and you
# can either do it explicitly with _CMD variable or based on the
# target's suffix and corresponding MAKECMD variable.  For example %.a
# are # updated by MAKECMD.a (examplary setting below).  If the target
# is not filtered out by AUTO_TGTS and there's neither _CMD nor suffix
# specific command to build the target DEFAULT_MAKECMD is used.  See
# skel.mk for the explanation of the R versions of ? and ^ variables.
MAKECMD.a = $(call echo_cmd,AR $@) $(AR) $(ARFLAGS) $@ $(?R) && $(RANLIB) $@
DEFAULT_MAKECMD = $(LINK.cc) $(^R) $(LDLIBS) -o $@

########################################################################
# Below is a "Blood sugar sex^H^H^Hmake magik" :) - don't touch it
# unless you know what you are doing.
########################################################################

# This can be useful.  E.g. if you want to set INCLUDES_$(d) for given
# $(d) to the same value as includes for its parent directory plus some
# add ons then: INCLUDES_$(d) := $(INCLUDES_$(parent)) ...
parent = $(patsubst %/,%,$(dir $(d)))

define include_subdir_rules
dir_stack := $(d) $(dir_stack)
d := $(d)/$(1)
include $(addsuffix /Rules.mk,$$(d))
d := $$(firstword $$(dir_stack))
dir_stack := $$(wordlist 2,$$(words $$(dir_stack)),$$(dir_stack))
endef

define save_vars
DEPS_$(OBJPATH)/$(1) = $$($(1)_DEPS)
LIBS_$(OBJPATH)/$(1) = $$($(1)_LIBS)
CMD_$(OBJPATH)/$(1) = $$($(1)_CMD)
endef

define tgt_rule
abs_deps := $$(filter /%,$$(DEPS_$(1)))
rel_deps := $$(filter-out /%,$$(DEPS_$(1)))
abs_deps += $$(addprefix $(OBJPATH)/,$$(rel_deps))
-include $$(addsuffix .d,$$(basename $$(abs_deps)))
ifneq ($(LIBS_$(1)),)
$(1): LDLIBS += $(LIBS_$(1))
endif
$(1): $$(abs_deps) $(OBJPATH)/.fake_file
	$$(or $$(CMD_$(1)),$$(MAKECMD$$(suffix $$@)),$$(DEFAULT_MAKECMD))
endef

# Suck in the default rules
include $(MK)/def_rules.mk
