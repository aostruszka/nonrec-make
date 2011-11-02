TARGETS := dir2_lib.a
SUBDIRS := Dir_2a Dir_2b Dir_ex

dir2_lib.a_DEPS = dir_2_file1.o dir_2_file2.o \
		$(TARGETS_$(d)/Dir_2a) $(TARGETS_$(d)/Dir_2b)
