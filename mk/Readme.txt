################################################################################
#                  Non-recursive make build system                             #
#                  -------------------------------                             #
#     Copyright (C) 2012 Andrzej Ostruszka <andrzej.ostruszka@gmail.com>       #
#                                                                              #
#          URL: http://github.com/aostruszka/nonrec-make                       #
#          (or older: http://nonrec-make.googlecode.com/)                      #
#                                                                              #
# Permission is hereby granted, free of charge, to any person obtaining a copy #
# of this software and associated documentation files (the "Software"), to     #
# deal in the Software without restriction, including without limitation the   #
# rights to use, copy, modify, merge, publish, distribute, sublicense,         #
# and/or sell copies of the Software, and to permit persons to whom the        #
# Software is furnished to do so, subject to the following conditions:         #
#                                                                              #
# The above copyright notice and this permission notice shall be included in   #
# all copies or substantial portions of the Software.                          #
#                                                                              #
# Except as contained in this notice, the name(s) of the above copyright       #
# holders shall not be used in advertising or otherwise to promote the sale,   #
# use or other dealings in this Software without prior written authorization.  #
#                                                                              #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS #
# IN THE SOFTWARE.                                                             #
################################################################################

NOTE: This readme _might_ not be up to date.  For up to date information
see the above URL (and accompanying wiki pages).

This is my attempt to implement a non-recursive make build system.  For
the motivation Google for the paper "Recursive make consider harmful" by
Peter Miller.

I've seen couple of other proposals and decided to have something that
will be a blend of nice ideas I have seen plus some improvements.  If
you actually use this I'd like to hear from you :) - is it useful, does
it perform well, do you have any suggestions for the improvements ...
and so on.  This implementation is based on GNU make and its new
features introduced in 3.80.  But don't use that version - these
features had bugs in that version.  Use version 3.81 where everything
works OK.

Before you keep on reading though, just take a look at the structure of
the Rules.mk files (Rules.top has exactly the same structure as Rules.mk
- it just has another name to ease location of the top level project
directory from its subfolders).
I've got a feeling that it is much easier to understand how the system
looks from the user perspective just by looking at the example than
reading its explanation :D.

OK, now that you have a feeling how the Rules.mk look like let me walk
you through an example (ex1 in the repository).  Consider the project
that has some source files at the top directory and is depending on two
libraries in Dir_1 and Dir_2 and another one in Dir_3.  The libraries
themselves are partitioned between several subdirectories and Dir_2 has
some examples in a separate subfolder (do not pay attention to all *.c
files).

ex1/
  Makefile
  Rules.top <- Just a symlink to Rules.mk to mark where the top level is
  Rules.mk
  main.c
  top_a.c
  top_b.c
  cli.c
  cli_dep.c
  mk/* <- This is where the mk files from this build system are
  Dir_1/
    Makefile
    Rules.mk
    dir_1_file1.c
    dir_1_file2.c
    dir_1_file3.c
    Dir_1a/
      Makefile
      Rules.mk
      dir_1a_file1.c
      dir_1a_file2.c
      dir_1a_file3.c
    Dir_1b/
      Makefile
      Rules.mk
      src/
        dir_1b_file1.c
        dir_1b_file2.c
  Dir_2/
    Makefile
    Rules.mk
    dir_2_file1.c
    dir_2_file2.c
    Dir_2a/
      Makefile
      Rules.mk
      dir_2a_file1.c
      dir_2a_file2.c
      dir_2a_file3.c
    Dir_2b/
      Makefile
      Rules.mk
      dir_2b_file1.c
      dir_2b_file2.c
      dir_2b_file3.c
    Dir_ex/
      Makefile
      Rules.mk
      ex.c
  Dir_3/
    Makefile
    Rules.mk
    dir_3_file1.c
    dir_3_file2.c

There's one top level make file (Rules.top) which eventually includes
all the makefiles.  In addition in each directory there is Makefile
(which can be a link to the one in the top level directory) which
searches for the Rules.top includes it with the default goal
changed to rebuild only targets for the current directory.  This allows
you to run make from each subdirectory and update only part of the
targets (in contrary to other implementation which usually require
you to run it at the top level and make full build each time).

This build system was designed to have very simple structure of the
"user makefiles".  The user just has to set the Rules.mk files in each
directory and some general configuration options.  All the "magic" is
hidden in header.mk, footer.mk and skel.mk which don't have to be
modified [1].

The structure of the Rules.mk is following (this is from top level
Rules.top which has the same format as Rules.mk - and in fact it is
suggested that it should be a symlink to normal Rules.mk file since it
will allow for this project to act as a subproject of some super project
treating your whole project tree as a subdirectory[2]):

-8<---Rules.top---------------
1:  TARGETS = app.exe cli.exe
2:  SUBDIRS = Dir_1 Dir_2
3:
4:  app.exe_DEPS = top_a.o top_b.o main.o $(SUBDIRS_TGTS)
5:  app.exe_LIBS = -lm
6:  # Let's use DEFAULT_MAKECMD for app.exe
7:
8:  cli.exe_DEPS = cli.o cli_dep.o
9:  cli.exe_CMD = $(LINK.c) $^ $(LDLIBS) -o $@
-8<---------------------------

Line 1 - this directory has two targets that should be built.
Line 2 - this directory has two subdirectories that should be scanned
Line 4 - app.exe depends on ... (SUBDIRS_TGTS is a variable that
	 contains all the targets from the subdirectories mentioned at
	 line 4)
Line 5 - app.exe should be linked with math library
Line 6 - app.exe will be built with default "rule"
Line 8 - cli.exe depends on ... and
Line 9 - use the following command to build it

You can specify the targets for current directory in two ways:
1. Give them in TARGETS.  Each target can have it's own *_DEPS, *_LIBS
  and *_CMD which give the dependencies, additional libs needed and
  a command to run which will update the target.  They are explained
  a bit below.
2. The targets are simply objects - or in more general files that
  match patterns in AUTO_TGTS, and have appropriate rules in 'skeleton'.
  In that case you can list them in OBJS or SRCS like e.g. in Rules.mk
  from Dir_1a

-8<---Dir_2/Dir_2a/Rules.mk---
1: SRCS := dir_2a_file1.c dir_2a_file2.c dir_2a_file3.c
-8<---------------------------

There are "reserved" variables that you should not modify.  Most notably:
- $(d) is the directory of the current Rules.mk [see note 2]
- $(TOP) is the top level directory of the project tree
- $(MK) is the directory where the included *.mk makefiles are
For the full list you have to take a look at the makefiles in mk
directory (e.g. in the skel.mk there are macros 'include_subdir_rules',
'save_vars', 'tgt_rule' and 'skeleton' which you should not change [1]).

Going back to the Rules.mk.  Normally wildcards in variable assignments
are not expanded in make but this make system detects wildcards in SRCS
and expands them (both in directory of the Rules.mk and its SRCS_VPATH
subdirectories - see below what SRCS_VPATH is used for).  Thus you can
simply say in Rules.mk:

SRCS := *.c

If you have directory with large number of files where simple glob is
what you want to use in SRCS but there are some files that you'd like to
exclude just list them in SRCS_EXCLUDES :) - this is a list of makefile
patterns e.g.

SRCS_EXCLUDES := extra% test%

Of course you can use the built in make wildcards but you should do that
as follows:

SRCS := $(notdir $(wildcard $(d)/*.c))

Keep in mind that the directory where make is invoked is usually different
from where given Rules.mk is located.

When supplying the value for *_DEPS you can refer to the object from the
same directory with no directory prefix.  To be specific all
dependencies that are not absolute paths will be treated as ones from
the $(OBJDIR) subdirectory of current directory (OBJDIR and OBJPATH are
"discussed" below).  You can use SUBDIRS_TGTS variable which will list
all targets in subdirectories.  You can also name them explicitly like
$(TARGETS_$(d)/subdir) and so on - see e.g. the Rules.mk in Dir_2
directory where Dir_ex is mentioned as a subdirectory but is excluded
from the *_DEPS (this allows you to create folders that "inherit" all
the setting from the project build system but are not meant to be a part
of the project itself - like examples).  For instance:

dir1_lib.a_DEPS = dir_1_file1.o dir_1_file2.o dir_1_file3.o $(SUBDIRS_TGTS)

tells that dir1_lib.a (which will be created in Dir_1/$(OBJDIR)) depends
on several object files from the same directory and the targets from all
subdirectories.

One last thing about the TARGETS/OBJS.  By default source files for the
objects are searched in the directory where Rules.mk is, but if you want
to have source files in a subdirectory (say 'src') you can do that via
SRCS_VPATH variable (see skel.mk).  E.g.:

SRCS_VPATH := src1 src2

will cause make to first look at the directory where Rules.mk is present
and then in its src1 and src2 subdirectories.

*_LIBS are appended to the LDLIBS variable when updating the target.
This variable is used by several make built in rules but if you create
your own rule or MAKECMD.* (see next paragraph) you can refer to it (see
the function 'save_vars').

When *_CMD is not present and the target does not match any pattern in
AUTO_TGTS then either MAKECMD.suff (where .suff is the suffix of the
target) or DEFAULT_MAKECMD is used - take a look into skel.mk.

If you want to setup special flags for compilation you can do that via
"directory specific variables".  As an example here's what I did for
compilation of C files.  There's a built in rule in make which uses
COMPILE.c variable for making %.o out of %.c so I added $(DIR_CFLAGS) to
its default value and DIR_CFLAGS is defined in skel.mk as:

DIR_INCLUDES = $(addprefix -I,$(INCLUDES_$(<D)))
DIR_CFLAGS = $(CFLAGS_$(<D)) $(DIR_INCLUDES)

So it extracts the directory part of the first prerequisite in the rule
(that is %.c file - check the section 'automatic variables' in make
manual for the meaning of $(<) and $(<D)) and refer to variables named
CFLAGS_the_directory_part and INCLUDES_the_directory_part.
Thus if you wanted to add special includes for files in Dir_1/Dir_1b you
could add:

INCLUDES_$(d) := $(TOP)/some/special/include_dir

into its Rules.mk and all files in this directory will be compiled with
-I$(TOP)/some...  switch.  The same goes for CFLAGS and CXXFLAGS.

The same goes for the linker flags - quoting from skel.mk:

LDFLAGS = $(addprefix -L,$(LIBDIRS_$(subst /$(OBJDIR),,$(@D))))
LDLIBS = $(LIBS_$(@))

The above means that if targets in given directory need to be linked
with special -L switches you can provide them via LIBDIRS_$(d)
variables.  If there are some global -L switches just append them in
skel.mk.  The second line above shows how *_LIBS variable that you can
give for specific target gets added to the LDLIBS (there's 'save_vars'
in between if you're curious :)).

You can of course use target specific variables that GNU make supports
so you have more control (if you don't know what target specific
variables are take a look into manual).  Say you want to compile
dir_1b_file2.c with an additional flag but all other files in
Dir_1/Dir_1b directory should not have this flag turned on.  All you
need to do is to add this line into Rules.mk in Dir_1b directory.

$(OBJPATH)/dir_1b_file2.o : CFLAGS += -ansi

OBJPATH is a variable that contains the full directory where the
resulting object file will be placed.  While we are at this, by default
all targets are compiled into OBJDIR (defined in skel.mk as 'obj')
subdirectory of the directory where Rules.mk is present.  You can use
this OBJDIR variable (and perhaps some conditional statements) to setup
the output path according to your current compilation mode.  E.g.
obj/debug for objects with debugging information or obj/ppc_7xx for
cross compilation to the given Power PC family and so on.  There's
predefined (in config* files) HOST_ARCH variable that you can use for
this (e.g. set OBJDIR := obj/$(HOST_ARCH) in skel.mk).

Finally let me explain what targets are defined and the way you can run
them from command line.  By default (that is if you have not modified
anything :)) there are several targets that are "global".  It is 'all',
'clean_all' and 'dist_clean'.  If you specify them in the command line
they will respectively rebuild whole tree, clean everything and clean
everything together with the removal of OBJDIRs - no matter from which
directory you started make.  BTW if there's something that you want to
clean up and it's not in the OBJDIR - e.g. you've got file lexer.l out
of which lexer.c and lexer.h is generated and you want them to be
removed - you can specify this in the variable CLEAN (this is relative
to the directory where Rules.mk is).
In addition to those each dir has "it's own" targets.  These are:

1) dir_<directory_path>
   which builds all targets in given directory plus its dependencies
2) tree_<directory_path>
   which builds all targets in subtree starting at directory given
3) clean_<directory_path>
   which removes all "products" from the $(OBJDIR) subdirectory of
   current directory
4) clean_tree_<directory_path>
   which does clean_<directory_path> and the same for each its
   subdirectory

For your convenience there are couple "aliases" defined (see Makefile).
When no target is given on command line it defaults to dir_$(pwd).
If you give 'clean' as a target that will result in execution of target
clean_$(pwd) and the same for 'clean_tree'.  E.g. say you're in Dir_1.
Then:

* 'make' (same as 'make dir_$(pwd)')
   builds all targets in the Dir_1 which in our example is
   Dir_1/obj/dir1_lib.a - of course any of its dependencies that are not
   up to date are updated also.  This rule has one exception - if your
   Rules.mk has no targets and only SUBDIRS (e.g. you have grouped
   several subdirectories in one directory) then simple 'make' in this
   directory - instead of doing nothing - will build targets of all its
   subdirectories.
* 'make tree' (same as 'make tree_$(pwd)')
   rebuilds everything in given subtree
* 'make clean' (same as 'make clean_$(pwd)')
   removes everything from Dir_1/obj/
* 'make clean_tree (same as 'make clean_tree_$(pwd)')
   cleans Dir_1/obj and Dir_1/Dir_1[abc]/obj

You can obviously provide the path by yourself - it does not have to
be $(pwd) - and as usual you can build particular object files too e.g.
'make $(pwd)/obj/dir_1_file1.o'

And that would be it.  Gee, so much writing for something that is rather
simple to use - go ahead and take a look again at these Rules.mk in
various directories.  Setting up you project should be simple by now :).

Have fun!

					Andrzej Ostruszka

[1] Unless this build system does not do what you wanted :-P.  In that
case you probably need to spiff it up.  So you'll need to
digest it first and note [3] is my hand at it :).

[2] There is one limitation that you should be aware.
Prior to commit 070f681 you should not have in your project two "target
specific" LIBS, LDFLAGS or CMD variables (that is those that are used
during second phase of make execution) that have the same names!  For
example in one part of your tree you're generating target abc which has
it's abc_CMD and in the other part another target that has the same name
and also it's own command.  In such case the last assignment to abc_CMD
will hold and it will be used for both targets.  The same goes for LIBS
and LDFLAGS.

And this also applied to situation when you would like to use two
subprojects in one larger project.  There should be no clash between
variables from these subprojects.

Starting with commit 070f681 you can have in your (sub)projects two
LIBS, LDFLAGS or CMD variables.  However there is a catch here! Since
these variables are not mandatory (you don't have to provide them for
each target) in order to differentiate between case where abc_CMD was
actually given for this instance of abc target from the situation where
abc_CMD is still visible from previous instance of abc target those
abc_(LIBS|LDFLAGS|CMD) variables are cleared once their value is
used/remembered (see save_vars macro in skel.mk). That means referring
to these variables outside Rules.mk where they were assigned will not
work (and even in the same Rules.mk they will work only in case of
simply expanded variables - not recursive). If you have such need I'd
advice to introduce your own variable and use this variable in all
places, e.g.:

MATH_LIBS := -lgsl -lgslcblas -lm
...
TARGETS := abc

abc_DEPS = ...
abc_LIBS = $(MATH_LIBS)
...

[3] You should know that make works in two phases - first it scans the
makefiles and then it begins their execution (see discussion of
'immediate' and 'deferred' in section 'Reading Makefiles' of make
manual).  This implies that the $(d) variable is not valid during
execution of the commands used for target updates.  If you need to refer
to the directory of the target or prerequisite you should rely on
automatic variables (@, <, ...) and built in functions (dir, notdir,
...).

Every Rules.mk (or Rules.top) need to be included in cooperation with
header.mk and footer.mk.  This is now done automatically but in older
versions this was not so and user had to include them manually.
The main purpose of header is to clear all variables that you can use
inside Rules.mk so that values set in one rules file does not propagate
to other.  In addition at the top level it sets the $(d) variable (which
stands for the directory where the currently included Rules.mk is) and
includes the skel.mk so the top level Rules.top can have exactly the
same structure as other Rules.mk.

The skel.mk is a skeleton which defines variables used by make.  In
addition it includes:
- config.mk - this is a file with the "configuration" for your project
- def_rules.mk - where to put general rules (e.g. pattern rules).  E.g.
  if you want to add a rule that builds %.o out of %.m4 (by running m4
  preprocessor before passing the contents of file to CC) just put it in
  here.

skel.mk also defines some functions like save_vars and tgt_rule
which are called in the footer.mk.  Take a look into make manual for the
way the functions are defined and called if you're not familiar with it.

include_subdir_rules: This is where I keep track of directory of
	currently included makefile and include the Rules.mk from the
	subdirectories.  This function is called in footer.mk in foreach
	loop with a subdirectory name as an argument.

save_vars: This one is very simple it just saves the target specific
	variables under their "full path" variables.  E.g.
	dir1_lib.a_DEPS will get saved as DEPS_$(TOP)/Dir_1/obj/dir1_lib.a
	This has two purposes.  First it allows you to have targets with
	the same names in different directories (not that I recommend
	this :)) and allows for easier definition of tgt_rules :-P

tgt_rule: This is where the rule for given target is created.  First
	I convert all relative dependencies to the absolute ones then
	I include all dependency files (by default they are created as
	side effects during compilation - if your compiler does not
	allow you to do that just make simple shell script that will do
	this).  I also append appropriate libs and then issue the rule
	for this target.  By using the short circuiting 'or' command
	I give priority to the CMD over MAKECMD.suffix which itself has
	priority over DEFAULT_MAKECMD.

skeleton: This is just a skeleton for compilation of files in given
	directory.  If you want to add some rule here then also add
	appropriate pattern to the AUTO_TGTS that will filter out these
	targets and prevent generation of the specific rules via
	tgt_rule function.

The footer.mk is where Rules.mk gets translated into the proper
makefile.  There's not much to explain, just take a look in there.
First I memorize the targets for given directory (either from OBJS/SRCS
or from TARGETS) with appropriate directory prefix.  If there's need to
save the target specific *_(CMD|DEP|LIB) I do it.  Then I include all
the Rules.mk from the subdirectories.  Then I define the targets for
given directory either explicitly (like clean_all or clean_$(d)) or by
evaluation of the 'skeleton' mentioned above or by iterating through all
targets which do not match AUTO_TGTS and evaluating what tgt_rule
function for this target has returned.

In case you want to play with these settings make sure you understand
how make works, what are it's phases, when and how the variables are
expanded and so on.  It will save you a lot of time :).

Best regards
Andrzej
