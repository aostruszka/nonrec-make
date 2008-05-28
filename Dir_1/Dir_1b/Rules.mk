include $(MK)/header.mk

# Wildcards in SRCS work both in "current" directory and its SRCS_VPATH
# subdirectories
SRCS := *.c

include $(MK)/footer.mk
