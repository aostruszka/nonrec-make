SUBDIRS := libA libB

TARGETS := bigLib.a main$(EXE)

INCLUDES_$(d) = $(LIB_B_DIR)/include $(LIB_A_DIR)/include

# Make a new archive out of several existing archives
bigLib.a_DEPS = $(LIB_A) $(LIB_B)

main$(EXE)_DEPS = bigLib.a main.o
