# For now I depend on flex and bison
%.c %.h : %.y
	bison -d -o $*.c $<

%.c : %.l
	flex -o$@ $<

# Sometimes you have a code that you're not in charge of and which gives
# a lot of warnings.  In that case you can use colors so that you find
# easily what is being compiled.  By default I check terminal
# capabilities and use colors only when the terminal suport them but you
# can surpress coloring by setting COLOR_TTY to something else than
# 'true' (see config.mk).
# Please don't argue about this choice of colors - I'm always using black
# background so yellow on black it is :-D - background is specified
# below just for those using bright background :-P
COLOR := \033[33;40m
NOCOLOR := \033[0m

ifndef COLOR_TTY
COLOR_TTY := $(shell [ `tput colors` -gt 2 ] && echo true)
endif

ifeq ($(CC_SILENT),true)
ifeq ($(COLOR_TTY),true)
echo_prog := $(shell if echo -e | grep -q -- -e; then echo echo; else echo echo -e; fi)
echo_cmd = @$(echo_prog) "$(COLOR)$(1)$(NOCOLOR)";
else
echo_cmd = @echo "$(1)";
endif
else
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
