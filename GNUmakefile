# FUSEOFS

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif

include $(GNUSTEP_MAKEFILES)/common.make

GNUSTEP_HOST_OS := $(shell gnustep-config --variable=GNUSTEP_HOST_OS 2>/dev/null)


SUBPROJECT_NAME = FUSEOFS

ADDITIONAL_CPPFLAGS += -std=c99

ifneq ($(FOUNDATION_LIB),apple)
ADDITIONAL_CPPFLAGS += -DNO_OSX_ADDITIONS
FUSEOFS_SUBPROJECTS = GSFUSE
FUSEOFS_INCLUDE_DIRS +=	-IGSFUSE
endif

ifeq ($(GNUSTEP_HOST_OS),linux-gnu)
ADDITIONAL_CPPFLAGS += -D_FILE_OFFSET_BITS=64
endif

FUSEOFS_OBJC_FILES +=			\
	FUSEOFSAppController.m		\
					\
	NSObject+FUSEOFS.m		\
					\
	FUSEObjectFileSystem.m		\
	FUSEOFSLookupContext.m		\
					\
	FUSEOFSMemoryObject.m		\
	FUSEOFSMemoryFile.m		\
	FUSEOFSMemoryContainer.m	\
	FUSEOFSFileProxy.m		\
  
	

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/subproject.make
-include GNUmakefile.postamble
