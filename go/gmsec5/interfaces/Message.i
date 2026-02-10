/*
 * Copyright 2007-2025 United States Government as represented by the
 * Administrator of The National Aeronautics and Space Administration.
 * No copyright is claimed in the United States under Title 17, U.S. Code.
 * All Rights Reserved.
 */

%module Message
%{
#include <gmsec5/Message.h>
#include <list>
using namespace gmsec::api5;
%}

/* method containing list will be redefined */
%ignore gmsec::api5::Message::addFields(const gmsec::api5::util::List<Field*>&);

/* SWIG doesn't play well with these function headers
 * We'll tell SWIG to ignore them and define our own implementation using %extend
 */
%ignore gmsec::api5::Message::destroy(Message*&);

/* ignore overloaded addField() methods since many use types not applicable to Python */
%ignore gmsec::api5::Message::addField(const char*, const GMSEC_U8*, size_t);
%ignore gmsec::api5::Message::addField(const char*, bool);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_CHAR);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_F32);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_F64);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_I8);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_I16);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_I32);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_I64);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_U8);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_U16);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_U32);
%ignore gmsec::api5::Message::addField(const char*, GMSEC_U64);
%ignore gmsec::api5::Message::addField(const char*, const char*);

/* ignore methods that do not make sense in the python context */
%ignore gmsec::api5::Message::getI16Value();
%ignore gmsec::api5::Message::getI32Value();
%ignore gmsec::api5::Message::getU16Value();
%ignore gmsec::api5::Message::getU32Value();
%ignore gmsec::api5::Message::getU64Value();

/* ignore method that cannot be translated to Python */
%ignore gmsec::api5::Message::operator=(const Message&);



%include <gmsec5/util/wdllexp.h>
%include <gmsec5/Specification.h>
%include <gmsec5/Message.h>

%include <std_list.i>


%extend gmsec::api5::Message
{
    bool CALL_TYPE addFields(const std::list<gmsec::api5::Field*>& fields) {
        gmsec::api5::util::List<gmsec::api5::Field*> list_fields;

        for (std::list<gmsec::api5::Field*>::const_iterator it = fields.begin(); it != fields.end(); ++it) {
            list_fields.push_back(*it);
        }

        return self->addFields(list_fields);
    }

    static void CALL_TYPE destroy(Message* msg)
    {
        Message::destroy(msg);
    }
}
