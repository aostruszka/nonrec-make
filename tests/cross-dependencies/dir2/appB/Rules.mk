TARGETS := appB$(EXE)

INCLUDES_$(d) = $(LIB_B_DIR)/include

appB$(EXE)_DEPS = appB.o $$(TARGETS_$$(LIB_B_DIR))
