TARGETS := app2$(EXE)
SUBDIRS := a b

app2$(EXE)_DEPS = app.o $(call subtree_tgts,$(d)/a) $(TARGETS_$(d)/b)
