TARGETS := dir1_lib.a
SUBDIRS := Dir_1a Dir_1b

INSTALL_LIB := $(TARGETS)

# If you have twisted interdependencies in your project that you cannot
# resolve by simple ordering of directories listed in SUBDIRS, then you
# can still refer to the variables that will be defined in Rules.mk that
# are yet to be read.  But you have to defer their expansion by simply
# protecting $ with another $ (like below for DIR3_LIB).
dir1_lib.a_DEPS = dir_1_file1.o dir_1_file2.o dir_1_file3.o $(SUBDIRS_TGTS) $$(DIR3_LIB)
