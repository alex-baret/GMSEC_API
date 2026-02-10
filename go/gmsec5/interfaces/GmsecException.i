/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module GmsecException

%{
#include <gmsec5/GmsecException.h>
using namespace gmsec::api5;
%}

%ignore gmsec::api5::GmsecException::operator=(const GmsecException&);

%include <gmsec5/util/wdllexp.h>
%include <gmsec5/GmsecException.h>


/* Map C++ GmsecException to Go panics */
%exception {
    try
    {
        $action
    }
    catch (const gmsec::api5::GmsecException& e)
    {
        _swig_gopanic(e.what());
    }
}

