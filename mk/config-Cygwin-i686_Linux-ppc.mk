# How the "cross tools" should be invoked
CC := powerpc-750-linux-gnu-gcc
CXX := powerpc-750-linux-gnu-g++
AR := powerpc-750-linux-gnu-ar
RANLIB := powerpc-750-linux-gnu-ranlib

# Since we are compiling for a "remote target" we have to set this manually
ENDIAN := big

# Any other target specific settings
CPPFLAGS += -DLINUX_PPC
