TARGETS := hello$(EXE)

INCLUDES_$(d) := $(d)/include

hello$(EXE)_DEPS = main.o lib.o
