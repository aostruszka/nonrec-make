TARGETS = app.exe cli.exe
SUBDIRS = Dir_1 Dir_2 Dir_3

app.exe_DEPS = top_a.o top_b.o main.o $(SUBDIRS_TGTS)
app.exe_LIBS = -lm
# Let's use DEFAULT_MAKECMD for app.exe

cli.exe_DEPS = cli.o cli_dep.o
cli.exe_CMD = $(LINK.c) $(^R) $(LDLIBS) -o $@
