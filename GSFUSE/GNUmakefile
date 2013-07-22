# GSFUSE

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_HOST_OS := $(shell gnustep-config --variable=GNUSTEP_HOST_OS 2>/dev/null)

SUBPROJECT_NAME = GSFUSE

ifneq ($(FOUNDATION_LIB),apple)
ADDITIONAL_CPPFLAGS += -DNO_OSX_ADDITIONS
endif
ADDITIONAL_CPPFLAGS += $(shell pkg-config --cflags-only-other fuse 2>/dev/null)
ADDITIONAL_CPPFLAGS += -DFUSE_USE_VERSION=26

ADDITIONAL_CPPFLAGS += -std=c99

ifeq ($(GNUSTEP_HOST_OS),linux-gnu)
ADDITIONAL_CPPFLAGS += -DIS_LINUX
ADDITIONAL_CPPFLAGS += -D_BSD_SOURCE
endif

ADDITIONAL_INCLUDE_DIRS = $(shell pkg-config --cflags-only-I fuse 2>/dev/null)

GSFUSE_OBJC_FILES +=			\
	GMUserFileSystem.m		\
	GMDataBackedFileDelegate.m	\

GMUserFileSystem.m_FILE_FLAGS = -Wno-unused-variable

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble
