include $(MK)/config-default.mk

CPPFLAGS += -DCYGWIN
# There's no rt lib on Cygwin
LDLIBS := $(subst -lrt,,$(LDLIBS))
