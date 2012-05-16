TARGETS := app2.exe
SUBDIRS := a b

app2.exe_DEPS = app.o $(call subtree_tgts,$(d)/a) $(TARGETS_$(d)/b)
