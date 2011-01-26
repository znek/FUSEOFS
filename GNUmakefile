# FUSEOFS

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

SUBPROJECT_NAME = FUSEOFS

FUSEOFS_INCLUDE_DIRS +=			\
	-I../GNUstepFUSE		\

FUSEOFS_OBJC_FILES +=			\
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
