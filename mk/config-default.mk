# Default values for CC/CXX/AR for GNU make are cc/g++/ar which are OK
# for me but I spell them out here explicitly (with cc->gcc change) so
# you can easily change them.
# You can also override these from command line or via global variables
ifeq ($(origin CC),default)
  CC := gcc
endif
ifeq ($(origin CXX),default)
  CXX := g++
endif
ifeq ($(origin AR),default)
  AR := ar
endif
ifneq ($(filter undefined default,$(origin RANLIB)),)
  RANLIB := ranlib
endif

OPEN_GL_LIBS := -lGL -lGLU
