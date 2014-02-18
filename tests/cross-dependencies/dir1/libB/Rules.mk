TARGETS := libB.a

LIB_B_DIR := $(d)

INCLUDES_$(d) := $(LIB_B_DIR)/include

libB.a_DEPS = libB.o
