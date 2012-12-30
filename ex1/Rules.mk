TARGETS := app$(EXE) cli$(EXE)
SUBDIRS := Dir_1 Dir_2 Dir_3

INSTALL_BIN := $(TARGETS)
INSTALL_DOC := Readme.txt

app$(EXE)_DEPS = top_a.o top_b.o main.o $(SUBDIRS_TGTS)
app$(EXE)_LIBS = -lm
# Let's use DEFAULT_MAKECMD for app$(EXE)

cli$(EXE)_DEPS = cli.o cli_dep.o
cli$(EXE)_CMD = $(LINK.c) $(^R) $(LDLIBS) -o $@
