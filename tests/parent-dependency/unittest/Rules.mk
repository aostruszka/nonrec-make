TARGETS := factorial_test$(EXE)

INCLUDES_$(d) := $(d)/../include
factorial_test$(EXE)_DEPS = ../factorial_lib.a factorial_test.o
