# You can use wildcards in SRCS - they are detected and expanded by this
# make system (not make itself).  You can always use builtin wildcard
# function e.g. SRCS := $(notdir $(wildcard ...))
SRCS := *.c

# If you'd like to exclude some files that are matching glob just list
# them in SRCS_EXCLUDES :) - this is a list of makefile patterns
SRCS_EXCLUDES := extra% test%
