TARGETS := appA$(EXE)

INCLUDES_$(d) = $(LIB_A_DIR)/include

appA$(EXE)_DEPS = appA.o $$(TARGETS_$$(LIB_A_DIR))
