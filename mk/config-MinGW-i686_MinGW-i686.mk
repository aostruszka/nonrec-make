include $(MK)/config-default.mk

CPPFLAGS += -DMINGW

# On mingw shared libraries have dll extension
SOEXT := dll

OPEN_GL_LIBS := -lopengl32 -lglu32
