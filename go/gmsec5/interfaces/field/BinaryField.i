/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module BinaryField

%{
#include <gmsec5/field/BinaryField.h>
using namespace gmsec::api5;
%}

%include <gmsec5/util/wdllexp.h>
%include <gmsec5/field/BinaryField.h>


%extend gmsec::api5::BinaryField
{
    /* Obsolete as of API 5.1, but leave in place to preserve binary compatibility */
    static BinaryField* CALL_TYPE cast_field(Field* field)
    {
        BinaryField* casted = dynamic_cast<BinaryField*>(field);

        if (casted == NULL)
        {
            throw GmsecException(FIELD_ERROR, FIELD_TYPE_MISMATCH, "Field cannot be casted to a BinaryField");
        }

        return casted;
    }
};
