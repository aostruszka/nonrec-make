include $(MK)/header.mk

TARGETS := b.a
SUBDIRS := 1 2

# You can't use simple $(call subtree_tgts,$(d)) since it includes
# target of this directory also and this would be a circular dependency
b.a_DEPS = b.o $(foreach sd,$(SUBDIRS_$(d)),$(call subtree_tgts,$(sd)))

include $(MK)/footer.mk
