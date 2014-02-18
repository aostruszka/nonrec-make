TARGETS := libdir3.$(SOEXT)

INSTALL_LIB := $(TARGETS)

# This is just an example how you can give a name to your target
# that can be referred in any other place.  Note that when referring
# from Rules.mk that has been read earlier you have to defer expansion
# (see Dir_1/Rules.mk for more info).
DIR3_LIB := $(OBJPATH)/$(TARGETS)

libdir3.$(SOEXT)_DEPS := dir_3_file1.o dir_3_file2.o

# You should not forget about that when you create shared library
# When it is not needed for your platform gcc will tell you that :)
CFLAGS_$(d) := -fPIC
