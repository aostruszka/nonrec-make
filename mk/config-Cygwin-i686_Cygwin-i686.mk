include $(MK)/config-default.mk

CPPFLAGS += -DCYGWIN
# There's no rt lib on Cygwin
LDLIBS := $(subst -lrt,,$(LDLIBS))

# On cygwin shared libraries have dll extension
SOEXT := dll
# and by default executables have .exe appended
EXE := .exe
