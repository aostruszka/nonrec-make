TARGETS := libdir3.$(SOEXT)

INSTALL_LIB := $(TARGETS)

libdir3.$(SOEXT)_DEPS := dir_3_file1.o dir_3_file2.o

# You should not forget about that when you create shared library
# When it is not needed for your platform gcc will tell you that :)
CFLAGS_$(d) := -fPIC
