/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module Log
%{
#include <map>
#include <gmsec5/util/Log.h>
using namespace gmsec::api5;
%}

%ignore gmsec::api5::util::Log::registerHandler(GMSEC_LogHandler*);
%ignore gmsec::api5::util::Log::registerHandler(GMSEC_LogLevel, GMSEC_LogHandler*);


%include <gmsec5/util/wdllexp.h>
%include <gmsec5/util/Log.h>

%extend gmsec::api5::util::Log {


};


