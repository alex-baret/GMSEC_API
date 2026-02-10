#!/usr/bin/env bash

# Copyright 2007-2025 United States Government as represented by the
# Administrator of The National Aeronautics and Space Administration.
# No copyright is claimed in the United States under Title 17, U.S. Code.
# All Rights Reserved.

# Auto-generate Go SWIG interface files from the Python3 SWIG interfaces.
# This script strips Python-specific code (%rename, %pythoncode, dox includes)
# and generates Go-specific versions of files that need custom handling.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON3_DIR="$SCRIPT_DIR/../../python3/gmsec5/interfaces"
GO_DIR="$SCRIPT_DIR/interfaces"

COPYRIGHT_HEADER='/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */
'

# Create directory structure
mkdir -p "$GO_DIR/field" "$GO_DIR/util"


###############################################
# Generic transformation function
# Strips Python-specific SWIG directives:
#   - %rename lines
#   - %include "dox/..." lines
#   - %pythoncode %{ ... %} blocks
###############################################
transform_generic() {
    local src="$1"
    local dst="$2"

    awk '
        BEGIN { in_pythoncode = 0 }

        # Skip %rename lines
        /^[[:space:]]*%rename/ { next }

        # Skip %include "dox/" lines
        /^[[:space:]]*%include[[:space:]]+"dox\// { next }

        # Skip %pythoncode blocks (multiline)
        /%pythoncode[[:space:]]*%\{/ { in_pythoncode = 1; next }
        in_pythoncode && /^%\}/ { in_pythoncode = 0; next }
        in_pythoncode { next }

        # Print everything else
        { print }
    ' "$src" > "$dst"
}


###############################################
# Copy files that have no Python-specific code
###############################################
copy_direct_files() {
    echo "  Copying direct files (no transformation needed)..."
    for f in gmsec5_defs.i gmsec_version.i Errors.i; do
        cp "$PYTHON3_DIR/$f" "$GO_DIR/$f"
    done
}


###############################################
# Transform standard interface files
###############################################
transform_standard_files() {
    echo "  Transforming standard interface files..."

    # Root-level interfaces (Config.i handled separately due to Go naming conflicts)
    local root_files="
        Status.i
        Connection.i
        Message.i
        MessageFactory.i
        MessageValidator.i
        Callback.i
        EventCallback.i
        ReplyCallback.i
        ConfigFile.i
        ConfigFileIterator.i
        HeartbeatGenerator.i
        ResourceGenerator.i
        Specification.i
        FieldSpecification.i
        MessageSpecification.i
        SubscriptionInfo.i
        SchemaIDIterator.i
        MessageFieldIterator.i
    "
    for f in $root_files; do
        transform_generic "$PYTHON3_DIR/$f" "$GO_DIR/$f"
    done

    # Field interfaces (except BinaryField which needs special handling)
    local field_files="
        Field.i
        BooleanField.i
        CharField.i
        F32Field.i
        F64Field.i
        I8Field.i
        I16Field.i
        I32Field.i
        I64Field.i
        StringField.i
        U8Field.i
        U16Field.i
        U32Field.i
        U64Field.i
    "
    for f in $field_files; do
        transform_generic "$PYTHON3_DIR/field/$f" "$GO_DIR/field/$f"
    done

    # Utility interfaces (except Log.i which needs additional cleanup)
    local util_files="
        TimeUtil.i
        LogHandler.i
        Mutex.i
        Condition.i
    "
    for f in $util_files; do
        transform_generic "$PYTHON3_DIR/util/$f" "$GO_DIR/util/$f"
    done

    # Log.i - generic transform handles the %pythoncode blocks
    transform_generic "$PYTHON3_DIR/util/Log.i" "$GO_DIR/util/Log.i"
}


###############################################
# Generate Go-specific Config.i
# The Python3 version has a ConfigPair class with both
# public fields (name, value) and getter methods (getName, getValue).
# In Go SWIG, both generate GetName()/GetValue() causing a conflict.
# We hide the getter methods and let Go access the fields directly.
###############################################
generate_config() {
    echo "  Generating Go-specific Config.i..."
    transform_generic "$PYTHON3_DIR/Config.i" "$GO_DIR/Config.i"

    # Add %ignore directives for ConfigPair getters to avoid Go name conflicts
    # Insert before the %inline block that defines ConfigPair
    sed -i '/^%inline %{/i\
/* Ignore ConfigPair getter methods to avoid Go naming conflict with public fields */\
%ignore ConfigPair::getName;\
%ignore ConfigPair::getValue;\
' "$GO_DIR/Config.i"
}


###############################################
# Generate Go-specific BinaryField.i
# The Python3 version has Python-specific typemaps and constructors
# that reference PyObject/PyByteArray. For Go, we use the original
# C++ constructor and getValue() directly.
###############################################
generate_binary_field() {
    echo "  Generating Go-specific BinaryField.i..."
    cat > "$GO_DIR/field/BinaryField.i" << 'EOF'
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
EOF
}


###############################################
# Generate Go-specific GmsecException.i
# The Python3 version has Python-specific exception handling
# (PyErr_Fetch, PyErr_SetObject, etc.). For Go, SWIG converts
# C++ exceptions to Go panics via _swig_gopanic.
###############################################
generate_gmsec_exception() {
    echo "  Generating Go-specific GmsecException.i..."
    cat > "$GO_DIR/GmsecException.i" << 'EOF'
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

EOF
}


###############################################
# Generate main Go SWIG module file
###############################################
generate_main_module() {
    echo "  Generating main module file libgmsec_go.i..."
    cat > "$GO_DIR/libgmsec_go.i" << 'EOF'
/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module(directors="1") gmsec

#pragma SWIG nowarn=451

/* CGO build flags for compiling the wrapper and linking against the GMSEC API */
/* Note: ${SRCDIR} resolves to the directory containing the .go file (interfaces/) */
%insert(cgo_comment_typedefs) %{
#cgo CXXFLAGS: -I${SRCDIR}/../../../framework/include
#cgo LDFLAGS: -L${SRCDIR}/../../../bin -lgmsecapi -lstdc++
%}

/* Ignore C-binding types that are not applicable to Go */
%ignore GMSEC_BOOL;
%ignore GMSEC_Callback;
%ignore GMSEC_EventCallback;
%ignore GMSEC_ReplyCallback;
%ignore GMSEC_Config;
%ignore GMSEC_ConfigEntry;
%ignore GMSEC_ConfigFile;
%ignore GMSEC_ConfigFileIterator;
%ignore GMSEC_Connection;
%ignore GMSEC_ConnectionEvent;
%ignore GMSEC_Field;
%ignore GMSEC_HeartbeatGenerator;
%ignore GMSEC_LogEntry;
%ignore GMSEC_LogHandler;
%ignore GMSEC_LogLevel;
%ignore GMSEC_Message;
%ignore GMSEC_MessageEntry;
%ignore GMSEC_MessageFactory;
%ignore GMSEC_MessageFieldIterator;
%ignore GMSEC_MessageValidator;
%ignore GMSEC_ResourceGenerator;
%ignore GMSEC_ResponseStatus;
%ignore GMSEC_SchemaIDIterator;
%ignore GMSEC_Status;
%ignore GMSEC_SchemaLevel;
%ignore GMSEC_Specification;
%ignore GMSEC_SubscriptionEntry;
%ignore GMSEC_SubscriptionInfo;

%include gmsec_version.i

%include gmsec5_defs.i

%include Errors.i
%include GmsecException.i
%include Status.i

%include field/Field.i
%include field/BinaryField.i
%include field/BooleanField.i
%include field/CharField.i
%include field/F32Field.i
%include field/F64Field.i
%include field/I16Field.i
%include field/I32Field.i
%include field/I64Field.i
%include field/I8Field.i
%include field/StringField.i
%include field/U8Field.i
%include field/U16Field.i
%include field/U32Field.i
%include field/U64Field.i

/* Field type conversion helpers */
%inline %{
        gmsec::api5::BinaryField* to_BinaryField(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::BinaryField*>(field);
        }

        gmsec::api5::BooleanField* to_BooleanField(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::BooleanField*>(field);
        }

        gmsec::api5::CharField* to_CharField(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::CharField*>(field);
        }

        gmsec::api5::F32Field* to_F32Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::F32Field*>(field);
        }

        gmsec::api5::F64Field* to_F64Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::F64Field*>(field);
        }

        gmsec::api5::I16Field* to_I16Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::I16Field*>(field);
        }

        gmsec::api5::I32Field* to_I32Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::I32Field*>(field);
        }

        gmsec::api5::I64Field* to_I64Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::I64Field*>(field);
        }

        gmsec::api5::I8Field* to_I8Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::I8Field*>(field);
        }

        gmsec::api5::U16Field* to_U16Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::U16Field*>(field);
        }

        gmsec::api5::U32Field* to_U32Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::U32Field*>(field);
        }

        gmsec::api5::U64Field* to_U64Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::U64Field*>(field);
        }

        gmsec::api5::U8Field* to_U8Field(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::U8Field*>(field);
        }

        gmsec::api5::StringField* to_StringField(gmsec::api5::Field* field) {
                return dynamic_cast<gmsec::api5::StringField*>(field);
        }
%}

%include util/TimeUtil.i
%include util/LogHandler.i
%include util/Log.i
%include util/Mutex.i
%include util/Condition.i

%include MessageFieldIterator.i
%include Message.i
%include MessageFactory.i
%include MessageValidator.i
%include SubscriptionInfo.i
%include Callback.i
%include EventCallback.i
%include ReplyCallback.i
%include Connection.i
%include Config.i
%include ConfigFile.i
%include ConfigFileIterator.i
%include FieldSpecification.i
%include MessageSpecification.i
%include HeartbeatGenerator.i
%include ResourceGenerator.i
%include SchemaIDIterator.i
%include Specification.i
EOF
}


###############################################
# Main execution
###############################################
echo "Generating Go SWIG interface files..."
echo "  Source: $PYTHON3_DIR"
echo "  Target: $GO_DIR"

copy_direct_files
transform_standard_files
generate_config
generate_binary_field
generate_gmsec_exception
generate_main_module

echo "Go interface generation complete."
