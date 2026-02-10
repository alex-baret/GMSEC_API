# Copyright 2007-2025 United States Government as represented by the
# Administrator of The National Aeronautics and Space Administration.
# No copyright is claimed in the United States under Title 17, U.S. Code.
# All Rights Reserved.

GMSEC_API_HOME = ../..

include $(GMSEC_API_HOME)/config/$(GMSEC_PLATFORM)

TARGET          = libgmsec_go.so

SWIG            = $(SWIG_HOME)/bin/swig
SWIG_LIB       := $(shell $(SWIG) -swiglib 2>/dev/null)
SWIG_SWG        = -I$(SWIG_LIB)/go -I$(SWIG_LIB)
SWIG_OPTS       = -c++ -go -cgo -intgosize 64 $(SWIG_SWG) -DCHAR_BIT=8 -DSWIG_BINDING

FRAMEWORK_DIR   = ../../framework

GMSEC_INCS      = -I$(FRAMEWORK_DIR)/include -I$(CXX_INCS)

INTERFACEDIR    = interfaces

GO_BINDIR       = $(BINDIR)/lib/GMSECAPI5/go

WRAPPED_SRC     = $(INTERFACEDIR)/libgmsec_go_wrap.cxx

WRAPPED_OBJ     = $(INTERFACEDIR)/libgmsec_go_wrap.o

OBJECTS        += $(WRAPPED_OBJ)


default: check_swig check_go message generate $(WRAPPED_SRC) $(WRAPPED_OBJ) $(BINDIR)/$(TARGET) install


check_swig:
	@if [ -z $(SWIG_HOME) ]; then \
		echo; \
		echo; \
		echo "###########################################################"; \
		echo "#"; \
		echo "# SWIG_HOME is not defined"; \
		echo "#"; \
		echo "# Skipping build of Go binding for API 5.x"; \
		echo "#"; \
		echo "###########################################################"; \
		exit 1; \
	fi


check_go:
	@if ! command -v go >/dev/null 2>&1; then \
		echo; \
		echo; \
		echo "###########################################################"; \
		echo "#"; \
		echo "# go not found in PATH"; \
		echo "#"; \
		echo "# Skipping build of Go binding for API 5.x"; \
		echo "#"; \
		echo "###########################################################"; \
		exit 1; \
	fi


message:
	@echo
	@echo
	@echo "###########################################################"
	@echo "#"
	@echo "#  Building Go binding for GMSEC API 5.x"
	@echo "#"
	@echo "###########################################################"


generate:
	@ ./generate_interfaces.sh


$(INTERFACEDIR)/%_wrap.cxx: $(INTERFACEDIR)/%.i
	$(SWIG) $(SWIG_OPTS) $(GMSEC_INCS) $<
	@ ./patch.sh


$(INTERFACEDIR)/%.o: $(INTERFACEDIR)/%.cxx
	$(CXX) -c $(API_CXXFLAGS) $< -o $@


$(BINDIR)/$(TARGET): $(OBJECTS)
	$(DLINK) $(OBJECTS) $(LDFLAGS) -o $@


install:
	mkdir -p $(GO_BINDIR)
	cp $(INTERFACEDIR)/*.go $(GO_BINDIR)/


clean:
	find $(INTERFACEDIR) \( -name '*.gcno' -o -name '*.gcda' \) -exec rm -rf {} \;
	find $(INTERFACEDIR) \( -name '*.cxx' -o -name '*.go' -o -name '*.o' -o -name '*.h' -o -name '*.c' \) -exec rm -rf {} \;
	$(RM) -f $(BINDIR)/$(TARGET) $(GO_BINDIR)/*.go
