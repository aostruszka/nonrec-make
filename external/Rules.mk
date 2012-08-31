# If you give target with absolute name it will be recognized as
# a trigger for some external build system.
TARGETS := $(d)/external_app

# Normally it is a job of this external build system to track
# dependencies.  But if you want to prevent triggering submake
# invocation every time you can monitor them on your own.
$(d)/external_app_DEPS := $(addprefix $(d)/,one two three)
$(d)/external_app_CMD = make -C $(@D)
