# GSFUSE

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make


ifneq ($(FOUNDATION_LIB),apple)
ADDITIONAL_CPPFLAGS += -DNO_OSX_ADDITIONS
endif
ADDITIONAL_CPPFLAGS += $(shell pkg-config --cflags fuse 2>/dev/null)
ADDITIONAL_CPPFLAGS += -DFUSE_USE_VERSION=26

ADDITIONAL_CPPFLAGS += -std=c99

SUBPROJECT_NAME = GSFUSE

GSFUSE_OBJC_FILES +=			\
	GMUserFileSystem.m		\
	GMDataBackedFileDelegate.m	\


-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble
