TARGETS := dir1_lib.a
SUBDIRS := Dir_1a Dir_1b

dir1_lib.a_DEPS = dir_1_file1.o dir_1_file2.o dir_1_file3.o $(SUBDIRS_TGTS)
