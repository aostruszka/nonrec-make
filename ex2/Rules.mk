TARGETS := app$(EXE)
SUBDIRS := a b

app$(EXE)_DEPS = app.o $(call subtree_tgts,$(d)/a) $(TARGETS_$(d)/b)
