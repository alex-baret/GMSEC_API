/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module TimeUtil
%{
#include <gmsec5/util/TimeUtil.h>
using namespace gmsec::api5;
using namespace gmsec::api5::util;
%}

%ignore gmsec::api5::util::TimeUtil::formatTime(const GMSEC_TimeSpec&, char*);
%ignore gmsec::api5::util::TimeUtil::formatTime(const GMSEC_TimeSpec&, int, char*);

%ignore operator==(const GMSEC_TimeSpec&, const GMSEC_TimeSpec&);
%ignore operator>(const GMSEC_TimeSpec&, const GMSEC_TimeSpec&);
%ignore operator<(const GMSEC_TimeSpec&, const GMSEC_TimeSpec&);


%include "std_string.i"

%include <gmsec5/util/wdllexp.h>
%include <gmsec5/util/TimeUtil.h>

%extend gmsec::api5::util::TimeUtil {
        static std::string CALL_TYPE formatTime(const GMSEC_TimeSpec& ts)
        {
                char tmp[GMSEC_TIME_BUFSIZE];
                gmsec::api5::util::TimeUtil::formatTime(ts, tmp);
                return std::string(tmp);
        }

        static std::string CALL_TYPE formatTime(const GMSEC_TimeSpec& ts, int subs)
        {
                char tmp[GMSEC_TIME_BUFSIZE];
                gmsec::api5::util::TimeUtil::formatTime(ts, subs, tmp);
                return std::string(tmp);
        }
};
