include $(MK)/config-default.mk

# These two settings are the reason for a separate config
CPPFLAGS += -DSPARC
# On Sun the sockets are in a separate library
#LDLIBS += -lsocket
