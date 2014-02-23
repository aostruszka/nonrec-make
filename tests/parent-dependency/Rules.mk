TARGETS := factorial_lib.a
SUBDIRS := unittest

CFLAGS_$(d) := -std=c99
INCLUDES_$(d) := $(d)/include

factorial_lib.a_DEPS = factorial_lib.o
