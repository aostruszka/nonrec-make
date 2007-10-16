include $(MK)/header.mk

# If you want to use wildcards you can do it that way
SRCS := $(notdir $(wildcard $(d)/*.c))

include $(MK)/footer.mk
