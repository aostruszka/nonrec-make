# For now I depend on flex and bison - I want to generate source files
# in the same directory as their lex/yacc inputs.
%.c %.h : %.y
	bison -d -o $*.c $<

%.c : %.l
	flex -o$@ $<

# "Pretty printing" stuff
#
# The value of the variable VERBOSE decides whether to output only
# a short note what is being done (e.g. "CC foobar.c") or a full
# command line.
#
# Sometimes you have a code that you're not in charge of and which gives
# a lot of warnings.  In that case you can use colors so that you find
# easily what is being compiled.  By default I check terminal
# capabilities and use colors only when the terminal support them but you
# can suppress coloring by setting COLOR_TTY to something else than
# 'true' (see config.mk).
# Please don't argue about this choice of colors - I'm always using black
# background so yellow on black it is :-D - background is specified
# below just for those using bright background :-P
COLOR := \033[33;40m
NOCOLOR := \033[0m

ifndef COLOR_TTY
COLOR_TTY := $(shell [ `tput colors` -gt 2 ] && echo true)
endif

ifneq ($(VERBOSE),true)
ifneq ($(strip $(TOP_BUILD_DIR)),)
  strip_top = $(subst $(TOP)/,,$(subst $(TOP_BUILD_DIR)/,,$(1)))
else
  strip_top = $(subst $(TOP)/,,$(1))
endif
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = @$(echo_prog) "$(COLOR)$(call strip_top,$(1))$(NOCOLOR)";
else
echo_cmd = @echo "$(call strip_top,$(1))";
endif
else # Verbose output
echo_cmd =
endif

COMPILE.c = $(call echo_cmd,CC $<) $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cc = $(call echo_cmd,CXX $<) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
LINK.c = $(call echo_cmd,LINK $@) $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LINK.cc = $(call echo_cmd,LINK $@) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)

# This rule is just for running C/C++ preprocessor and saving the output
# into the file with .E appended - sometimes this can be handy.
# Suffix E comes from -E option to gcc.  Make sure you invoke this rule
# via full path (e.g.: make $(pwd)/foobar.c.E) if you want to have per
# directory preprocessor flags included.
%.E : %
	$(call echo_cmd,CPP $<) $(CPP) $(CPPFLAGS) -o $@ $<

# Special rule to get easily CPP options for given file.  This can be
# handy for your code "assistant" (e.g. clang) that needs to know
# preprocessor options in order to parse file properly.  In that case
# you can run: make /path/to/foobar.c.CPPFLAGS | tail -1
# to get effective flags for foobar.c
%.CPPFLAGS : %
	@echo $(CPPFLAGS)

# Create the output directory for build targets.
%/$(OBJDIR):
	@mkdir -p $@

# Automatic rules.  Again, since the output is in different directory
# than source files I cannot count on the built in make rules.  So
# I keep them in a "macro" (see 'skeleton' below) that is expanded for
# every directory with Rules.mk (and its SRCS_VPATH subdirectories).
# Below setting means that %.o are made from %.cpp and the same for .cc
# and .c - this is just the list of mappings.
# You can add your own here.  For example to add support for Fortran you
# would just append ".o:.f" and set COMPILE.f (actually make already
# defines it - just take a look at output of "make -p")
AUTO_RULES := .o:.cpp .o:.cc .o:.c
# Additional mapping together with corresponding variables can be specified
# in user_rules.mk
-include $(MK)/user_rules.mk

# This compile command should be generic for most compilers - you should
# just define appropriate COMPILE.suffix variable.
COMPILECMD = $(COMPILE$(suffix $<)) -o $@ $<

# In cases where from one source different types of objects can be
# generated I have added COMPILECMD_TD (TD stands for "target
# dependent").  So e.g. for OCaml one could use:
# CAML := ocamlc
# CAMLOPT := ocamlopt
# AUTO_TGTS += %.cmo %.cmx # or modify its value in skel.mk
# COMPILE.cmo.ml = $(call echo_cmd,CAML $<) $(CAML) -c
# COMPILE.cmx.ml = $(call echo_cmd,CAMLOPT $<) $(CAMLOPT) -c
# AUTO_TD_RULES := .cmo&.cmx:.ml
# The syntax for AUTO_TD_RULES is similar to AUTO_RULES but instead of
# single output suffix (e.g. ".o") you have to list them all separated
# by "&" (sorry, comma gives me problems since it is part of normal make
# syntax for functions :P).  The above setting means that %.cmo and %.cmx
# can be generated from %.ml via their respective COMPILE commands
# expanded in COMPILECMD_TD (see below).

# Again this should be generic enough so that you won't have to touch it
COMPILECMD_TD = $(COMPILE$(suffix $@)$(suffix $<)) -o $@ $<

# Definition of variable ${\n} containing just new-line character
define \n


endef

# Definition of 'skeleton' macro used in generation of recipes.  This
# definition is itself computed so you should not modify it (unless you
# know what you are doing :D).  It should be enough for you to add new
# mappings to AUTO_RULES and AUTO_TD_RULES above and define/change
# corresponding COMPILE.suffix and COMPILE.outsuffix.insuffix variables.
$(eval define skeleton$(foreach rule,$(AUTO_RULES),${\n}$$(OBJPATH)/%$(subst :,: $$(1)/%,$(rule)) | $$(OBJPATH); $$(value COMPILECMD))${\n}\
                      $(foreach rule,$(AUTO_TD_RULES),${\n}$$(OBJPATH)/%$(subst :,: $$(1)/%,$(subst &, $$(OBJPATH)/%,$(rule))) | $$(OBJPATH); $$(value COMPILECMD_TD))${\n}endef)
