# Fill BUILD_ARCH with appropriate value automatically (with some
# cosmetics in case of Cygwin :)).
BUILD_ARCH := $(patsubst CYGWIN_%,Cygwin,$(shell uname -s))-$(shell uname -m)

# Target platform (where the code will be executed).  I'm not using
# TARGET_ARCH for this since this variable is already used in builtin
# make rules and I want to be able to use those built in rules.  By
# default we are running on the same machine we are building.
HOST_ARCH := $(BUILD_ARCH)

# Again, by default we are running on the same architecture we are
# building - if you're cross compiling then you should set this manually
ENDIAN := $(shell perl -le 'print unpack(N,pack(L,0x01020304)) == 0x01020304 ? big : little')

# Make the compiler invocation lines terse
VERBOSE := false

# Uncomment if you don't like coloring of the output
#COLOR_TTY := false

# Any additional settings should go here
