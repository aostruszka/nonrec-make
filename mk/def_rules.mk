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
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = @$(echo_prog) "$(COLOR)$(1)$(NOCOLOR)";
else
echo_cmd = @echo "$(1)";
endif
else # Verbose output
echo_cmd =
endif

COMPILE.c = $(call echo_cmd,CC $<) $(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
COMPILE.cc = $(call echo_cmd,CXX $<) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c
LINK.c = $(call echo_cmd,LINK $@) $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)
LINK.cc = $(call echo_cmd,LINK $@) $(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)

# These two rules are just for running preprocessor and saving the
# output into the file with .E appended - sometimes this can be handy.
%.c.E : %.c
	$(call echo_cmd,CPP $<) $(CPP) $(CPPFLAGS) -o $@ $<

%.cpp.E : %.cpp
	$(call echo_cmd,CPP $<) $(CPP) $(CPPFLAGS) -o $@ $<

# In this build system all objects are in a separate directory and
# I make sure this directory exists by the dependency on this fake file
%/$(OBJDIR)/.fake_file:
	@[ -d $(dir $@) ] || mkdir -p $(dir $@); touch $@

# Generic rules.  Again, since the output is in different directory than
# source files I cannot count on the built in make rules.  So I keep
# them in a "macro" that is expanded for every directory with Rules.mk
# (and its SRCS_VPATH subdirectories).  This compile command should be
# generic for most compilers - you should just define its COMPILE
# variable.
# In cases where from one source different types of objects can be
# generated I have added COMPILECMD_TD (TD stands for "target
# dependent").  So e.g. for OCaml one could use:
# CAML := ocamlc
# CAMLOPT := ocamlopt
# AUTO_TGTS += %.cmo %.cmx # or modify its value in skel.mk
# COMPILE.cmo.ml = $(call echo_cmd,CAML $<) $(CAML) -c
# COMPILE.cmx.ml = $(call echo_cmd,CAMLOPT $<) $(CAMLOPT) -c
# together with corresponding two entries in 'skeleton' below:
# $(OBJPATH)/%.cmo $(OBJPATH)/%.cmx: $(1)/%.ml $(OBJPATH)/.fake_file
# 	$(value COMPILECMD_TD)

COMPILECMD = $(COMPILE$(suffix $<)) -o $@ $<
COMPILECMD_TD = $(COMPILE$(suffix $@)$(suffix $<)) -o $@ $<

define skeleton
$(OBJPATH)/%.o: $(1)/%.cpp $(OBJPATH)/.fake_file
	$(value COMPILECMD)

$(OBJPATH)/%.o: $(1)/%.cc $(OBJPATH)/.fake_file
	$(value COMPILECMD)

$(OBJPATH)/%.o: $(1)/%.c $(OBJPATH)/.fake_file
	$(value COMPILECMD)
endef
